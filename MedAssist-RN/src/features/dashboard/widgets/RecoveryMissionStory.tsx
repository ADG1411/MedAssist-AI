import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated, Easing } from 'react-native';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import Svg, { Path, Circle as SvgCircle } from 'react-native-svg';
import { GlassCard } from '../../../shared/components/GlassCard';
import { DashSectionLabel } from '../../../shared/components/DashSectionLabel';
import { useAppTheme } from '../../../core/theme/useTheme';

interface Props { data: Record<string, any> }

const MILESTONES = [
  { label: '50 pts', unlocked: true },
  { label: '60 pts', unlocked: true },
  { label: '70 pts', unlocked: true },
  { label: '80 pts', unlocked: false },
  { label: '90 pts', unlocked: false },
];

function SmoothedTrendChart({ data, color, width: w, height: h }: { data: number[]; color: string; width: number; height: number }) {
  if (data.length < 2) return null;
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
    const cp1y = points[i - 1].y;
    const cp2x = points[i].x - (points[i].x - points[i - 1].x) * 0.4;
    const cp2y = points[i].y;
    d += ` C ${cp1x},${cp1y} ${cp2x},${cp2y} ${points[i].x},${points[i].y}`;
  }

  const last = points[points.length - 1];

  return (
    <Svg width={w} height={h}>
      <Path d={d} fill="none" stroke={color} strokeWidth={2} strokeLinecap="round" />
      <SvgCircle cx={last.x} cy={last.y} r={4} fill={color} />
      <SvgCircle cx={last.x} cy={last.y} r={7} fill={color} opacity={0.2} />
    </Svg>
  );
}

export function RecoveryMissionStory({ data }: Props) {
  const { isDark, colors } = useAppTheme();
  const recoveryScore = (data?.recovery_score as number) ?? 70;
  const velocity = (data?.recovery_velocity as number[]) ?? [70, 72, 71, 75, 76];
  const trending = velocity.length >= 2 && velocity[velocity.length - 1] > velocity[velocity.length - 2];
  const nextMilestone = 80;
  const etaDays = Math.max(1, Math.round((nextMilestone - recoveryScore) / 2));

  // Fire animation for streak
  const fireScale = useRef(new Animated.Value(0.85)).current;
  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(fireScale, { toValue: 1.15, duration: 1200, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
        Animated.timing(fireScale, { toValue: 0.85, duration: 1200, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
      ])
    ).start();
  }, []);

  return (
    <View>
      <DashSectionLabel title="🏔️ Recovery Mission" subtitle="Your healing journey" />
      <View style={{ height: 10 }} />
      <GlassCard radius={24} blur={20} padding={18}>
        {/* Header row */}
        <View style={styles.headerRow}>
          <View style={styles.scoreCol}>
            <Text style={[styles.scoreNum, { color: colors.textPrimary }]}>{recoveryScore}</Text>
            <Text style={[styles.scoreSub, { color: colors.textSecondary }]}>Recovery Score</Text>
          </View>
          <View style={styles.badgeRow}>
            {/* Streak fire badge */}
            <Animated.View style={[styles.fireBadge, { transform: [{ scale: fireScale }] }]}>
              <Text style={styles.fireEmoji}>🔥</Text>
              <Text style={styles.fireText}>3 Day Streak</Text>
            </Animated.View>
            {/* Trend arrow */}
            <View style={[styles.trendBadge, { backgroundColor: trending ? 'rgba(16,185,129,0.12)' : 'rgba(239,68,68,0.12)' }]}>
              <Ionicons name={trending ? 'trending-up' : 'trending-down'} size={12} color={trending ? '#10B981' : '#EF4444'} />
            </View>
          </View>
        </View>

        {/* Trend chart */}
        <View style={styles.chartWrap}>
          <SmoothedTrendChart data={velocity} color="#10B981" width={280} height={70} />
        </View>

        {/* Milestones */}
        <View style={styles.milestoneRow}>
          {MILESTONES.map((m, i) => (
            <View key={i} style={[
              styles.milestoneChip,
              {
                backgroundColor: m.unlocked ? 'rgba(16,185,129,0.12)' : (isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.04)'),
                borderColor: m.unlocked ? 'rgba(16,185,129,0.30)' : 'transparent',
              },
            ]}>
              {m.unlocked && <Ionicons name="checkmark-circle" size={10} color="#10B981" />}
              <Text style={[styles.milestoneText, {
                color: m.unlocked ? '#10B981' : colors.textSecondary,
                fontWeight: m.unlocked ? '700' : '500',
              }]}>{m.label}</Text>
            </View>
          ))}
        </View>

        {/* Recovery ETA bar */}
        <View style={styles.etaContainer}>
          <View style={styles.etaHeader}>
            <Ionicons name="flag" size={14} color="#6366F1" />
            <Text style={[styles.etaLabel, { color: colors.textPrimary }]}>
              Next milestone: {nextMilestone} pts  ·  ETA ~{etaDays} days
            </Text>
            <View style={styles.rewardBadge}>
              <Text style={styles.rewardText}>🏆 Reward</Text>
            </View>
          </View>
          <View style={[styles.progressBg, { backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)' }]}>
            <View style={[styles.progressFill, { width: `${Math.min(100, (recoveryScore / nextMilestone) * 100)}%` }]} />
          </View>
        </View>
      </GlassCard>
    </View>
  );
}

const styles = StyleSheet.create({
  headerRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' },
  scoreCol: {},
  scoreNum: { fontSize: 36, fontWeight: '800', letterSpacing: -1.5 },
  scoreSub: { fontSize: 11, fontWeight: '500', marginTop: -2 },
  badgeRow: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  fireBadge: {
    flexDirection: 'row', alignItems: 'center', gap: 3,
    paddingHorizontal: 6, paddingVertical: 2, borderRadius: 8,
    backgroundColor: '#F59E0B',
    shadowColor: '#F59E0B', shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.35, shadowRadius: 8, elevation: 4,
  },
  fireEmoji: { fontSize: 10 },
  fireText: { fontSize: 9, color: '#FFF', fontWeight: '800' },
  trendBadge: { width: 26, height: 26, borderRadius: 13, alignItems: 'center', justifyContent: 'center' },
  chartWrap: { marginVertical: 14, alignItems: 'center' },
  milestoneRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 6, marginBottom: 14 },
  milestoneChip: {
    flexDirection: 'row', alignItems: 'center', gap: 3,
    paddingHorizontal: 8, paddingVertical: 4, borderRadius: 8, borderWidth: 0.5,
  },
  milestoneText: { fontSize: 10 },
  etaContainer: {
    padding: 10, borderRadius: 12,
    backgroundColor: 'rgba(99,102,241,0.08)',
    borderWidth: 0.5, borderColor: 'rgba(99,102,241,0.18)',
  },
  etaHeader: { flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 6 },
  etaLabel: { flex: 1, fontSize: 11, fontWeight: '600' },
  rewardBadge: { backgroundColor: 'rgba(16,185,129,0.12)', paddingHorizontal: 6, paddingVertical: 3, borderRadius: 6 },
  rewardText: { fontSize: 9, color: '#10B981', fontWeight: '700' },
  progressBg: { height: 4, borderRadius: 2, overflow: 'hidden' },
  progressFill: { height: 4, borderRadius: 2, backgroundColor: '#6366F1' },
});
