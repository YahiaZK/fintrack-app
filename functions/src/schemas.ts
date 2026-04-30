import { z } from 'zod';

export const TransactionProposalSchema = z.object({
  name: z
    .string()
    .min(1)
    .describe('Short label for the transaction, e.g. "Groceries", "Coffee", "Salary".'),
  amount: z.number().positive().describe('Positive amount in user currency.'),
  type: z.enum(['income', 'expense']),
  category: z
    .string()
    .min(1)
    .describe('Free-form category like "Food", "Transport", "Salary", "Entertainment".'),
  date: z
    .string()
    .datetime()
    .describe('ISO 8601 datetime. Default to now if user did not specify.'),
});
export type TransactionProposal = z.infer<typeof TransactionProposalSchema>;

export const AssistantOutputSchema = z.object({
  reply: z.string().describe('Friendly conversational reply shown to the user.'),
  proposal: TransactionProposalSchema.nullable().describe(
    'Set to a proposal object ONLY when the user is logging a single transaction; otherwise null.',
  ),
});
export type AssistantOutput = z.infer<typeof AssistantOutputSchema>;
