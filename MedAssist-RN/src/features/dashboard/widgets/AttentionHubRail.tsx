import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, ScrollView, Animated, Easing } from 'react-native';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { GlassCard } from '../../../shared/components/GlassCard';
import { DashSectionLabel } from '../../../shared/components/DashSectionLabel';
import { useAppTheme } from '../../../core/theme/useTheme';

interface Alert {
  label: string;
  detail: string;
  icon: string;
  urgency: 'high' | 'medium' | 'low';
}

interface Props { data: Record<string, any> }

function buildAlerts(data: Record<string, any>): Alert[] {
  const alerts: Alert[] = [];
  const meds = (data?.medication_reminders as any[]) ?? [];
  const hasMissed = meds.some((m) => !m.taken);
  if (hasMissed) {
    alerts.push({ label: 'Missed Medication', detail: 'You missed your evening dose', icon: 'alert-circle', urgency: 'high' });
  }
  alerts.push({ label: 'Unsafe Meal Logged', detail: 'High sodium detected in lunch', icon: 'warning', urgency: 'medium' });
  alerts.push({ label: 'Complete Profile', detail: 'Add allergies for better AI results', icon: 'information-circle', urgency: 'low' });
  alerts.push({ label: 'Wearable Sync', detail: 'Last synced 2h ago', icon: 'watch', urgency: 'low' });
  // Sort: high → medium → low
  const order = { high: 0, medium: 1, low: 2 };
  alerts.sort((a, b) => order[a.urgency] - order[b.urgency]);
  return alerts;
}

const URGENCY_STYLES = {
  high: { bg: 'rgba(239,68,68,0.08)', border: 'rgba(239,68,68,0.40)', iconColor: '#EF4444', chipBg: 'rgba(239,68,68,0.12)', chipColor: '#EF4444' },
  medium: { bg: 'rgba(245,158,11,0.06)', border: 'rgba(245,158,11,0.25)', iconColor: '#F59E0B', chipBg: 'rgba(245,158,11,0.10)', chipColor: '#F59E0B' },
  low: { bg: 'rgba(59,130,246,0.04)', border: 'rgba(59,130,246,0.15)', iconColor: '#3B82F6', chipBg: 'rgba(59,130,246,0.08)', chipColor: '#3B82F6' },
};

function PulseDot() {
  const pulse = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(pulse, { toValue: 1, duration: 1000, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
        Animated.timing(pulse, { toValue: 0, duration: 1000, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
      ])
    ).start();
  }, []);
  const opacity = pulse.interpolate({ inputRange: [0, 1], outputRange: [0.4, 1] });
  const scale = pulse.interpolate({ inputRange: [0, 1], outputRange: [0.7, 1.2] });
  return <Animated.View style={[styles.pulseDot, { opacity, transform: [{ scale }] }]} />;
}

export function AttentionHubRail({ data }: Props) {
  const { colors } = useAppTheme();
  const alerts = buildAlerts(data);
  const criticalCount = alerts.filter((a) => a.urgency === 'high').length;

  return (
    <View>
      <View style={styles.headerRow}>
        <DashSectionLabel title="🚨 Attention Hub" subtitle="Alerts needing your action" />
        {criticalCount > 0 && (
          <View style={styles.critBadge}>
            <Text style={styles.critBadgeText}>{criticalCount}</Text>
          </View>
        )}
      </View>
      <View style={{ height: 10 }} />
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.scroll}>
        {alerts.map((alert, i) => {
          const s = URGENCY_STYLES[alert.urgency];
          return (
            <View key={i} style={[styles.card, { backgroundColor: s.bg, borderColor: s.border }]}>
              {alert.urgency === 'high' && (
                <View style={styles.pulseDotWrap}><PulseDot /></View>
              )}
              <Ionicons name={alert.icon as any} size={22} color={s.iconColor} />
              <Text style={[styles.cardLabel, { color: colors.textPrimary }]} numberOfLines={1}>
                {alert.label}
              </Text>
              <Text style={[styles.cardDetail, { color: colors.textSecondary }]} numberOfLines={2}>
                {alert.detail}
              </Text>
              <View style={[styles.urgChip, { backgroundColor: s.chipBg }]}>
                <Text style={[styles.urgChipText, { color: s.chipColor }]}>
                  {alert.urgency.toUpperCase()}
                </Text>
              </View>
            </View>
          );
        })}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  headerRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  critBadge: {
    backgroundColor: '#EF4444', width: 20, height: 20, borderRadius: 10,
    alignItems: 'center', justifyContent: 'center', marginRight: 4,
  },
  critBadgeText: { color: '#FFF', fontSize: 10, fontWeight: '800' },
  scroll: { paddingRight: 16, gap: 10 },
  card: {
    width: 155, borderRadius: 16, padding: 14, borderWidth: 1,
    shadowColor: '#000', shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.04, shadowRadius: 8, elevation: 2,
  },
  pulseDotWrap: { position: 'absolute', top: 10, right: 10 },
  pulseDot: { width: 8, height: 8, borderRadius: 4, backgroundColor: '#EF4444' },
  cardLabel: { fontSize: 13, fontWeight: '700', marginTop: 8 },
  cardDetail: { fontSize: 10, marginTop: 3, lineHeight: 14 },
  urgChip: { marginTop: 8, paddingHorizontal: 6, paddingVertical: 2, borderRadius: 5, alignSelf: 'flex-start' },
  urgChipText: { fontSize: 8, fontWeight: '800', letterSpacing: 0.3 },
});
