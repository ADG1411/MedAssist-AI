import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable,
} from 'react-native';
import { useRouter } from 'expo-router';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const MOCK_HISTORY = [
  { date: 'Today', totalCal: 1450, meals: [
    { name: 'Oatmeal with berries', cal: 320, time: '8:30 AM', meal: 'Breakfast' },
    { name: 'Grilled chicken salad', cal: 480, time: '1:00 PM', meal: 'Lunch' },
    { name: 'Protein bar', cal: 200, time: '4:00 PM', meal: 'Snack' },
    { name: 'Brown rice & vegetables', cal: 450, time: '7:30 PM', meal: 'Dinner' },
  ]},
  { date: 'Yesterday', totalCal: 1890, meals: [
    { name: 'Eggs & toast', cal: 350, time: '9:00 AM', meal: 'Breakfast' },
    { name: 'Pasta with marinara', cal: 620, time: '12:30 PM', meal: 'Lunch' },
    { name: 'Apple & peanut butter', cal: 280, time: '3:30 PM', meal: 'Snack' },
    { name: 'Grilled fish & quinoa', cal: 540, time: '8:00 PM', meal: 'Dinner' },
    { name: 'Greek yogurt', cal: 100, time: '9:30 PM', meal: 'Snack' },
  ]},
  { date: 'Apr 2', totalCal: 1720, meals: [
    { name: 'Smoothie bowl', cal: 380, time: '8:00 AM', meal: 'Breakfast' },
    { name: 'Chicken wrap', cal: 520, time: '1:00 PM', meal: 'Lunch' },
    { name: 'Mixed nuts', cal: 180, time: '4:00 PM', meal: 'Snack' },
    { name: 'Stir-fry tofu', cal: 640, time: '7:00 PM', meal: 'Dinner' },
  ]},
];

export default function NutritionHistoryScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Nutrition History</Text>
        </View>

        {MOCK_HISTORY.map((day, di) => (
          <View key={di} style={styles.daySection}>
            <View style={styles.dayHeader}>
              <Text style={[styles.dayDate, { color: colors.textPrimary }]}>{day.date}</Text>
              <View style={[styles.calBadge, { backgroundColor: isDark ? 'rgba(16,185,129,0.12)' : 'rgba(16,185,129,0.08)' }]}>
                <Ionicons name="flame" size={12} color="#10B981" />
                <Text style={styles.calBadgeText}>{day.totalCal} kcal</Text>
              </View>
            </View>
            {day.meals.map((meal, mi) => (
              <GlassCard key={mi} radius={14} blur={12} padding={12} style={{ marginBottom: 6 }}>
                <View style={styles.mealRow}>
                  <View style={styles.mealInfo}>
                    <Text style={[styles.mealName, { color: colors.textPrimary }]}>{meal.name}</Text>
                    <Text style={[styles.mealMeta, { color: colors.textSecondary }]}>{meal.meal} · {meal.time}</Text>
                  </View>
                  <Text style={[styles.mealCal, { color: colors.textPrimary }]}>{meal.cal} cal</Text>
                </View>
              </GlassCard>
            ))}
          </View>
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
  daySection: { marginBottom: 20 },
  dayHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 },
  dayDate: { fontSize: 16, fontWeight: '700' },
  calBadge: { flexDirection: 'row', alignItems: 'center', gap: 4, paddingHorizontal: 8, paddingVertical: 4, borderRadius: 8 },
  calBadgeText: { fontSize: 11, fontWeight: '700', color: '#10B981' },
  mealRow: { flexDirection: 'row', alignItems: 'center' },
  mealInfo: { flex: 1 },
  mealName: { fontSize: 13, fontWeight: '600' },
  mealMeta: { fontSize: 10, marginTop: 2 },
  mealCal: { fontSize: 13, fontWeight: '700' },
});
