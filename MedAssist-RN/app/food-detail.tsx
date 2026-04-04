import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable,
} from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import Svg, { Circle } from 'react-native-svg';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const MOCK_NUTRIENTS = [
  { label: 'Protein', value: 25, unit: 'g', color: '#3B82F6', daily: 50 },
  { label: 'Carbs', value: 12, unit: 'g', color: '#F59E0B', daily: 300 },
  { label: 'Fat', value: 8, unit: 'g', color: '#EF4444', daily: 65 },
  { label: 'Fiber', value: 3, unit: 'g', color: '#10B981', daily: 25 },
  { label: 'Sodium', value: 320, unit: 'mg', color: '#8B5CF6', daily: 2300 },
  { label: 'Sugar', value: 2, unit: 'g', color: '#EC4899', daily: 50 },
];

export default function FoodDetailScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const { name, cal } = useLocalSearchParams<{ name?: string; cal?: string }>();
  const [servings, setServings] = useState(1);

  const calories = parseInt(cal ?? '200', 10) * servings;

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]} numberOfLines={1}>{name ?? 'Food Detail'}</Text>
        </View>

        {/* Calorie ring */}
        <GlassCard radius={24} blur={20} padding={24}>
          <View style={styles.heroRow}>
            <View style={styles.ringWrap}>
              <Svg width={110} height={110} viewBox="0 0 110 110">
                <Circle cx={55} cy={55} r={48} stroke={isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.06)'} strokeWidth={7} fill="none" />
                <Circle cx={55} cy={55} r={48} stroke="#10B981" strokeWidth={7} fill="none"
                  strokeLinecap="round" strokeDasharray={`${2 * Math.PI * 48}`}
                  strokeDashoffset={2 * Math.PI * 48 * (1 - Math.min(calories / 2200, 1))}
                  rotation={-90} origin="55,55" />
              </Svg>
              <View style={styles.ringCenter}>
                <Text style={[styles.calNum, { color: colors.textPrimary }]}>{calories}</Text>
                <Text style={[styles.calUnit, { color: colors.textSecondary }]}>kcal</Text>
              </View>
            </View>
            <View style={styles.servingCol}>
              <Text style={[styles.servingLabel, { color: colors.textSecondary }]}>Servings</Text>
              <View style={styles.servingRow}>
                <Pressable
                  onPress={() => setServings(Math.max(1, servings - 1))}
                  style={[styles.servingBtn, { backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#F1F5F9' }]}
                >
                  <Ionicons name="remove" size={18} color={colors.textPrimary} />
                </Pressable>
                <Text style={[styles.servingNum, { color: colors.textPrimary }]}>{servings}</Text>
                <Pressable
                  onPress={() => setServings(servings + 1)}
                  style={[styles.servingBtn, { backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#F1F5F9' }]}
                >
                  <Ionicons name="add" size={18} color={colors.textPrimary} />
                </Pressable>
              </View>
            </View>
          </View>
        </GlassCard>

        {/* Nutrients */}
        <GlassCard radius={20} blur={16} padding={16} style={{ marginTop: 14 }}>
          <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>Nutrition Facts</Text>
          {MOCK_NUTRIENTS.map((n, i) => {
            const val = Math.round(n.value * servings);
            const pct = Math.round((val / n.daily) * 100);
            return (
              <View key={i} style={styles.nutrientRow}>
                <View style={[styles.nutrientDot, { backgroundColor: n.color }]} />
                <Text style={[styles.nutrientLabel, { color: colors.textPrimary }]}>{n.label}</Text>
                <View style={[styles.nutrientBar, { backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)' }]}>
                  <View style={[styles.nutrientBarFill, { width: `${Math.min(pct, 100)}%`, backgroundColor: n.color }]} />
                </View>
                <Text style={[styles.nutrientVal, { color: colors.textPrimary }]}>{val}{n.unit}</Text>
                <Text style={[styles.nutrientPct, { color: colors.textSecondary }]}>{pct}%</Text>
              </View>
            );
          })}
        </GlassCard>

        {/* Add button */}
        <Pressable
          onPress={() => {
            Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
            router.back();
          }}
          style={{ marginTop: 16 }}
        >
          <LinearGradient colors={['#10B981', '#059669']} style={styles.addBtn}>
            <Ionicons name="add-circle" size={18} color="#FFF" />
            <Text style={styles.addBtnText}>Add to Diary</Text>
          </LinearGradient>
        </Pressable>

        <View style={{ height: 40 }} />
      </ScrollView>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingHorizontal: 16, paddingTop: 60 },
  headerRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginBottom: 16 },
  backBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 22, fontWeight: '800', flex: 1 },
  heroRow: { flexDirection: 'row', alignItems: 'center' },
  ringWrap: { width: 110, height: 110, alignItems: 'center', justifyContent: 'center' },
  ringCenter: { position: 'absolute', alignItems: 'center' },
  calNum: { fontSize: 26, fontWeight: '800', letterSpacing: -1 },
  calUnit: { fontSize: 11, marginTop: -2 },
  servingCol: { flex: 1, marginLeft: 24, alignItems: 'center' },
  servingLabel: { fontSize: 12, fontWeight: '600', marginBottom: 10 },
  servingRow: { flexDirection: 'row', alignItems: 'center', gap: 16 },
  servingBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  servingNum: { fontSize: 24, fontWeight: '800' },
  sectionTitle: { fontSize: 15, fontWeight: '700', marginBottom: 14 },
  nutrientRow: { flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 10 },
  nutrientDot: { width: 6, height: 6, borderRadius: 3 },
  nutrientLabel: { width: 60, fontSize: 12, fontWeight: '600' },
  nutrientBar: { flex: 1, height: 5, borderRadius: 2.5, overflow: 'hidden' },
  nutrientBarFill: { height: 5, borderRadius: 2.5 },
  nutrientVal: { width: 50, fontSize: 12, fontWeight: '700', textAlign: 'right' },
  nutrientPct: { width: 30, fontSize: 10, textAlign: 'right' },
  addBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    height: 52, borderRadius: 14,
    shadowColor: '#10B981', shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25, shadowRadius: 12, elevation: 6,
  },
  addBtnText: { fontSize: 15, fontWeight: '700', color: '#FFF' },
});
