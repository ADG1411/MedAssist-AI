import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TextInput, Pressable,
} from 'react-native';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const ACTIVITIES = [
  { name: 'Walking', cal: 150, unit: '30 min', icon: '🚶' },
  { name: 'Running', cal: 350, unit: '30 min', icon: '🏃' },
  { name: 'Cycling', cal: 280, unit: '30 min', icon: '🚴' },
  { name: 'Swimming', cal: 300, unit: '30 min', icon: '🏊' },
  { name: 'Yoga', cal: 120, unit: '30 min', icon: '🧘' },
  { name: 'Weight Training', cal: 200, unit: '30 min', icon: '🏋️' },
  { name: 'Dancing', cal: 250, unit: '30 min', icon: '💃' },
  { name: 'Hiking', cal: 320, unit: '60 min', icon: '🥾' },
];

export default function ActivitySearchScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const [search, setSearch] = useState('');

  const filtered = ACTIVITIES.filter((a) =>
    a.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Log Activity</Text>
        </View>

        <View style={[styles.searchBar, {
          backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : '#F1F5F9',
          borderColor: isDark ? 'rgba(255,255,255,0.08)' : '#E2E8F0',
        }]}>
          <Ionicons name="search" size={18} color={colors.textSecondary} />
          <TextInput
            style={[styles.searchInput, { color: colors.textPrimary }]}
            placeholder="Search activities..."
            placeholderTextColor={colors.textSecondary}
            value={search}
            onChangeText={setSearch}
          />
        </View>

        {filtered.map((act, i) => (
          <Pressable key={i} onPress={() => {
            Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
            router.back();
          }}>
            <GlassCard radius={14} blur={12} padding={14} style={{ marginBottom: 6 }}>
              <View style={styles.actRow}>
                <Text style={styles.actIcon}>{act.icon}</Text>
                <View style={styles.actInfo}>
                  <Text style={[styles.actName, { color: colors.textPrimary }]}>{act.name}</Text>
                  <Text style={[styles.actUnit, { color: colors.textSecondary }]}>{act.unit}</Text>
                </View>
                <View style={[styles.calBadge, { backgroundColor: isDark ? 'rgba(239,68,68,0.10)' : 'rgba(239,68,68,0.06)' }]}>
                  <Ionicons name="flame" size={12} color="#EF4444" />
                  <Text style={styles.calText}>{act.cal} cal</Text>
                </View>
              </View>
            </GlassCard>
          </Pressable>
        ))}

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
  searchBar: {
    flexDirection: 'row', alignItems: 'center', height: 46, borderRadius: 14,
    paddingHorizontal: 14, borderWidth: 0.6, marginBottom: 16, gap: 10,
  },
  searchInput: { flex: 1, fontSize: 14 },
  actRow: { flexDirection: 'row', alignItems: 'center' },
  actIcon: { fontSize: 28 },
  actInfo: { flex: 1, marginLeft: 12 },
  actName: { fontSize: 14, fontWeight: '600' },
  actUnit: { fontSize: 11, marginTop: 2 },
  calBadge: { flexDirection: 'row', alignItems: 'center', gap: 4, paddingHorizontal: 8, paddingVertical: 4, borderRadius: 8 },
  calText: { fontSize: 11, fontWeight: '700', color: '#EF4444' },
});
