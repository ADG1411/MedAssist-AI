import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TextInput, Pressable,
} from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const RECENT_FOODS = [
  { name: 'Chicken Breast', cal: 165, unit: '100g', icon: '🍗' },
  { name: 'Brown Rice', cal: 216, unit: '1 cup', icon: '🍚' },
  { name: 'Greek Yogurt', cal: 100, unit: '170g', icon: '🥛' },
  { name: 'Banana', cal: 105, unit: '1 medium', icon: '🍌' },
];

const SEARCH_RESULTS = [
  { name: 'Grilled Salmon', cal: 208, protein: 20, carbs: 0, fat: 13, unit: '100g', icon: '🐟' },
  { name: 'Sweet Potato', cal: 103, protein: 2, carbs: 24, fat: 0, unit: '1 medium', icon: '🍠' },
  { name: 'Avocado Toast', cal: 250, protein: 6, carbs: 26, fat: 15, unit: '1 slice', icon: '🥑' },
  { name: 'Caesar Salad', cal: 180, protein: 8, carbs: 12, fat: 12, unit: '1 bowl', icon: '🥗' },
  { name: 'Protein Shake', cal: 150, protein: 25, carbs: 8, fat: 3, unit: '1 scoop', icon: '🥤' },
];

export default function NutritionSearchScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const { mealType } = useLocalSearchParams<{ mealType?: string }>();
  const [search, setSearch] = useState('');

  const showResults = search.length > 0;

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>
            {mealType ? `Add to ${mealType}` : 'Search Food'}
          </Text>
        </View>

        <View style={[styles.searchBar, {
          backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : '#F1F5F9',
          borderColor: isDark ? 'rgba(255,255,255,0.08)' : '#E2E8F0',
        }]}>
          <Ionicons name="search" size={18} color={colors.textSecondary} />
          <TextInput
            style={[styles.searchInput, { color: colors.textPrimary }]}
            placeholder="Search foods, meals, brands..."
            placeholderTextColor={colors.textSecondary}
            value={search}
            onChangeText={setSearch}
            autoFocus
          />
          {search.length > 0 && (
            <Pressable onPress={() => setSearch('')}>
              <Ionicons name="close-circle" size={18} color={colors.textSecondary} />
            </Pressable>
          )}
        </View>

        {!showResults && (
          <>
            <Text style={[styles.sectionLabel, { color: colors.textSecondary }]}>RECENT</Text>
            {RECENT_FOODS.map((food, i) => (
              <Pressable key={i} onPress={() => {
                Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                router.push({ pathname: '/food-detail', params: { name: food.name, cal: String(food.cal) } });
              }}>
                <GlassCard radius={14} blur={12} padding={12} style={{ marginBottom: 6 }}>
                  <View style={styles.foodRow}>
                    <Text style={styles.foodIcon}>{food.icon}</Text>
                    <View style={styles.foodInfo}>
                      <Text style={[styles.foodName, { color: colors.textPrimary }]}>{food.name}</Text>
                      <Text style={[styles.foodUnit, { color: colors.textSecondary }]}>{food.unit}</Text>
                    </View>
                    <Text style={[styles.foodCal, { color: colors.textPrimary }]}>{food.cal} cal</Text>
                  </View>
                </GlassCard>
              </Pressable>
            ))}
          </>
        )}

        {showResults && (
          <>
            <Text style={[styles.sectionLabel, { color: colors.textSecondary }]}>RESULTS</Text>
            {SEARCH_RESULTS.filter((f) => f.name.toLowerCase().includes(search.toLowerCase()) || search.length > 0).map((food, i) => (
              <Pressable key={i} onPress={() => {
                Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                router.push({ pathname: '/food-detail', params: { name: food.name, cal: String(food.cal) } });
              }}>
                <GlassCard radius={14} blur={12} padding={12} style={{ marginBottom: 6 }}>
                  <View style={styles.foodRow}>
                    <Text style={styles.foodIcon}>{food.icon}</Text>
                    <View style={styles.foodInfo}>
                      <Text style={[styles.foodName, { color: colors.textPrimary }]}>{food.name}</Text>
                      <Text style={[styles.foodUnit, { color: colors.textSecondary }]}>
                        {food.unit} · P:{food.protein}g C:{food.carbs}g F:{food.fat}g
                      </Text>
                    </View>
                    <Text style={[styles.foodCal, { color: colors.textPrimary }]}>{food.cal} cal</Text>
                  </View>
                </GlassCard>
              </Pressable>
            ))}
          </>
        )}

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
    paddingHorizontal: 14, borderWidth: 0.6, marginBottom: 20, gap: 10,
  },
  searchInput: { flex: 1, fontSize: 14 },
  sectionLabel: { fontSize: 11, fontWeight: '700', letterSpacing: 0.5, marginBottom: 8, marginLeft: 4 },
  foodRow: { flexDirection: 'row', alignItems: 'center' },
  foodIcon: { fontSize: 24 },
  foodInfo: { flex: 1, marginLeft: 12 },
  foodName: { fontSize: 14, fontWeight: '600' },
  foodUnit: { fontSize: 11, marginTop: 2 },
  foodCal: { fontSize: 14, fontWeight: '700' },
});
