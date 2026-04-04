import { useState, useRef } from 'react';
import {
  View, Text, StyleSheet, TextInput, TouchableOpacity, FlatList, KeyboardAvoidingView, Platform, ActivityIndicator
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import type { ChatMessage } from '../../types/chat';

const NIM_API_KEY = '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';
const MODEL = 'stepfun-ai/step-3.5-flash';

const SYSTEM_PROMPT = `You are MedAssist AI.

STRICT RULES:
- Only answer medical/health questions
- If question is not medical → REFUSE

Refusal format:
"I'm a medical assistant. I can only answer health-related questions."

DO NOT answer anything outside healthcare.

You are talking to a DOCTOR (not a patient). Use professional medical language.
For clinical questions, provide evidence-based differentials with probability estimates.
For prescriptions, flag drug interactions and contraindications.
Structure complex answers with headers and bullet points.
Be concise but thorough.`;

const SUGGESTIONS = [
  'What are the top differential diagnoses for chest pain?',
  'Review drug interactions for Aspirin + Metformin',
  'Summarize my patient load today',
  'Generate a follow-up plan for diabetic patient',
];

export default function AIScreen() {
  const [messages, setMessages] = useState<ChatMessage[]>([
    { id: '0', role: 'assistant', content: '👋 Hello Doctor! I\'m your AI Co-Pilot.\n\nI can help with:\n• Clinical decision support\n• Drug interaction checks\n• Differential diagnoses\n• Patient data analysis\n\nHow can I assist you today?', timestamp: new Date().toISOString() },
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const flatListRef = useRef<FlatList>(null);

  const performFetch = async (messagesPayload: any[], temp: number, tokens: number) => {
    const endpoints = Platform.OS === 'web' 
      ? [
          'https://cors-anywhere.herokuapp.com/https://integrate.api.nvidia.com/v1/chat/completions',
          'https://integrate.api.nvidia.com/v1/chat/completions'
        ]
      : ['https://integrate.api.nvidia.com/v1/chat/completions'];

    let response;
    for (const endpoint of endpoints) {
      try {
        response = await fetch(endpoint, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${NIM_API_KEY}` },
          body: JSON.stringify({
            model: MODEL,
            messages: messagesPayload,
            temperature: temp,
            max_tokens: tokens,
          }),
        });
        if (response.ok) break;
      } catch (e) {
        // keep trying
      }
    }
    
    if (!response || !response.ok) throw new Error(`Network failed or blocked by CORS`);
    const data = await response.json();
    return data.choices?.[0]?.message?.content || '';
  };

  const sendMessage = async (text?: string) => {
    const msg = text || input.trim();
    if (!msg || loading) return;

    if (msg.length < 5) {
      const errMsg: ChatMessage = { id: Date.now().toString(), role: 'assistant', content: 'Please ask a complete medical question.', timestamp: new Date().toISOString() };
      setMessages(prev => [...prev, { id: Date.now().toString() + 'u', role: 'user', content: msg, timestamp: new Date().toISOString() }, errMsg]);
      setInput('');
      return;
    }

    const userMsg: ChatMessage = { id: Date.now().toString(), role: 'user', content: msg, timestamp: new Date().toISOString() };
    setMessages(prev => [...prev, userMsg]);
    setInput('');
    setLoading(true);

    try {
      // 🚀 STEP 1: AI CLASSIFIER (STRICT)
      const classifierPrompt = `You are a strict classifier. ONLY answer: YES → if question is medical/health related. NO → if not. No explanation.`;
      const classifierMessages = [
        { role: 'system', content: classifierPrompt },
        { role: 'user', content: msg }
      ];
      
      const classifierRaw = await performFetch(classifierMessages, 0.1, 10);
      const isMedical = classifierRaw.trim().toUpperCase().replace(/[^A-Z]/g, ''); // Extract only letters

      if (!isMedical.includes("YES") && !msg.toLowerCase().includes('summarize')) {
        const blockMsg: ChatMessage = { id: Date.now().toString() + 'a', role: 'assistant', content: "⚠ I am a medical AI. Please ask health-related questions only.", timestamp: new Date().toISOString() };
        setMessages(prev => [...prev, blockMsg]);
        setLoading(false);
        return;
      }

      // ── Proceed to Step 2 ──

      // 1. Gather Supabase Context
      let dbContext = '';
      try {
        const { supabase } = require('../../services/supabase');
        const { data: { user } } = await supabase.auth.getUser();
        if (user) {
          const [{ data: patients }, { data: bookings }] = await Promise.all([
            supabase.from('doctor_patient_access').select('patient_id, is_active').eq('doctor_id', user.id).eq('is_active', true),
            supabase.from('bookings').select('id, slot_time, status').eq('doctor_id', user.id)
          ]);
          dbContext = `Context Update: You have ${patients?.length || 0} active patient accesses right now. You have ${bookings?.length || 0} total bookings registered. Use this to summarize patient loads.`;
        }
      } catch (dbErr) {
        console.warn("Context fetch failed", dbErr);
      }

      // Filter out the initial welcome message
      const historyMsgs = messages
        .filter((m) => m.id !== '0')
        .slice(-6)
        .map((m) => ({ role: m.role, content: m.content }));

      // 🚀 STEP 2: MAIN AI WITH HARD RESTRICTION
      const finalMessages = [
        { role: 'system', content: SYSTEM_PROMPT + '\n' + dbContext },
        ...historyMsgs,
        { role: 'user', content: msg }
      ];

      const content = await performFetch(finalMessages, 0.7, 1500) || 'I couldn\'t generate a response. Please try again.';

      const assistantMsg: ChatMessage = { id: (Date.now() + 1).toString(), role: 'assistant', content, timestamp: new Date().toISOString() };
      setMessages(prev => [...prev, assistantMsg]);
    } catch (e: any) {
      const errMsg: ChatMessage = {
        id: (Date.now() + 1).toString(), role: 'assistant',
        content: `⚠️ AI service error: ${e.message}. Please try again.`,
        timestamp: new Date().toISOString()
      };
      setMessages(prev => [...prev, errMsg]);
    } finally {
      setLoading(false);
    }
  };

  const renderMessage = ({ item }: { item: ChatMessage }) => {
    const isUser = item.role === 'user';
    return (
      <View style={[styles.msgRow, isUser && styles.msgRowUser]}>
        {!isUser && (
          <View style={styles.aiAvatar}>
            <Ionicons name="sparkles" size={16} color={Colors.brandBlue} />
          </View>
        )}
        <View style={[styles.msgBubble, isUser ? styles.userBubble : styles.aiBubble]}>
          <Text style={[styles.msgText, isUser && styles.userMsgText]}>{item.content}</Text>
        </View>
      </View>
    );
  };

  return (
    <KeyboardAvoidingView style={styles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined} keyboardVerticalOffset={90}>
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerIcon}>
          <Ionicons name="sparkles" size={20} color={Colors.brandBlue} />
        </View>
        <View>
          <Text style={styles.headerTitle}>AI Co-Pilot</Text>
          <Text style={styles.headerStatus}>
            {loading ? '● Thinking...' : '● Online'}
          </Text>
        </View>
      </View>

      {/* Messages */}
      <FlatList
        ref={flatListRef}
        data={messages}
        keyExtractor={m => m.id}
        renderItem={renderMessage}
        contentContainerStyle={styles.messageList}
        onContentSizeChange={() => flatListRef.current?.scrollToEnd({ animated: true })}
        ListFooterComponent={loading ? (
          <View style={styles.typingRow}>
            <View style={styles.aiAvatar}><Ionicons name="sparkles" size={14} color={Colors.brandBlue} /></View>
            <View style={styles.typingBubble}>
              <ActivityIndicator size="small" color={Colors.brandBlue} />
              <Text style={styles.typingText}>Analyzing...</Text>
            </View>
          </View>
        ) : null}
      />

      {/* Suggestions */}
      {messages.length <= 1 && (
        <View style={styles.suggestionsBox}>
          {SUGGESTIONS.map((s, i) => (
            <TouchableOpacity key={i} style={styles.suggestionChip} onPress={() => sendMessage(s)}>
              <Text style={styles.suggestionText} numberOfLines={1}>{s}</Text>
            </TouchableOpacity>
          ))}
        </View>
      )}

      {/* Input */}
      <View style={styles.inputBar}>
        <TextInput
          style={styles.input}
          placeholder="Ask your AI assistant..."
          placeholderTextColor={Colors.slate400}
          value={input}
          onChangeText={setInput}
          multiline
          maxLength={2000}
        />
        <TouchableOpacity style={[styles.sendBtn, (!input.trim() || loading) && styles.sendBtnDisabled]}
          onPress={() => sendMessage()} disabled={!input.trim() || loading}>
          <Ionicons name="send" size={18} color="#FFF" />
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.background },
  header: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingTop: 56, paddingBottom: 12, backgroundColor: Colors.surface, borderBottomWidth: 1, borderBottomColor: Colors.border },
  headerIcon: { width: 40, height: 40, borderRadius: 12, backgroundColor: Colors.blueBg, justifyContent: 'center', alignItems: 'center' },
  headerTitle: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary },
  headerStatus: { fontSize: FontSize.sm, color: Colors.emerald, fontWeight: '600' },
  messageList: { padding: 16, paddingBottom: 8 },
  msgRow: { flexDirection: 'row', alignItems: 'flex-end', gap: 8, marginBottom: 12 },
  msgRowUser: { flexDirection: 'row-reverse' },
  aiAvatar: { width: 28, height: 28, borderRadius: 14, backgroundColor: Colors.blueBg, justifyContent: 'center', alignItems: 'center' },
  msgBubble: { maxWidth: '78%', paddingHorizontal: 16, paddingVertical: 12, borderRadius: 20 },
  userBubble: { backgroundColor: Colors.brandBlue, borderBottomRightRadius: 6 },
  aiBubble: { backgroundColor: Colors.surface, borderBottomLeftRadius: 6, borderWidth: 1, borderColor: Colors.border },
  msgText: { fontSize: FontSize.md, color: Colors.textPrimary, lineHeight: 22 },
  userMsgText: { color: '#FFF' },
  typingRow: { flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 12 },
  typingBubble: { flexDirection: 'row', alignItems: 'center', gap: 8, backgroundColor: Colors.surface, paddingHorizontal: 16, paddingVertical: 10, borderRadius: 16, borderWidth: 1, borderColor: Colors.border },
  typingText: { fontSize: FontSize.sm, color: Colors.textSecondary, fontWeight: '600' },
  suggestionsBox: { paddingHorizontal: 16, paddingBottom: 8, gap: 8 },
  suggestionChip: { backgroundColor: Colors.surface, paddingHorizontal: 14, paddingVertical: 10, borderRadius: BorderRadius.md, borderWidth: 1, borderColor: Colors.blueLight },
  suggestionText: { fontSize: FontSize.sm, color: Colors.brandBlue, fontWeight: '600' },
  inputBar: { flexDirection: 'row', alignItems: 'flex-end', gap: 10, paddingHorizontal: 16, paddingVertical: 12, backgroundColor: Colors.surface, borderTopWidth: 1, borderTopColor: Colors.border },
  input: { flex: 1, backgroundColor: Colors.slate50, borderRadius: BorderRadius.xl, paddingHorizontal: 16, paddingVertical: 12, fontSize: FontSize.md, color: Colors.textPrimary, maxHeight: 100, borderWidth: 1, borderColor: Colors.border },
  sendBtn: { width: 44, height: 44, borderRadius: 22, backgroundColor: Colors.brandBlue, justifyContent: 'center', alignItems: 'center' },
  sendBtnDisabled: { opacity: 0.4 },
});
