import React from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable,
} from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import Svg, { Path, Circle as SvgCircle } from 'react-native-svg';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const MOCK_DETAIL: Record<string, {
  title: string; color: string; icon: string; value: string; unit: string;
  history: number[]; normal: string; description: string; tips: string[];
}> = {
  heart_rate: {
    title: 'Heart Rate', color: '#EF4444', icon: 'heart', value: '72', unit: 'bpm',
    history: [68, 72, 70, 75, 72, 71, 73, 72], normal: '60-100 bpm',
    description: 'Your resting heart rate is within the normal range and has been stable over the past week.',
    tips: ['Regular exercise helps lower resting heart rate', 'Avoid caffeine before bed', 'Practice deep breathing for stress management'],
  },
  steps: {
    title: 'Steps', color: '#3B82F6', icon: 'footsteps', value: '6,340', unit: 'steps',
    history: [4200, 5100, 6340, 5800, 6000, 6340, 7100, 6340], normal: '8,000-10,000 steps',
    description: 'You\'re at 79% of the recommended daily step goal. Try adding a 15-minute walk after lunch.',
    tips: ['Take stairs instead of elevator', 'Walk during phone calls', 'Set hourly movement reminders'],
  },
  sleep: {
    title: 'Sleep', color: '#8B5CF6', icon: 'moon', value: '6.2', unit: 'hours',
    history: [5.5, 6.0, 7.2, 6.2, 5.8, 6.2, 6.8, 6.2], normal: '7-9 hours',
    description: 'Your sleep is slightly below the recommended range. Sleep quality directly impacts recovery score.',
    tips: ['Maintain consistent sleep schedule', 'Avoid screens 1 hour before bed', 'Keep room cool and dark'],
  },
};

function TrendChart({ data, color, width: w, height: h }: { data: number[]; color: string; width: number; height: number }) {
  if (data.length < 2) return null;
  const min = Math.min(...data) - (Math.max(...data) - Math.min(...data)) * 0.2;
  const max = Math.max(...data) + (Math.max(...data) - Math.min(...data)) * 0.2;
  const range = max - min || 1;
  const pts = data.map((v, i) => ({
    x: (i / (data.length - 1)) * w,
    y: h - ((v - min) / range) * h * 0.8 - h * 0.1,
  }));

  let d = `M ${pts[0].x},${pts[0].y}`;
  for (let i = 1; i < pts.length; i++) {
    const cp1x = pts[i - 1].x + (pts[i].x - pts[i - 1].x) * 0.4;
    const cp2x = pts[i].x - (pts[i].x - pts[i - 1].x) * 0.4;
    d += ` C ${cp1x},${pts[i - 1].y} ${cp2x},${pts[i].y} ${pts[i].x},${pts[i].y}`;
  }
  const last = pts[pts.length - 1];

  return (
    <Svg width={w} height={h}>
      <Path d={d} fill="none" stroke={color} strokeWidth={2.5} strokeLinecap="round" />
      <SvgCircle cx={last.x} cy={last.y} r={5} fill={color} />
      <SvgCircle cx={last.x} cy={last.y} r={9} fill={color} opacity={0.2} />
    </Svg>
  );
}

export default function HealthDetailScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const { type } = useLocalSearchParams<{ type?: string }>();

  const detail = MOCK_DETAIL[type ?? 'heart_rate'] ?? MOCK_DETAIL.heart_rate;

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>{detail.title}</Text>
        </View>

        {/* Hero value */}
        <GlassCard radius={24} blur={20} padding={24}>
          <View style={styles.heroRow}>
            <View style={[styles.heroIcon, { backgroundColor: `${detail.color}14` }]}>
              <Ionicons name={detail.icon as any} size={32} color={detail.color} />
            </View>
            <View style={styles.heroInfo}>
              <Text style={[styles.heroValue, { color: colors.textPrimary }]}>{detail.value}</Text>
              <Text style={[styles.heroUnit, { color: colors.textSecondary }]}>{detail.unit}</Text>
            </View>
          </View>
          <View style={[styles.normalBadge, { backgroundColor: `${detail.color}10` }]}>
            <Ionicons name="information-circle" size={14} color={detail.color} />
            <Text style={[styles.normalText, { color: detail.color }]}>Normal range: {detail.normal}</Text>
          </View>
        </GlassCard>

        {/* Trend */}
        <GlassCard radius={20} blur={16} padding={18} style={{ marginTop: 14 }}>
          <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>7-Day Trend</Text>
          <View style={styles.chartWrap}>
            <TrendChart data={detail.history} color={detail.color} width={300} height={100} />
          </View>
          <View style={styles.daysRow}>
            {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Today'].map((d, i) => (
              <Text key={i} style={[styles.dayLabel, { color: colors.textSecondary }]}>{d}</Text>
            ))}
          </View>
        </GlassCard>

        {/* AI Analysis */}
        <GlassCard radius={20} blur={16} padding={16} style={{ marginTop: 14 }}>
          <View style={[styles.aiBadge, { backgroundColor: 'rgba(99,102,241,0.10)' }]}>
            <Ionicons name="sparkles" size={12} color="#6366F1" />
            <Text style={styles.aiBadgeText}>AI Analysis</Text>
          </View>
          <Text style={[styles.aiText, { color: colors.textPrimary }]}>{detail.description}</Text>
        </GlassCard>

        {/* Tips */}
        <GlassCard radius={20} blur={16} padding={16} style={{ marginTop: 14 }}>
          <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>
            <Ionicons name="bulb" size={16} color="#F59E0B" /> Tips
          </Text>
          {detail.tips.map((tip, i) => (
            <View key={i} style={styles.tipRow}>
              <View style={styles.tipDot} />
              <Text style={[styles.tipText, { color: colors.textPrimary }]}>{tip}</Text>
            </View>
          ))}
        </GlassCard>

        <View style={{ height: 40 }} />
      </ScrollView>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingHorizontal: 16, paddingTop: 60 },
  headerRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginBottom: 16 },
  backBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 22, fontWeight: '800' },
  heroRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 16 },
  heroIcon: { width: 64, height: 64, borderRadius: 20, alignItems: 'center', justifyContent: 'center' },
  heroInfo: { marginLeft: 16 },
  heroValue: { fontSize: 40, fontWeight: '800', letterSpacing: -2 },
  heroUnit: { fontSize: 14, fontWeight: '500', marginTop: -4 },
  normalBadge: { flexDirection: 'row', alignItems: 'center', gap: 6, paddingHorizontal: 10, paddingVertical: 6, borderRadius: 10 },
  normalText: { fontSize: 12, fontWeight: '600' },
  sectionTitle: { fontSize: 15, fontWeight: '700', marginBottom: 12 },
  chartWrap: { alignItems: 'center' },
  daysRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 8, paddingHorizontal: 4 },
  dayLabel: { fontSize: 9, fontWeight: '600' },
  aiBadge: { flexDirection: 'row', alignItems: 'center', gap: 4, paddingHorizontal: 8, paddingVertical: 4, borderRadius: 8, alignSelf: 'flex-start', marginBottom: 10 },
  aiBadgeText: { fontSize: 11, fontWeight: '700', color: '#6366F1' },
  aiText: { fontSize: 13, lineHeight: 19 },
  tipRow: { flexDirection: 'row', alignItems: 'flex-start', gap: 8, marginBottom: 8 },
  tipDot: { width: 6, height: 6, borderRadius: 3, backgroundColor: '#F59E0B', marginTop: 6 },
  tipText: { flex: 1, fontSize: 13, lineHeight: 19 },
});
