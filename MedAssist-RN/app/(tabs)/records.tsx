import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable,
} from 'react-native';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../../src/shared/components/AppBackground';
import { GlassCard } from '../../src/shared/components/GlassCard';
import { useAppTheme } from '../../src/core/theme/useTheme';

const TABS = ['All', 'Reports', 'Prescriptions', 'Lab Results', 'Insurance'];

const MOCK_RECORDS = [
  { id: '1', title: 'Blood Test Report', type: 'Lab Results', date: 'Mar 28, 2026', icon: 'flask', color: '#EF4444' },
  { id: '2', title: 'Dr. Sharma Prescription', type: 'Prescriptions', date: 'Mar 25, 2026', icon: 'document-text', color: '#3B82F6' },
  { id: '3', title: 'X-Ray Chest PA', type: 'Reports', date: 'Mar 20, 2026', icon: 'scan', color: '#8B5CF6' },
  { id: '4', title: 'ECG Report', type: 'Reports', date: 'Mar 15, 2026', icon: 'pulse', color: '#10B981' },
  { id: '5', title: 'Health Insurance Card', type: 'Insurance', date: 'Jan 01, 2026', icon: 'shield-checkmark', color: '#F59E0B' },
  { id: '6', title: 'Thyroid Panel', type: 'Lab Results', date: 'Feb 10, 2026', icon: 'flask', color: '#EF4444' },
];

export default function HealthRecordsScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const [activeTab, setActiveTab] = useState('All');

  const filtered = activeTab === 'All' ? MOCK_RECORDS : MOCK_RECORDS.filter((r) => r.type === activeTab);

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <View>
            <Text style={[styles.title, { color: colors.textPrimary }]}>Health Records</Text>
            <Text style={[styles.subtitle, { color: colors.textSecondary }]}>Your medical vault</Text>
          </View>
          <Pressable
            onPress={() => {
              Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
              router.push('/medassist-card');
            }}
            style={styles.cardBtn}
          >
            <Ionicons name="card" size={16} color="#FFF" />
            <Text style={styles.cardBtnText}>Health ID</Text>
          </Pressable>
        </View>

        {/* Tabs */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.tabScroll} contentContainerStyle={styles.tabRow}>
          {TABS.map((t) => (
            <Pressable
              key={t}
              onPress={() => setActiveTab(t)}
              style={[styles.tab, {
                backgroundColor: t === activeTab ? '#2A7FFF' : (isDark ? 'rgba(255,255,255,0.06)' : '#F1F5F9'),
              }]}
            >
              <Text style={[styles.tabText, {
                color: t === activeTab ? '#FFF' : colors.textSecondary,
              }]}>{t}</Text>
            </Pressable>
          ))}
        </ScrollView>

        {/* Records */}
        {filtered.map((rec) => (
          <GlassCard key={rec.id} radius={18} blur={14} padding={14} style={styles.recCard}>
            <View style={styles.recRow}>
              <View style={[styles.recIcon, { backgroundColor: `${rec.color}14` }]}>
                <Ionicons name={rec.icon as any} size={20} color={rec.color} />
              </View>
              <View style={styles.recInfo}>
                <Text style={[styles.recTitle, { color: colors.textPrimary }]}>{rec.title}</Text>
                <Text style={[styles.recDate, { color: colors.textSecondary }]}>{rec.date}</Text>
              </View>
              <View style={[styles.typeBadge, { backgroundColor: `${rec.color}10` }]}>
                <Text style={[styles.typeText, { color: rec.color }]}>{rec.type}</Text>
              </View>
            </View>
          </GlassCard>
        ))}

        <View style={{ height: 120 }} />
      </ScrollView>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingHorizontal: 16, paddingTop: 60 },
  headerRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16 },
  title: { fontSize: 26, fontWeight: '800', letterSpacing: -0.5 },
  subtitle: { fontSize: 13, marginTop: 4 },
  cardBtn: {
    flexDirection: 'row', alignItems: 'center', gap: 6,
    backgroundColor: '#2A7FFF', paddingHorizontal: 14, paddingVertical: 8, borderRadius: 12,
  },
  cardBtnText: { fontSize: 12, fontWeight: '700', color: '#FFF' },
  tabScroll: { marginBottom: 16 },
  tabRow: { gap: 8 },
  tab: { paddingHorizontal: 14, paddingVertical: 7, borderRadius: 20 },
  tabText: { fontSize: 12, fontWeight: '600' },
  recCard: { marginBottom: 8 },
  recRow: { flexDirection: 'row', alignItems: 'center' },
  recIcon: { width: 42, height: 42, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  recInfo: { flex: 1, marginLeft: 12 },
  recTitle: { fontSize: 14, fontWeight: '600' },
  recDate: { fontSize: 11, marginTop: 2 },
  typeBadge: { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 8 },
  typeText: { fontSize: 9, fontWeight: '700' },
});
