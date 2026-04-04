import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import Svg, { Polyline } from 'react-native-svg';
import { GlassCard } from '../../../shared/components/GlassCard';
import { DashSectionLabel } from '../../../shared/components/DashSectionLabel';
import { useAppTheme } from '../../../core/theme/useTheme';

interface VitalItem {
  label: string;
  value: string;
  unit: string;
  icon: string;
  color: string;
  sparkline: number[];
}

interface Props { data: Record<string, any> }

function buildVitals(data: Record<string, any>): VitalItem[] {
  const w = data?.wearable_data ?? {};
  return [
    { label: 'Heart Rate', value: String(w.heart_rate ?? 72), unit: 'bpm', icon: 'heart', color: '#EF4444', sparkline: [68, 72, 70, 75, 72, 71, 73] },
    { label: 'Steps', value: String(w.steps ?? 6340), unit: 'steps', icon: 'footsteps', color: '#3B82F6', sparkline: [4200, 5100, 6340, 5800, 6000, 6340] },
    { label: 'Sleep', value: String(w.sleep_hours ?? 6.2), unit: 'hrs', icon: 'moon', color: '#8B5CF6', sparkline: [5.5, 6.0, 7.2, 6.2, 5.8, 6.2] },
    { label: 'SpO2', value: String(w.spo2 ?? 97), unit: '%', icon: 'water', color: '#06B6D4', sparkline: [96, 97, 97, 98, 97, 96, 97] },
    { label: 'Calories', value: String(w.calories_burned ?? 1840), unit: 'kcal', icon: 'flame', color: '#F59E0B', sparkline: [1600, 1750, 1840, 1700, 1800, 1840] },
    { label: 'Hydration', value: String(w.hydration_cups ?? 5), unit: 'cups', icon: 'water-outline', color: '#06B6D4', sparkline: [3, 4, 5, 4, 5, 5] },
  ];
}

function Sparkline({ data, color, width: w, height: h }: { data: number[]; color: string; width: number; height: number }) {
  if (data.length < 2) return null;
  const min = Math.min(...data);
  const max = Math.max(...data) || 1;
  const range = max - min || 1;
  const points = data
    .map((v, i) => `${(i / (data.length - 1)) * w},${h - ((v - min) / range) * h * 0.8 - h * 0.1}`)
    .join(' ');
  return (
    <Svg width={w} height={h}>
      <Polyline points={points} fill="none" stroke={color} strokeWidth={1.5} strokeLinecap="round" strokeLinejoin="round" opacity={0.6} />
    </Svg>
  );
}

export function LiveVitalsGlassRail({ data }: Props) {
  const { isDark, colors } = useAppTheme();
  const vitals = buildVitals(data);

  return (
    <View>
      <DashSectionLabel title="💓 Live Vitals" subtitle="Real-time wearable data" />
      <View style={{ height: 10 }} />
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.scroll}>
        {vitals.map((v, i) => (
          <GlassCard key={i} radius={16} blur={14} padding={12} style={styles.card}>
            <View style={styles.cardHeader}>
              <View style={[styles.iconWrap, { backgroundColor: `${v.color}14` }]}>
                <Ionicons name={v.icon as any} size={14} color={v.color} />
              </View>
              <Text style={[styles.cardLabel, { color: colors.textSecondary }]}>{v.label}</Text>
            </View>
            <View style={styles.valueRow}>
              <Text style={[styles.valueText, { color: colors.textPrimary }]}>{v.value}</Text>
              <Text style={[styles.unitText, { color: colors.textSecondary }]}> {v.unit}</Text>
            </View>
            <View style={styles.sparkWrap}>
              <Sparkline data={v.sparkline} color={v.color} width={90} height={28} />
            </View>
          </GlassCard>
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingRight: 16, gap: 10 },
  card: { width: 130 },
  cardHeader: { flexDirection: 'row', alignItems: 'center', gap: 6, marginBottom: 8 },
  iconWrap: { width: 24, height: 24, borderRadius: 8, alignItems: 'center', justifyContent: 'center' },
  cardLabel: { fontSize: 10, fontWeight: '600' },
  valueRow: { flexDirection: 'row', alignItems: 'baseline' },
  valueText: { fontSize: 20, fontWeight: '800', letterSpacing: -0.5 },
  unitText: { fontSize: 10, fontWeight: '500' },
  sparkWrap: { marginTop: 8 },
});
