import * as admin from 'firebase-admin';
import { z } from 'zod';

import { ai } from './genkit';

export function buildTools(uid: string) {
  const db = admin.firestore();
  const txCol = db.collection('users').doc(uid).collection('transactions');

  const getRecentTransactions = ai.defineTool(
    {
      name: 'getRecentTransactions',
      description:
        'Returns the user\'s transactions from the last N days. Use this to answer questions about recent spending or income.',
      inputSchema: z.object({
        days: z.number().int().min(1).max(365),
      }),
      outputSchema: z.object({
        count: z.number(),
        transactions: z.array(
          z.object({
            name: z.string(),
            amount: z.number(),
            type: z.string(),
            category: z.string(),
            date: z.string(),
          }),
        ),
      }),
    },
    async ({ days }) => {
      const cutoff = admin.firestore.Timestamp.fromMillis(
        Date.now() - days * 24 * 60 * 60 * 1000,
      );
      const snap = await txCol.where('date', '>=', cutoff).limit(500).get();
      const transactions = snap.docs.map((d) => {
        const v = d.data();
        const dateField = v.date as admin.firestore.Timestamp | undefined;
        return {
          name: (v.name as string) ?? '',
          amount: Number(v.amount ?? 0),
          type: (v.type as string) ?? 'expense',
          category: (v.category as string) ?? '',
          date: dateField ? dateField.toDate().toISOString() : '',
        };
      });
      return { count: transactions.length, transactions };
    },
  );

  const getMonthlySummary = ai.defineTool(
    {
      name: 'getMonthlySummary',
      description:
        'Returns aggregated totals for the current calendar month: total income, total expenses, savings (income - expenses), and the top spending categories.',
      inputSchema: z.object({}),
      outputSchema: z.object({
        month: z.string(),
        totalIncome: z.number(),
        totalExpense: z.number(),
        savings: z.number(),
        topCategories: z.array(
          z.object({ category: z.string(), total: z.number() }),
        ),
      }),
    },
    async () => {
      const now = new Date();
      const start = new Date(now.getFullYear(), now.getMonth(), 1);
      const snap = await txCol
        .where('date', '>=', admin.firestore.Timestamp.fromDate(start))
        .limit(1000)
        .get();

      let totalIncome = 0;
      let totalExpense = 0;
      const byCategory = new Map<string, number>();

      for (const d of snap.docs) {
        const v = d.data();
        const amount = Number(v.amount ?? 0);
        if (v.type === 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
          const cat = (v.category as string) || 'Other';
          byCategory.set(cat, (byCategory.get(cat) ?? 0) + amount);
        }
      }

      const topCategories = [...byCategory.entries()]
        .sort((a, b) => b[1] - a[1])
        .slice(0, 5)
        .map(([category, total]) => ({ category, total }));

      const month = `${start.getFullYear()}-${String(start.getMonth() + 1).padStart(2, '0')}`;
      return {
        month,
        totalIncome,
        totalExpense,
        savings: totalIncome - totalExpense,
        topCategories,
      };
    },
  );

  return [getRecentTransactions, getMonthlySummary];
}
