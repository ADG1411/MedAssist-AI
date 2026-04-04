import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable,
} from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import Svg, { Circle } from 'react-native-svg';
import { AppBackground } from '../../src/shared/components/AppBackground';
import { GlassCard } from '../../src/shared/components/GlassCard';
import { useAppTheme } from '../../src/core/theme/useTheme';

const MEAL_TYPES = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

const QUICK_ACTIONS = [
  { icon: 'search', label: 'Search Food', route: '/nutrition-search', color: '#3B82F6' },
  { icon: 'barcode', label: 'Scan Barcode', route: '/nutrition-barcode', color: '#10B981' },
  { icon: 'camera', label: 'Photo Scan', route: '/nutrition-image-scan', color: '#8B5CF6' },
  { icon: 'chatbubble-ellipses', label: 'AI Coach', route: '/nutrition-ai', color: '#F59E0B' },
];

const MOCK_SUMMARY = { calories: 1450, target: 2200, protein: 62, carbs: 180, fat: 48, burned: 420 };

export default function NutritionDiaryScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();

  const progress = MOCK_SUMMARY.calories / MOCK_SUMMARY.target;
  const circumference = 2 * Math.PI * 45;
  const strokeDashoffset = circumference * (1 - Math.min(progress, 1));

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <Text style={[styles.title, { color: colors.textPrimary }]}>Nutrition Diary</Text>
        <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
          Track meals & get AI nutrition coaching
        </Text>

        {/* Calorie Hero */}
        <GlassCard radius={24} blur={20} padding={20}>
          <View style={styles.heroRow}>
            <View style={styles.ringWrap}>
              <Svg width={100} height={100} viewBox="0 0 100 100">
                <Circle cx={50} cy={50} r={45} stroke={isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.06)'} strokeWidth={7} fill="none" />
                <Circle cx={50} cy={50} r={45} stroke="#10B981" strokeWidth={7} fill="none"
                  strokeLinecap="round" strokeDasharray={`${circumference}`} strokeDashoffset={strokeDashoffset}
                  rotation={-90} origin="50,50" />
              </Svg>
              <View style={styles.ringCenter}>
                <Text style={[styles.calNum, { color: colors.textPrimary }]}>{MOCK_SUMMARY.calories}</Text>
                <Text style={[styles.calLabel, { color: colors.textSecondary }]}>/ {MOCK_SUMMARY.target}</Text>
              </View>
            </View>
            <View style={styles.macroCol}>
              {[
                { label: 'Protein', val: `${MOCK_SUMMARY.protein}g`, color: '#3B82F6' },
                { label: 'Carbs', val: `${MOCK_SUMMARY.carbs}g`, color: '#F59E0B' },
                { label: 'Fat', val: `${MOCK_SUMMARY.fat}g`, color: '#EF4444' },
                { label: 'Burned', val: `${MOCK_SUMMARY.burned} kcal`, color: '#10B981' },
              ].map((m, i) => (
                <View key={i} style={styles.macroRow}>
                  <View style={[styles.macroDot, { backgroundColor: m.color }]} />
                  <Text style={[styles.macroLabel, { color: colors.textSecondary }]}>{m.label}</Text>
                  <Text style={[styles.macroVal, { color: colors.textPrimary }]}>{m.val}</Text>
                </View>
              ))}
            </View>
          </View>
        </GlassCard>

        {/* Quick actions */}
        <View style={styles.quickGrid}>
          {QUICK_ACTIONS.map((a, i) => (
            <Pressable
              key={i}
              style={{ width: '23%' }}
              onPress={() => {
                Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                router.push(a.route as any);
              }}
            >
              <GlassCard radius={16} blur={12} padding={12} style={styles.quickCard}>
                <View style={[styles.quickIcon, { backgroundColor: `${a.color}14` }]}>
                  <Ionicons name={a.icon as any} size={20} color={a.color} />
                </View>
                <Text style={[styles.quickLabel, { color: colors.textPrimary }]} numberOfLines={1}>{a.label}</Text>
              </GlassCard>
            </Pressable>
          ))}
        </View>

        {/* Meal sections */}
        {MEAL_TYPES.map((meal, i) => (
          <GlassCard key={i} radius={18} blur={14} padding={14} style={styles.mealCard}>
            <View style={styles.mealHeader}>
              <Text style={[styles.mealTitle, { color: colors.textPrimary }]}>{meal}</Text>
              <Pressable
                onPress={() => {
                  Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                  router.push({ pathname: '/nutrition-search', params: { mealType: meal } });
                }}
                style={[styles.addBtn, { backgroundColor: isDark ? 'rgba(42,127,255,0.15)' : 'rgba(42,127,255,0.08)' }]}
              >
                <Ionicons name="add" size={16} color="#2A7FFF" />
                <Text style={styles.addBtnText}>Add</Text>
              </Pressable>
            </View>
            <Text style={[styles.mealEmpty, { color: colors.textSecondary }]}>
              No items logged yet. Tap + to add.
            </Text>
          </GlassCard>
        ))}

        {/* History link */}
        <Pressable
          onPress={() => router.push('/nutrition-history')}
          style={styles.historyLink}
        >
          <Text style={styles.historyText}>View Full History →</Text>
        </Pressable>

        <View style={{ height: 120 }} />
      </ScrollView>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingHorizontal: 16, paddingTop: 60 },
  title: { fontSize: 26, fontWeight: '800', letterSpacing: -0.5 },
  subtitle: { fontSize: 13, marginTop: 4, marginBottom: 16 },
  heroRow: { flexDirection: 'row', alignItems: 'center' },
  ringWrap: { width: 100, height: 100, alignItems: 'center', justifyContent: 'center' },
  ringCenter: { position: 'absolute', alignItems: 'center' },
  calNum: { fontSize: 22, fontWeight: '800', letterSpacing: -1 },
  calLabel: { fontSize: 10, marginTop: -2 },
  macroCol: { flex: 1, marginLeft: 20, gap: 6 },
  macroRow: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  macroDot: { width: 6, height: 6, borderRadius: 3 },
  macroLabel: { fontSize: 11, width: 55 },
  macroVal: { fontSize: 13, fontWeight: '700' },
  quickGrid: { flexDirection: 'row', justifyContent: 'space-between', marginVertical: 16 },
  quickCard: { alignItems: 'center' },
  quickIcon: { width: 40, height: 40, borderRadius: 14, alignItems: 'center', justifyContent: 'center', marginBottom: 6 },
  quickLabel: { fontSize: 9, fontWeight: '600', textAlign: 'center' },
  mealCard: { marginBottom: 10 },
  mealHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 },
  mealTitle: { fontSize: 15, fontWeight: '700' },
  addBtn: { flexDirection: 'row', alignItems: 'center', gap: 4, paddingHorizontal: 10, paddingVertical: 5, borderRadius: 10 },
  addBtnText: { fontSize: 12, fontWeight: '600', color: '#2A7FFF' },
  mealEmpty: { fontSize: 12, fontStyle: 'italic' },
  historyLink: { alignItems: 'center', paddingVertical: 14 },
  historyText: { fontSize: 13, fontWeight: '600', color: '#2A7FFF' },
});
