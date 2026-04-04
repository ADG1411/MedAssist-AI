import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated, Easing } from 'react-native';
import Svg, { Circle } from 'react-native-svg';
import { GlassCard } from '../../../shared/components/GlassCard';
import { DashSectionLabel } from '../../../shared/components/DashSectionLabel';
import { useAppTheme } from '../../../core/theme/useTheme';

interface Props { data: Record<string, any> }

const DELTA_CHIPS = [
  { label: '+6 Hydration', color: '#06B6D4' },
  { label: '+3 Sleep', color: '#8B5CF6' },
  { label: '-2 No Log', color: '#EF4444' },
];

const FACTOR_PILLS = [
  { label: 'Hydration', pct: 28, color: '#06B6D4' },
  { label: 'Medication', pct: 25, color: '#10B981' },
  { label: 'Sleep', pct: 22, color: '#8B5CF6' },
  { label: 'Nutrition', pct: 15, color: '#F59E0B' },
  { label: 'Activity', pct: 10, color: '#3B82F6' },
];

export function PremiumHealthCommandCard({ data }: Props) {
  const { isDark, colors } = useAppTheme();
  const score = (data?.health_score as number) ?? 72;
  const glow = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(glow, { toValue: 1, duration: 2000, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
        Animated.timing(glow, { toValue: 0, duration: 2000, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
      ])
    ).start();
  }, []);

  const glowOpacity = glow.interpolate({ inputRange: [0, 1], outputRange: [0.15, 0.35] });
  const glowScale = glow.interpolate({ inputRange: [0, 1], outputRange: [0.9, 1.1] });

  const scoreColor = score >= 80 ? '#10B981' : score >= 60 ? '#F59E0B' : '#EF4444';
  const circumference = 2 * Math.PI * 52;
  const strokeDashoffset = circumference * (1 - score / 100);

  return (
    <View>
      <DashSectionLabel title="🏥 Health Command" subtitle="Your AI health score" />
      <View style={{ height: 10 }} />
      <GlassCard radius={24} blur={20} padding={18}>
        <View style={styles.topRow}>
          {/* Score Ring */}
          <View style={styles.ringContainer}>
            {/* Radial glow */}
            <Animated.View style={[styles.radialGlow, { backgroundColor: scoreColor, opacity: glowOpacity, transform: [{ scale: glowScale }] }]} />
            <Svg width={120} height={120} viewBox="0 0 120 120">
              <Circle
                cx={60} cy={60} r={52}
                stroke={isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.06)'}
                strokeWidth={8} fill="none"
              />
              <Circle
                cx={60} cy={60} r={52}
                stroke={scoreColor}
                strokeWidth={8} fill="none"
                strokeLinecap="round"
                strokeDasharray={`${circumference}`}
                strokeDashoffset={strokeDashoffset}
                rotation={-90} origin="60,60"
              />
            </Svg>
            <View style={styles.scoreCenter}>
              <Text style={[styles.scoreNum, { color: scoreColor }]}>{score}</Text>
              <Text style={[styles.scoreLabel, { color: colors.textSecondary }]}>/100</Text>
            </View>
          </View>

          {/* Right side */}
          <View style={styles.rightCol}>
            <Text style={[styles.statusLabel, { color: colors.textPrimary }]}>
              {score >= 80 ? 'Excellent' : score >= 60 ? 'Good' : 'Needs Attention'}
            </Text>
            {/* Confidence badge */}
            <View style={[styles.confBadge, { backgroundColor: `${scoreColor}18` }]}>
              <Text style={[styles.confText, { color: scoreColor }]}>
                AI Confidence: 82%
              </Text>
            </View>
            {/* Delta chips */}
            <View style={styles.deltaRow}>
              {DELTA_CHIPS.map((c, i) => (
                <View key={i} style={[styles.deltaChip, { backgroundColor: `${c.color}14`, borderColor: `${c.color}30` }]}>
                  <Text style={[styles.deltaText, { color: c.color }]}>{c.label}</Text>
                </View>
              ))}
            </View>
          </View>
        </View>

        {/* Factor pills */}
        <View style={styles.factorRow}>
          {FACTOR_PILLS.map((f, i) => (
            <View key={i} style={[styles.factorPill, { backgroundColor: `${f.color}10`, borderColor: `${f.color}22` }]}>
              <View style={[styles.factorDot, { backgroundColor: f.color }]} />
              <Text style={[styles.factorLabel, { color: colors.textPrimary }]}>{f.label}</Text>
              <Text style={[styles.factorPct, { color: f.color }]}>{f.pct}%</Text>
            </View>
          ))}
        </View>
      </GlassCard>
    </View>
  );
}

const styles = StyleSheet.create({
  topRow: { flexDirection: 'row', alignItems: 'center' },
  ringContainer: { width: 120, height: 120, alignItems: 'center', justifyContent: 'center' },
  radialGlow: {
    position: 'absolute', width: 100, height: 100, borderRadius: 50,
  },
  scoreCenter: {
    position: 'absolute', alignItems: 'center', justifyContent: 'center',
  },
  scoreNum: { fontSize: 32, fontWeight: '800', letterSpacing: -1.5 },
  scoreLabel: { fontSize: 12, marginTop: -2 },
  rightCol: { flex: 1, marginLeft: 16 },
  statusLabel: { fontSize: 18, fontWeight: '700', marginBottom: 6 },
  confBadge: { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 8, alignSelf: 'flex-start', marginBottom: 8 },
  confText: { fontSize: 10, fontWeight: '700' },
  deltaRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 4 },
  deltaChip: { paddingHorizontal: 6, paddingVertical: 2, borderRadius: 6, borderWidth: 0.5 },
  deltaText: { fontSize: 9, fontWeight: '700' },
  factorRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 6, marginTop: 14 },
  factorPill: {
    flexDirection: 'row', alignItems: 'center', gap: 4,
    paddingHorizontal: 8, paddingVertical: 4, borderRadius: 8, borderWidth: 0.5,
  },
  factorDot: { width: 5, height: 5, borderRadius: 2.5 },
  factorLabel: { fontSize: 10, fontWeight: '500' },
  factorPct: { fontSize: 10, fontWeight: '700' },
});
