import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable, TextInput, ActivityIndicator,
} from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const FOLLOW_UP_QUESTIONS = [
  'How long have you been experiencing these symptoms?',
  'Have you noticed any patterns or triggers?',
  'Are symptoms worse at a specific time of day?',
  'Any recent changes in diet or medication?',
  'Rate your stress level on a scale of 1-10',
];

export default function DeepCheckScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const [currentQ, setCurrentQ] = useState(0);
  const [answers, setAnswers] = useState<string[]>([]);
  const [currentAnswer, setCurrentAnswer] = useState('');
  const [analyzing, setAnalyzing] = useState(false);

  const handleNext = () => {
    if (!currentAnswer.trim()) return;
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    const newAnswers = [...answers, currentAnswer.trim()];
    setAnswers(newAnswers);
    setCurrentAnswer('');

    if (currentQ < FOLLOW_UP_QUESTIONS.length - 1) {
      setCurrentQ(currentQ + 1);
    } else {
      setAnalyzing(true);
      setTimeout(() => {
        router.push('/ai-result');
      }, 2500);
    }
  };

  const progress = (currentQ + 1) / FOLLOW_UP_QUESTIONS.length;

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Deep Analysis</Text>
        </View>
        <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
          Answer follow-up questions for a more accurate diagnosis
        </Text>

        {/* Progress */}
        <View style={styles.progressContainer}>
          <View style={[styles.progressBg, { backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)' }]}>
            <View style={[styles.progressFill, { width: `${progress * 100}%` }]} />
          </View>
          <Text style={[styles.progressText, { color: colors.textSecondary }]}>
            {currentQ + 1} of {FOLLOW_UP_QUESTIONS.length}
          </Text>
        </View>

        {analyzing ? (
          <GlassCard radius={24} blur={20} padding={40} style={{ marginTop: 20 }}>
            <View style={styles.analyzingWrap}>
              <ActivityIndicator size="large" color="#3B82F6" />
              <Text style={[styles.analyzingText, { color: colors.textPrimary }]}>
                Deep Analysis in Progress...
              </Text>
              <Text style={[styles.analyzingSubText, { color: colors.textSecondary }]}>
                Cross-referencing symptoms, medical history, and clinical guidelines
              </Text>
            </View>
          </GlassCard>
        ) : (
          <>
            {/* Previous answers */}
            {answers.map((a, i) => (
              <GlassCard key={i} radius={16} blur={12} padding={14} style={{ marginBottom: 8 }}>
                <Text style={[styles.prevQ, { color: colors.textSecondary }]}>
                  {FOLLOW_UP_QUESTIONS[i]}
                </Text>
                <Text style={[styles.prevA, { color: colors.textPrimary }]}>{a}</Text>
              </GlassCard>
            ))}

            {/* Current question */}
            <GlassCard radius={24} blur={20} padding={20} style={{ marginTop: 8 }}>
              <View style={[styles.qBadge, { backgroundColor: 'rgba(59,130,246,0.10)' }]}>
                <Ionicons name="help-circle" size={14} color="#3B82F6" />
                <Text style={styles.qBadgeText}>Question {currentQ + 1}</Text>
              </View>
              <Text style={[styles.questionText, { color: colors.textPrimary }]}>
                {FOLLOW_UP_QUESTIONS[currentQ]}
              </Text>
              <View style={[styles.inputWrap, {
                backgroundColor: isDark ? 'rgba(255,255,255,0.05)' : '#F1F5F9',
                borderColor: isDark ? 'rgba(255,255,255,0.08)' : '#E2E8F0',
              }]}>
                <TextInput
                  style={[styles.input, { color: colors.textPrimary }]}
                  placeholder="Type your answer..."
                  placeholderTextColor={colors.textSecondary}
                  value={currentAnswer}
                  onChangeText={setCurrentAnswer}
                  multiline
                />
              </View>
              <Pressable onPress={handleNext} disabled={!currentAnswer.trim()}>
                <LinearGradient
                  colors={['#3B82F6', '#2563EB']}
                  style={[styles.nextBtn, { opacity: currentAnswer.trim() ? 1 : 0.4 }]}
                >
                  <Text style={styles.nextBtnText}>
                    {currentQ === FOLLOW_UP_QUESTIONS.length - 1 ? 'Analyze' : 'Next'}
                  </Text>
                  <Ionicons name="arrow-forward" size={16} color="#FFF" />
                </LinearGradient>
              </Pressable>
            </GlassCard>
          </>
        )}

        <View style={{ height: 40 }} />
      </ScrollView>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingHorizontal: 16, paddingTop: 60 },
  headerRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginBottom: 4 },
  backBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 22, fontWeight: '800' },
  subtitle: { fontSize: 13, marginBottom: 16 },
  progressContainer: { flexDirection: 'row', alignItems: 'center', gap: 10, marginBottom: 16 },
  progressBg: { flex: 1, height: 6, borderRadius: 3, overflow: 'hidden' },
  progressFill: { height: 6, borderRadius: 3, backgroundColor: '#3B82F6' },
  progressText: { fontSize: 11, fontWeight: '600' },
  prevQ: { fontSize: 11, fontWeight: '500', marginBottom: 4 },
  prevA: { fontSize: 13, fontWeight: '600' },
  qBadge: { flexDirection: 'row', alignItems: 'center', gap: 4, paddingHorizontal: 8, paddingVertical: 4, borderRadius: 8, alignSelf: 'flex-start', marginBottom: 12 },
  qBadgeText: { fontSize: 11, fontWeight: '700', color: '#3B82F6' },
  questionText: { fontSize: 17, fontWeight: '700', marginBottom: 16, lineHeight: 24 },
  inputWrap: { borderRadius: 14, borderWidth: 0.6, padding: 14, marginBottom: 16, minHeight: 80 },
  input: { fontSize: 14, lineHeight: 20 },
  nextBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    height: 48, borderRadius: 14,
  },
  nextBtnText: { fontSize: 15, fontWeight: '700', color: '#FFF' },
  analyzingWrap: { alignItems: 'center', gap: 16 },
  analyzingText: { fontSize: 18, fontWeight: '700' },
  analyzingSubText: { fontSize: 13, textAlign: 'center', lineHeight: 19 },
});
