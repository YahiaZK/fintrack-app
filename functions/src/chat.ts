import * as admin from 'firebase-admin';
import { defineSecret } from 'firebase-functions/params';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import type { MessageData } from 'genkit';

import { ai } from './genkit';
import { buildSystemPrompt } from './prompt';
import { AssistantOutputSchema } from './schemas';
import { buildTools } from './tools';

const GEMINI_API_KEY = defineSecret('GEMINI_API_KEY');

const HISTORY_LIMIT = 20;
const MAX_MESSAGE_LEN = 1000;
const MAX_CHAT_ID_LEN = 64;

export const chatWithAssistant = onCall(
  {
    secrets: [GEMINI_API_KEY],
    region: 'us-central1',
    cors: true,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError('unauthenticated', 'Sign in required.');
    }

    const data = (request.data ?? {}) as { chatId?: unknown; message?: unknown };
    const chatId =
      typeof data.chatId === 'string' && data.chatId.length > 0
        ? data.chatId
        : 'default';
    if (chatId.length > MAX_CHAT_ID_LEN) {
      throw new HttpsError('invalid-argument', 'invalid chatId.');
    }
    if (typeof data.message !== 'string' || !data.message.trim()) {
      throw new HttpsError('invalid-argument', 'message must be a non-empty string.');
    }
    if (data.message.length > MAX_MESSAGE_LEN) {
      throw new HttpsError('invalid-argument', 'message too long.');
    }
    const message = data.message.trim();

    const db = admin.firestore();
    const userDocRef = db.collection('users').doc(uid);
    const messagesCol = userDocRef
      .collection('chats')
      .doc(chatId)
      .collection('messages');

    const userMsgRef = messagesCol.doc();
    await userMsgRef.set({
      role: 'user',
      text: message,
      proposal: null,
      status: null,
      transactionId: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const historySnap = await messagesCol
      .orderBy('createdAt', 'desc')
      .limit(HISTORY_LIMIT + 1)
      .get();

    const history: MessageData[] = historySnap.docs
      .filter((d) => d.id !== userMsgRef.id)
      .reverse()
      .map((d) => {
        const v = d.data();
        return {
          role: v.role === 'assistant' ? 'model' : 'user',
          content: [{ text: (v.text as string) ?? '' }],
        };
      });

    const userSnap = await userDocRef.get();
    const userName = (userSnap.data()?.name as string | undefined) ?? undefined;

    let output: { reply: string; proposal: unknown | null };
    try {
      const systemPrompt = buildSystemPrompt({
        todayISO: new Date().toISOString(),
        userName,
      });
      const messages: MessageData[] = [
        ...history,
        { role: 'user', content: [{ text: message }] },
      ];
      const result = await ai.generate({
        system: systemPrompt,
        messages,
        tools: buildTools(uid),
        output: { schema: AssistantOutputSchema },
      });
      output = result.output ?? {
        reply: 'Sorry, I could not understand that.',
        proposal: null,
      };
    } catch (err) {
      console.error('genkit generate failed', err);
      throw new HttpsError('internal', 'Assistant failed to respond.');
    }

    const assistantMsgRef = messagesCol.doc();
    await assistantMsgRef.set({
      role: 'assistant',
      text: output.reply,
      proposal: output.proposal ?? null,
      status: output.proposal ? 'pending' : null,
      transactionId: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      messageId: assistantMsgRef.id,
      reply: output.reply,
      proposal: output.proposal ?? null,
    };
  },
);
