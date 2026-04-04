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

interface Message {
  id: string;
  role: 'user' | 'ai';
  text: string;
}

const INITIAL_MESSAGES: Message[] = [
  { id: 'w1', role: 'ai', text: "Good evening! Time for your daily check-in. How are you feeling today compared to yesterday?" },
];

const QUICK_REPLIES = [
  'Feeling better today',
  'About the same',
  'Feeling worse',
  'Pain has increased',
  'Slept well last night',
];

export default function DailyFollowupScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const scrollRef = useRef<ScrollView>(null);

  const [messages, setMessages] = useState<Message[]>(INITIAL_MESSAGES);
  const [input, setInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);

  const sendMessage = (text?: string) => {
    const msg = (text ?? input).trim();
    if (!msg) return;
    setInput('');
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);

    const userMsg: Message = { id: `u_${Date.now()}`, role: 'user', text: msg };
    setMessages((prev) => [...prev, userMsg]);
    setIsTyping(true);
    setTimeout(() => scrollRef.current?.scrollToEnd({ animated: true }), 100);

    // Simulate AI response
    setTimeout(() => {
      const replies = [
        "Thanks for sharing. That's noted in your recovery log. Your AI health score will be updated shortly.",
        "I've recorded this in your daily monitoring. Based on your trends, your recovery is progressing well. Keep up the good work!",
        "Got it. I recommend logging your hydration and pain levels in the monitoring section for a more complete picture. Would you like me to set a reminder?",
        "Thank you. Based on your response and recent vitals, everything looks stable. Remember to take your evening medication!",
      ];
      const reply = replies[Math.floor(Math.random() * replies.length)];
      setMessages((prev) => [...prev, { id: `ai_${Date.now()}`, role: 'ai', text: reply }]);
      setIsTyping(false);
      setTimeout(() => scrollRef.current?.scrollToEnd({ animated: true }), 100);
    }, 1500);
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
            <Text style={[styles.headerTitle, { color: colors.textPrimary }]}>Daily Check-in</Text>
            <View style={styles.statusRow}>
              <View style={[styles.statusDot, { backgroundColor: '#10B981' }]} />
              <Text style={[styles.statusText, { color: colors.textSecondary }]}>AI Recovery Assistant</Text>
            </View>
          </View>
        </BlurView>

        {/* Messages */}
        <ScrollView ref={scrollRef} contentContainerStyle={styles.messagesScroll} showsVerticalScrollIndicator={false}>
          {messages.map((msg) => (
            <View key={msg.id} style={[styles.msgRow, msg.role === 'user' && styles.msgRowUser]}>
              {msg.role === 'ai' && (
                <View style={[styles.aiAvatar, { backgroundColor: 'rgba(99,102,241,0.12)' }]}>
                  <Ionicons name="sparkles" size={14} color="#6366F1" />
                </View>
              )}
              <View style={[
                styles.bubble,
                msg.role === 'user' ? styles.userBubble : [styles.aiBubble, { backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(99,102,241,0.06)' }],
              ]}>
                <Text style={[styles.msgText, { color: msg.role === 'user' ? '#FFF' : colors.textPrimary }]}>{msg.text}</Text>
              </View>
            </View>
          ))}
          {isTyping && (
            <View style={styles.typingRow}>
              <View style={[styles.aiAvatar, { backgroundColor: 'rgba(99,102,241,0.12)' }]}>
                <Ionicons name="sparkles" size={14} color="#6366F1" />
              </View>
              <View style={[styles.bubble, styles.aiBubble, { backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(99,102,241,0.06)' }]}>
                <ActivityIndicator size="small" color="#6366F1" />
              </View>
            </View>
          )}

          {/* Quick replies */}
          {messages.length <= 2 && !isTyping && (
            <View style={styles.quickReplies}>
              {QUICK_REPLIES.map((q, i) => (
                <Pressable key={i} onPress={() => sendMessage(q)} style={[styles.quickChip, {
                  backgroundColor: isDark ? 'rgba(99,102,241,0.10)' : 'rgba(99,102,241,0.06)',
                  borderColor: isDark ? 'rgba(99,102,241,0.20)' : 'rgba(99,102,241,0.15)',
                }]}>
                  <Text style={styles.quickText}>{q}</Text>
                </Pressable>
              ))}
            </View>
          )}
          <View style={{ height: 20 }} />
        </ScrollView>

        {/* Input */}
        <BlurView intensity={20} tint={isDark ? 'dark' : 'light'} style={styles.inputDock}>
          <View style={[styles.inputRow, {
            backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : '#F1F5F9',
            borderColor: isDark ? 'rgba(255,255,255,0.08)' : '#E2E8F0',
          }]}>
            <TextInput
              style={[styles.input, { color: colors.textPrimary }]}
              placeholder="How are you feeling?"
              placeholderTextColor={colors.textSecondary}
              value={input}
              onChangeText={setInput}
              multiline
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
  userBubble: { backgroundColor: '#6366F1', borderBottomRightRadius: 4 },
  aiBubble: { borderBottomLeftRadius: 4 },
  msgText: { fontSize: 14, lineHeight: 20 },
  typingRow: { flexDirection: 'row', alignItems: 'flex-end', gap: 8, marginBottom: 12 },
  quickReplies: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 8 },
  quickChip: { paddingHorizontal: 14, paddingVertical: 8, borderRadius: 18, borderWidth: 0.5 },
  quickText: { fontSize: 12, fontWeight: '600', color: '#6366F1' },
  inputDock: { paddingHorizontal: 16, paddingVertical: 12, paddingBottom: 30, borderTopWidth: 0.5, borderTopColor: 'rgba(0,0,0,0.06)' },
  inputRow: {
    flexDirection: 'row', alignItems: 'flex-end',
    borderRadius: 22, borderWidth: 0.6, paddingHorizontal: 14, paddingVertical: 6,
  },
  input: { flex: 1, fontSize: 14, maxHeight: 100, paddingVertical: 8 },
  sendBtn: {
    width: 36, height: 36, borderRadius: 18, backgroundColor: '#6366F1',
    alignItems: 'center', justifyContent: 'center', marginLeft: 8,
  },
});
