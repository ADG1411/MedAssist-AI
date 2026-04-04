import React from 'react';
import { View, Text, StyleSheet, Pressable } from 'react-native';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
import { GlassCard } from '../../../shared/components/GlassCard';
import { DashSectionLabel } from '../../../shared/components/DashSectionLabel';
import { useAppTheme } from '../../../core/theme/useTheme';

interface ActionItem {
  icon: string;
  label: string;
  color: string;
  route: string;
  aiSuggested?: boolean;
}

const ACTIONS: ActionItem[] = [
  { icon: 'medical', label: 'Symptom AI', color: '#3B82F6', route: '/symptom-check', aiSuggested: true },
  { icon: 'people', label: 'Doctors', color: '#6366F1', route: '/(tabs)/doctors' },
  { icon: 'restaurant', label: 'Nutrition', color: '#10B981', route: '/(tabs)/nutrition' },
  { icon: 'heart', label: 'Vitals', color: '#EF4444', route: '/health-connect' },
  { icon: 'document-text', label: 'Records', color: '#F59E0B', route: '/(tabs)/records' },
  { icon: 'medkit', label: 'Pharmacy', color: '#06B6D4', route: '/pharmacy' },
  { icon: 'pulse', label: 'Monitoring', color: '#8B5CF6', route: '/monitoring' },
  { icon: 'location', label: 'Hospitals', color: '#EC4899', route: '/hospitals' },
];

export function ActionMatrixGrid() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();

  return (
    <View>
      <DashSectionLabel title="⚡ Quick Actions" subtitle="Your health toolkit" />
      <View style={{ height: 10 }} />
      <View style={styles.grid}>
        {ACTIONS.map((a, i) => (
          <Pressable
            key={i}
            style={{ width: '23%' }}
            onPress={() => {
              Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
              router.push(a.route as any);
            }}
          >
            <GlassCard radius={16} blur={12} padding={0} style={styles.actionCard}>
              <View style={styles.actionInner}>
                {a.aiSuggested && (
                  <View style={styles.aiBadge}>
                    <Text style={styles.aiBadgeText}>AI</Text>
                  </View>
                )}
                <View style={[styles.iconBg, { backgroundColor: `${a.color}14` }]}>
                  <Ionicons name={a.icon as any} size={22} color={a.color} />
                </View>
                <Text style={[styles.actionLabel, { color: colors.textPrimary }]} numberOfLines={1}>
                  {a.label}
                </Text>
              </View>
            </GlassCard>
          </Pressable>
        ))}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, justifyContent: 'space-between' },
  actionCard: { aspectRatio: 1 },
  actionInner: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 8 },
  aiBadge: {
    position: 'absolute', top: 4, right: 4,
    backgroundColor: 'rgba(59,130,246,0.12)', paddingHorizontal: 4, paddingVertical: 1,
    borderRadius: 4,
  },
  aiBadgeText: { fontSize: 7, fontWeight: '800', color: '#3B82F6' },
  iconBg: { width: 40, height: 40, borderRadius: 14, alignItems: 'center', justifyContent: 'center', marginBottom: 6 },
  actionLabel: { fontSize: 10, fontWeight: '600', textAlign: 'center' },
});
