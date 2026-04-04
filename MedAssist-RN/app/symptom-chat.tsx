import React, { useState, useRef, useCallback } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TextInput, Pressable, KeyboardAvoidingView, Platform, ActivityIndicator, Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import { BlurView } from 'expo-blur';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';
import { invokeEdgeFunction } from '../src/core/services/edgeFunctionService';

interface Message {
  id: string;
  role: 'user' | 'ai';
  text: string;
  timestamp: string;
  emergency?: boolean;
}

export default function SymptomChatScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const scrollRef = useRef<ScrollView>(null);

  const [messages, setMessages] = useState<Message[]>([
    { id: 'welcome', role: 'ai', text: 'Hello! I\'m your AI health assistant. Please describe your symptoms in detail and I\'ll provide a clinical analysis.', timestamp: 'Just now' },
  ]);
  const [input, setInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const lastSendRef = useRef<number>(0);

  // Health-topic keywords
  const HEALTH_KEYWORDS = new Set([
    'pain','ache','hurt','sore','burning','sting','throb','cramp',
    'nausea','vomit','dizzy','dizziness','faint','fatigue','tired',
    'weak','fever','cough','cold','flu','sneeze','congestion',
    'headache','migraine','swelling','swollen','rash','itch','itchy',
    'bleed','bleeding','blood','bruise','numb','numbness','tingle',
    'stiff','stiffness','spasm','twitch','breathless','wheezing',
    'chest','throat','stomach','abdomen','back','neck','shoulder',
    'knee','ankle','wrist','hip','leg','arm','head','eye','ear',
    'nose','mouth','skin','muscle','joint','bone','spine',
    'diabetes','asthma','allergy','allergic','infection','inflammation',
    'arthritis','hypertension','cholesterol','thyroid','anemia',
    'insomnia','anxiety','depression','stress','panic',
    'medicine','medication','drug','tablet','pill','dose','dosage',
    'prescription','doctor','hospital','clinic','treatment','therapy',
    'surgery','diagnosis','symptom','symptoms','condition','disease',
    'illness','health','medical','test','scan','xray','mri',
    'bp','pulse','oxygen','spo2','temperature','weight','bmi',
    'sleep','sleeping','eat','eating','drink','drinking','walk',
    'walking','exercise','breathing','swallow','urinate','urine',
    'bowel','stool','diarrhea','constipation','vomiting','coughing',
    'worse','better','severe','mild','moderate','sharp','dull',
    'chronic','acute','sudden','constant','intermittent','occasional',
    'intense','unbearable','improving','worsening','spreading',
    'yes','no','yeah','nah','ok','okay','thanks','thank',
    'since','ago','days','weeks','hours','morning','night',
    'left','right','both','sometimes','always','never','often',
  ]);

  // Off-topic patterns
  const OFF_TOPIC_PATTERNS = [
    /\b(capital|president|prime\s*minister|population|country|city|state)\b/i,
    /\b(who\s+(is|was|are)|what\s+(is|was|are)\s+(the|a)\s+(capital|largest|smallest|tallest|fastest))\b/i,
    /\b(math|calculate|solve|equation|formula|multiply|divide|add|subtract)\b/i,
    /\b(recipe|cook|movie|song|music|game|play|score|weather|news|joke|story|poem)\b/i,
    /\b(code|program|software|javascript|python|flutter|html|css|api)\b/i,
    /\b(buy|sell|price|stock|crypto|bitcoin|money|loan|bank|invest)\b/i,
    /\b(homework|essay|assignment|exam|school|college|university)\b/i,
    /\b(translate|meaning\s+of|definition\s+of|spell|grammar)\b/i,
    /\b(who\s+invented|who\s+discovered|when\s+was\s+\w+\s+(born|founded|built|created))\b/i,
    /\b(tell\s+me\s+about|explain|describe)\s+(?!.*?(pain|symptom|condition|disease|health|feel|hurt))/i,
  ];

  const validateInput = useCallback((text: string): string | null => {
    // Rate limit: 2s between sends
    if (Date.now() - lastSendRef.current < 2000) {
      return 'Please wait a moment before sending another message.';
    }
    // Too short
    if (text.length < 3) {
      return 'Please describe your symptoms in more detail.';
    }
    // Too long
    if (text.length > 2000) {
      return 'Message is too long. Please keep it under 2000 characters.';
    }
    // Mostly digits (>60%)
    const digitCount = (text.match(/\d/g) || []).length;
    if (digitCount > text.length * 0.6 && text.length > 3) {
      return 'That looks like random numbers. Please describe your symptoms.';
    }
    // Repeated char spam (4+ same char in a row)
    if (/(.)\1{3,}/.test(text)) {
      return 'Please type a valid health-related message.';
    }
    // Keyboard mash — no vowels in a long alpha string
    const alphaOnly = text.replace(/[^a-zA-Z]/g, '');
    if (alphaOnly.length >= 5) {
      const vowels = (alphaOnly.match(/[aeiouAEIOU]/g) || []).length;
      if (vowels === 0) {
        return "That doesn't look like a real message. Please describe your symptoms.";
      }
    }
    // Must have at least 2 alphabetic chars
    if ((text.match(/[a-zA-Z]/g) || []).length < 2) {
      return 'Please use words to describe what you\'re feeling.';
    }
    // Off-topic detection
    for (const pattern of OFF_TOPIC_PATTERNS) {
      if (pattern.test(text)) {
        return 'I can only help with health and medical questions. Please describe your symptoms.';
      }
    }
    // Health relevance check (for messages with 4+ words)
    const words = text.toLowerCase().split(/\s+/);
    if (words.length >= 4) {
      const hasHealthWord = words.some((w) => HEALTH_KEYWORDS.has(w.replace(/[^a-z]/g, '')));
      if (!hasHealthWord) {
        return "This doesn't seem health-related. Please describe your symptoms or medical concerns.";
      }
    }
    return null;
  }, []);

  const sendMessage = async () => {
    const text = input.trim();
    if (!text) return;

    const guardrailMsg = validateInput(text);
    if (guardrailMsg) {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
      Alert.alert('Invalid Input', guardrailMsg);
      return;
    }

    lastSendRef.current = Date.now();
    setInput('');
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);

    const userMsg: Message = { id: `u_${Date.now()}`, role: 'user', text, timestamp: 'Just now' };
    setMessages((prev) => [...prev, userMsg]);
    setIsTyping(true);

    setTimeout(() => scrollRef.current?.scrollToEnd({ animated: true }), 100);

    try {
      const contextPayload = [...messages, userMsg].map((m) => ({ role: m.role, content: m.text }));
      const data = await invokeEdgeFunction<any>({
        functionName: 'symptom-triage',
        body: { messages: contextPayload, patient_context: { severity: 5, body_region: 'general' } },
      });

      const aiMsg: Message = {
        id: `ai_${Date.now()}`,
        role: 'ai',
        text: data?.reply ?? data?.next_question ?? 'I need more details to provide an analysis.',
        timestamp: 'Just now',
        emergency: data?.emergency === true,
      };
      setMessages((prev) => [...prev, aiMsg]);
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
            <Text style={[styles.headerTitle, { color: colors.textPrimary }]}>AI Symptom Analysis</Text>
            <View style={styles.statusRow}>
              <View style={[styles.statusDot, { backgroundColor: isTyping ? '#F59E0B' : '#10B981' }]} />
              <Text style={[styles.statusText, { color: colors.textSecondary }]}>
                {isTyping ? 'Analyzing...' : 'Online'}
              </Text>
            </View>
          </View>
          <Pressable onPress={() => router.push('/ai-result')} style={styles.resultBtn}>
            <Ionicons name="document-text" size={18} color="#2A7FFF" />
          </Pressable>
        </BlurView>

        {/* Messages */}
        <ScrollView ref={scrollRef} contentContainerStyle={styles.messagesScroll} showsVerticalScrollIndicator={false}>
          {messages.map((msg) => (
            <View key={msg.id} style={[styles.msgRow, msg.role === 'user' && styles.msgRowUser]}>
              {msg.role === 'ai' && (
                <View style={[styles.aiAvatar, { backgroundColor: isDark ? 'rgba(59,130,246,0.15)' : '#EAF3FF' }]}>
                  <Ionicons name="medical" size={14} color="#3B82F6" />
                </View>
              )}
              <View style={[
                styles.bubble,
                msg.role === 'user' ? styles.userBubble : styles.aiBubble,
                msg.emergency && styles.emergencyBubble,
                { maxWidth: '78%' },
              ]}>
                {msg.emergency && (
                  <View style={styles.emergencyBadge}>
                    <Ionicons name="warning" size={12} color="#EF4444" />
                    <Text style={styles.emergencyText}>Emergency Detected</Text>
                  </View>
                )}
                <Text style={[styles.msgText, {
                  color: msg.role === 'user' ? '#FFF' : colors.textPrimary,
                }]}>{msg.text}</Text>
              </View>
            </View>
          ))}
          {isTyping && (
            <View style={styles.typingRow}>
              <View style={[styles.aiAvatar, { backgroundColor: isDark ? 'rgba(59,130,246,0.15)' : '#EAF3FF' }]}>
                <Ionicons name="medical" size={14} color="#3B82F6" />
              </View>
              <View style={[styles.bubble, styles.aiBubble]}>
                <ActivityIndicator size="small" color="#3B82F6" />
              </View>
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
              placeholder="Describe your symptoms..."
              placeholderTextColor={colors.textSecondary}
              value={input}
              onChangeText={setInput}
              multiline
              maxLength={2000}
            />
            <Pressable
              onPress={sendMessage}
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
  resultBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center', backgroundColor: 'rgba(42,127,255,0.08)' },
  messagesScroll: { paddingHorizontal: 16, paddingTop: 16 },
  msgRow: { flexDirection: 'row', alignItems: 'flex-end', marginBottom: 12, gap: 8 },
  msgRowUser: { flexDirection: 'row-reverse' },
  aiAvatar: { width: 28, height: 28, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  bubble: { paddingHorizontal: 14, paddingVertical: 10, borderRadius: 18 },
  userBubble: { backgroundColor: '#3B82F6', borderBottomRightRadius: 4 },
  aiBubble: { backgroundColor: 'rgba(0,0,0,0.04)', borderBottomLeftRadius: 4 },
  emergencyBubble: { borderWidth: 1, borderColor: 'rgba(239,68,68,0.40)' },
  emergencyBadge: { flexDirection: 'row', alignItems: 'center', gap: 4, marginBottom: 6 },
  emergencyText: { fontSize: 10, fontWeight: '800', color: '#EF4444' },
  msgText: { fontSize: 14, lineHeight: 20 },
  typingRow: { flexDirection: 'row', alignItems: 'flex-end', gap: 8, marginBottom: 12 },
  inputDock: { paddingHorizontal: 16, paddingVertical: 12, paddingBottom: 30, borderTopWidth: 0.5, borderTopColor: 'rgba(0,0,0,0.06)' },
  inputRow: {
    flexDirection: 'row', alignItems: 'flex-end',
    borderRadius: 22, borderWidth: 0.6, paddingHorizontal: 14, paddingVertical: 6,
  },
  input: { flex: 1, fontSize: 14, maxHeight: 100, paddingVertical: 8 },
  sendBtn: {
    width: 36, height: 36, borderRadius: 18, backgroundColor: '#3B82F6',
    alignItems: 'center', justifyContent: 'center', marginLeft: 8,
  },
});
