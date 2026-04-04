import React, { useState, useRef } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TextInput, Pressable, KeyboardAvoidingView, Platform, ActivityIndicator,
} from 'react-native';
import { useRouter } from 'expo-router';
import { BlurView } from 'expo-blur';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { useAppTheme } from '../src/core/theme/useTheme';
import { invokeEdgeFunction } from '../src/core/services/edgeFunctionService';

interface Message {
  id: string;
  role: 'user' | 'ai';
  text: string;
  timestamp: string;
  flags?: string[];
}

const QUICK_PROMPTS = [
  'What should I eat for dinner?',
  'Is my protein intake enough?',
  'Suggest a low-sodium meal',
  'Healthy snack ideas',
];

export default function NutritionAiScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const scrollRef = useRef<ScrollView>(null);

  const [messages, setMessages] = useState<Message[]>([
    { id: 'welcome', role: 'ai', text: 'Hi! I\'m Dr. NutriAssist, your AI nutrition coach. Ask me anything about your diet, meal plans, or nutrition goals! 🥗', timestamp: 'Just now' },
  ]);
  const [input, setInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);

  const sendMessage = async (text?: string) => {
    const msg = (text ?? input).trim();
    if (!msg) return;
    setInput('');
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);

    const userMsg: Message = { id: `u_${Date.now()}`, role: 'user', text: msg, timestamp: 'Just now' };
    setMessages((prev) => [...prev, userMsg]);
    setIsTyping(true);
    setTimeout(() => scrollRef.current?.scrollToEnd({ animated: true }), 100);

    try {
      const contextPayload = [...messages, userMsg].map((m) => ({ role: m.role, content: m.text }));
      const data = await invokeEdgeFunction<any>({
        functionName: 'nutrition-ai',
        body: {
          messages: contextPayload,
          patient_context: { chronic_conditions: [], allergies: [], calories: 1450, protein: 62, carbs: 180, fat: 48 },
        },
      });

      const replyText = data?.reply ?? 'I can help with that! Could you give me more details?';
      const dailyTip = data?.daily_tip;
      const fullText = dailyTip ? `${replyText}\n\n💡 Tip: ${dailyTip}` : replyText;

      setMessages((prev) => [...prev, {
        id: `ai_${Date.now()}`, role: 'ai', text: fullText, timestamp: 'Just now', flags: data?.flags,
      }]);
    } catch {
      setMessages((prev) => [...prev, {
        id: `err_${Date.now()}`, role: 'ai', text: 'Sorry, I couldn\'t process that. Please try again.', timestamp: 'Just now',
      }]);
    } finally {
      setIsTyping(false);
      setTimeout(() => scrollRef.current?.scrollToEnd({ animated: true }), 100);
    }
  };

  return (
    <AppBackground>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        {/* Header */}
        <BlurView intensity={20} tint={isDark ? 'dark' : 'light'} style={styles.header}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <View style={styles.headerCenter}>
            <Text style={[styles.headerTitle, { color: colors.textPrimary }]}>🥗 AI Nutrition Coach</Text>
            <View style={styles.statusRow}>
              <View style={[styles.statusDot, { backgroundColor: isTyping ? '#F59E0B' : '#10B981' }]} />
              <Text style={[styles.statusText, { color: colors.textSecondary }]}>
                {isTyping ? 'Thinking...' : 'Online'}
              </Text>
            </View>
          </View>
        </BlurView>

        {/* Messages */}
        <ScrollView ref={scrollRef} contentContainerStyle={styles.messagesScroll} showsVerticalScrollIndicator={false}>
          {messages.map((msg) => (
            <View key={msg.id} style={[styles.msgRow, msg.role === 'user' && styles.msgRowUser]}>
              {msg.role === 'ai' && (
                <View style={[styles.aiAvatar, { backgroundColor: 'rgba(16,185,129,0.12)' }]}>
                  <Text style={{ fontSize: 12 }}>🥗</Text>
                </View>
              )}
              <View style={[
                styles.bubble,
                msg.role === 'user' ? styles.userBubble : [styles.aiBubble, { backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(16,185,129,0.06)' }],
              ]}>
                <Text style={[styles.msgText, { color: msg.role === 'user' ? '#FFF' : colors.textPrimary }]}>{msg.text}</Text>
                {msg.flags && msg.flags.length > 0 && (
                  <View style={styles.flagsRow}>
                    {msg.flags.map((f, i) => (
                      <View key={i} style={styles.flagChip}>
                        <Text style={styles.flagText}>{f}</Text>
                      </View>
                    ))}
                  </View>
                )}
              </View>
            </View>
          ))}
          {isTyping && (
            <View style={styles.typingRow}>
              <View style={[styles.aiAvatar, { backgroundColor: 'rgba(16,185,129,0.12)' }]}>
                <Text style={{ fontSize: 12 }}>🥗</Text>
              </View>
              <View style={[styles.bubble, styles.aiBubble, { backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(16,185,129,0.06)' }]}>
                <ActivityIndicator size="small" color="#10B981" />
              </View>
            </View>
          )}

          {/* Quick prompts */}
          {messages.length <= 1 && (
            <View style={styles.promptsWrap}>
              {QUICK_PROMPTS.map((p, i) => (
                <Pressable key={i} onPress={() => sendMessage(p)} style={[styles.promptChip, {
                  backgroundColor: isDark ? 'rgba(16,185,129,0.10)' : 'rgba(16,185,129,0.08)',
                  borderColor: isDark ? 'rgba(16,185,129,0.20)' : 'rgba(16,185,129,0.15)',
                }]}>
                  <Text style={styles.promptText}>{p}</Text>
                </Pressable>
              ))}
            </View>
          )}
          <View style={{ height: 20 }} />
        </ScrollView>

        {/* Input dock */}
        <BlurView intensity={20} tint={isDark ? 'dark' : 'light'} style={styles.inputDock}>
          <View style={[styles.inputRow, {
            backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : '#F1F5F9',
            borderColor: isDark ? 'rgba(255,255,255,0.08)' : '#E2E8F0',
          }]}>
            <TextInput
              style={[styles.input, { color: colors.textPrimary }]}
              placeholder="Ask about nutrition..."
              placeholderTextColor={colors.textSecondary}
              value={input}
              onChangeText={setInput}
              multiline
              maxLength={2000}
            />
            <Pressable
              onPress={() => sendMessage()}
              disabled={!input.trim() || isTyping}
              style={[styles.sendBtn, { opacity: input.trim() && !isTyping ? 1 : 0.4 }]}
            >
              <Ionicons name="send" size={18} color="#FFF" />
            </Pressable>
          </View>
        </BlurView>
      </KeyboardAvoidingView>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16,
    paddingTop: 50, paddingBottom: 12, gap: 12,
    borderBottomWidth: 0.5, borderBottomColor: 'rgba(0,0,0,0.06)',
  },
  backBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  headerCenter: { flex: 1 },
  headerTitle: { fontSize: 16, fontWeight: '700' },
  statusRow: { flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 2 },
  statusDot: { width: 6, height: 6, borderRadius: 3 },
  statusText: { fontSize: 11, fontWeight: '500' },
  messagesScroll: { paddingHorizontal: 16, paddingTop: 16 },
  msgRow: { flexDirection: 'row', alignItems: 'flex-end', marginBottom: 12, gap: 8 },
  msgRowUser: { flexDirection: 'row-reverse' },
  aiAvatar: { width: 28, height: 28, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  bubble: { paddingHorizontal: 14, paddingVertical: 10, borderRadius: 18, maxWidth: '78%' },
  userBubble: { backgroundColor: '#10B981', borderBottomRightRadius: 4 },
  aiBubble: { borderBottomLeftRadius: 4 },
  msgText: { fontSize: 14, lineHeight: 20 },
  flagsRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 4, marginTop: 8 },
  flagChip: { backgroundColor: 'rgba(239,68,68,0.10)', paddingHorizontal: 6, paddingVertical: 2, borderRadius: 6 },
  flagText: { fontSize: 9, fontWeight: '700', color: '#EF4444' },
  typingRow: { flexDirection: 'row', alignItems: 'flex-end', gap: 8, marginBottom: 12 },
  promptsWrap: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 8 },
  promptChip: { paddingHorizontal: 14, paddingVertical: 8, borderRadius: 18, borderWidth: 0.5 },
  promptText: { fontSize: 12, fontWeight: '600', color: '#10B981' },
  inputDock: { paddingHorizontal: 16, paddingVertical: 12, paddingBottom: 30, borderTopWidth: 0.5, borderTopColor: 'rgba(0,0,0,0.06)' },
  inputRow: {
    flexDirection: 'row', alignItems: 'flex-end',
    borderRadius: 22, borderWidth: 0.6, paddingHorizontal: 14, paddingVertical: 6,
  },
  input: { flex: 1, fontSize: 14, maxHeight: 100, paddingVertical: 8 },
  sendBtn: {
    width: 36, height: 36, borderRadius: 18, backgroundColor: '#10B981',
    alignItems: 'center', justifyContent: 'center', marginLeft: 8,
  },
});
