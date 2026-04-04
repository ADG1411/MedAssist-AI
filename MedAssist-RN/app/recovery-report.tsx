import React from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable,
} from 'react-native';
import { useRouter } from 'expo-router';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import Svg, { Path, Circle as SvgCircle } from 'react-native-svg';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const WEEKLY_DATA = [62, 65, 64, 68, 70, 72, 75];
const DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const METRICS = [
  { label: 'Recovery Score', value: '75', delta: '+5', color: '#10B981', icon: 'trending-up' },
  { label: 'Pain Level', value: '3/10', delta: '-2', color: '#EF4444', icon: 'trending-down' },
  { label: 'Sleep Quality', value: '7.2h', delta: '+0.8h', color: '#8B5CF6', icon: 'trending-up' },
  { label: 'Medication Adherence', value: '92%', delta: '+8%', color: '#3B82F6', icon: 'trending-up' },
];

function WeeklyChart({ data, width: w, height: h, color }: { data: number[]; width: number; height: number; color: string }) {
  const min = Math.min(...data) - 5;
  const max = Math.max(...data) + 5;
  const range = max - min || 1;
  const points = data.map((v, i) => ({
    x: (i / (data.length - 1)) * w,
    y: h - ((v - min) / range) * h * 0.8 - h * 0.1,
  }));

  let d = `M ${points[0].x},${points[0].y}`;
  for (let i = 1; i < points.length; i++) {
    const cp1x = points[i - 1].x + (points[i].x - points[i - 1].x) * 0.4;
    const cp2x = points[i].x - (points[i].x - points[i - 1].x) * 0.4;
    d += ` C ${cp1x},${points[i - 1].y} ${cp2x},${points[i].y} ${points[i].x},${points[i].y}`;
  }

  const last = points[points.length - 1];

  return (
    <Svg width={w} height={h}>
      <Path d={d} fill="none" stroke={color} strokeWidth={2.5} strokeLinecap="round" />
      <SvgCircle cx={last.x} cy={last.y} r={5} fill={color} />
      <SvgCircle cx={last.x} cy={last.y} r={9} fill={color} opacity={0.2} />
    </Svg>
  );
}

export default function RecoveryReportScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Recovery Report</Text>
        </View>

        {/* Metrics grid */}
        <View style={styles.metricsGrid}>
          {METRICS.map((m, i) => (
            <GlassCard key={i} radius={16} blur={14} padding={14} style={styles.metricCard}>
              <View style={[styles.metricIcon, { backgroundColor: `${m.color}14` }]}>
                <Ionicons name={m.icon as any} size={16} color={m.color} />
              </View>
              <Text style={[styles.metricValue, { color: colors.textPrimary }]}>{m.value}</Text>
              <Text style={[styles.metricLabel, { color: colors.textSecondary }]}>{m.label}</Text>
              <View style={[styles.deltaBadge, { backgroundColor: m.delta.startsWith('+') ? 'rgba(16,185,129,0.10)' : 'rgba(239,68,68,0.10)' }]}>
                <Text style={[styles.deltaText, { color: m.delta.startsWith('+') || m.delta.startsWith('-') && m.icon === 'trending-down' ? '#10B981' : '#EF4444' }]}>
                  {m.delta}
                </Text>
              </View>
            </GlassCard>
          ))}
        </View>

        {/* Weekly trend */}
        <GlassCard radius={24} blur={20} padding={18} style={{ marginTop: 14 }}>
          <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>Weekly Recovery Trend</Text>
          <View style={styles.chartWrap}>
            <WeeklyChart data={WEEKLY_DATA} width={300} height={100} color="#10B981" />
          </View>
          <View style={styles.daysRow}>
            {DAYS.map((d, i) => (
              <Text key={i} style={[styles.dayLabel, { color: colors.textSecondary }]}>{d}</Text>
            ))}
          </View>
        </GlassCard>

        {/* AI Summary */}
        <GlassCard radius={20} blur={16} padding={16} style={{ marginTop: 14 }}>
          <View style={styles.aiHeader}>
            <View style={[styles.aiBadge, { backgroundColor: 'rgba(99,102,241,0.10)' }]}>
              <Ionicons name="sparkles" size={12} color="#6366F1" />
              <Text style={styles.aiBadgeText}>AI Analysis</Text>
            </View>
          </View>
          <Text style={[styles.aiText, { color: colors.textPrimary }]}>
            Your recovery is progressing well with a 13-point improvement this week. Sleep quality is the biggest positive contributor. 
            Continue your medication schedule and aim for 8+ hours of sleep for optimal recovery velocity.
          </Text>
          <View style={styles.aiActions}>
            <Pressable onPress={() => router.push('/monitoring')} style={[styles.aiActionBtn, { backgroundColor: 'rgba(59,130,246,0.08)' }]}>
              <Ionicons name="pulse" size={14} color="#3B82F6" />
              <Text style={styles.aiActionText}>Log Today</Text>
            </Pressable>
            <Pressable onPress={() => router.push('/daily-followup')} style={[styles.aiActionBtn, { backgroundColor: 'rgba(16,185,129,0.08)' }]}>
              <Ionicons name="chatbubble-ellipses" size={14} color="#10B981" />
              <Text style={[styles.aiActionText, { color: '#10B981' }]}>Daily Check-in</Text>
            </Pressable>
          </View>
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
  metricsGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  metricCard: { width: '47%' },
  metricIcon: { width: 32, height: 32, borderRadius: 10, alignItems: 'center', justifyContent: 'center', marginBottom: 8 },
  metricValue: { fontSize: 22, fontWeight: '800', letterSpacing: -0.5 },
  metricLabel: { fontSize: 11, fontWeight: '500', marginTop: 2 },
  deltaBadge: { paddingHorizontal: 6, paddingVertical: 2, borderRadius: 6, alignSelf: 'flex-start', marginTop: 6 },
  deltaText: { fontSize: 10, fontWeight: '700' },
  sectionTitle: { fontSize: 15, fontWeight: '700', marginBottom: 12 },
  chartWrap: { alignItems: 'center' },
  daysRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 8, paddingHorizontal: 4 },
  dayLabel: { fontSize: 10, fontWeight: '600' },
  aiHeader: { marginBottom: 10 },
  aiBadge: { flexDirection: 'row', alignItems: 'center', gap: 4, paddingHorizontal: 8, paddingVertical: 4, borderRadius: 8, alignSelf: 'flex-start' },
  aiBadgeText: { fontSize: 11, fontWeight: '700', color: '#6366F1' },
  aiText: { fontSize: 13, lineHeight: 19 },
  aiActions: { flexDirection: 'row', gap: 8, marginTop: 12 },
  aiActionBtn: { flexDirection: 'row', alignItems: 'center', gap: 6, paddingHorizontal: 12, paddingVertical: 8, borderRadius: 10 },
  aiActionText: { fontSize: 12, fontWeight: '600', color: '#3B82F6' },
});
