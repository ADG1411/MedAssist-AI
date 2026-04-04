import React, { useRef, useState } from 'react';
import {
  View, Text, StyleSheet, Pressable, FlatList, Dimensions,
  NativeSyntheticEvent, NativeScrollEvent,
} from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { useAppTheme } from '../src/core/theme/useTheme';
import { AppColors } from '../src/core/theme/colors';

const { width } = Dimensions.get('window');

const PAGES = [
  {
    icon: 'medical',
    color: '#3B82F6',
    title: 'AI Symptom Analysis',
    desc: 'Describe your symptoms and get instant, clinically-informed AI triage with severity scores.',
  },
  {
    icon: 'nutrition',
    color: '#10B981',
    title: 'Smart Nutrition Coach',
    desc: 'Track meals, scan barcodes, and get personalized nutrition advice from your AI dietitian.',
  },
  {
    icon: 'heart',
    color: '#EF4444',
    title: 'Recovery Dashboard',
    desc: 'Monitor vitals, track recovery, and get predictive health insights powered by AI.',
  },
  {
    icon: 'shield-checkmark',
    color: '#6366F1',
    title: 'Secure & Private',
    desc: 'HIPAA-compliant, end-to-end encrypted. Your health data stays yours, always.',
  },
];

export default function OnboardingScreen() {
  const router = useRouter();
  const { isDark, colors } = useAppTheme();
  const flatListRef = useRef<FlatList>(null);
  const [currentPage, setCurrentPage] = useState(0);

  const handleScroll = (e: NativeSyntheticEvent<NativeScrollEvent>) => {
    const idx = Math.round(e.nativeEvent.contentOffset.x / width);
    setCurrentPage(idx);
  };

  const handleNext = () => {
    if (currentPage < PAGES.length - 1) {
      flatListRef.current?.scrollToIndex({ index: currentPage + 1, animated: true });
    } else {
      router.replace('/login');
    }
  };

  return (
    <AppBackground>
      <View style={styles.container}>
        <FlatList
          ref={flatListRef}
          data={PAGES}
          horizontal
          pagingEnabled
          showsHorizontalScrollIndicator={false}
          onMomentumScrollEnd={handleScroll}
          keyExtractor={(_, i) => String(i)}
          renderItem={({ item }) => (
            <View style={[styles.page, { width }]}>
              <View style={[styles.iconCircle, { backgroundColor: `${item.color}18` }]}>
                <Ionicons name={item.icon as any} size={56} color={item.color} />
              </View>
              <Text style={[styles.pageTitle, { color: colors.textPrimary }]}>
                {item.title}
              </Text>
              <Text style={[styles.pageDesc, { color: colors.textSecondary }]}>
                {item.desc}
              </Text>
            </View>
          )}
        />

        {/* Dots */}
        <View style={styles.dotsRow}>
          {PAGES.map((_, i) => (
            <View
              key={i}
              style={[
                styles.dot,
                {
                  backgroundColor: i === currentPage
                    ? AppColors.primary
                    : isDark ? 'rgba(255,255,255,0.15)' : '#D1D5DB',
                  width: i === currentPage ? 24 : 8,
                },
              ]}
            />
          ))}
        </View>

        {/* Buttons */}
        <View style={styles.buttonsRow}>
          <Pressable onPress={() => router.replace('/login')}>
            <Text style={[styles.skipText, { color: colors.textSecondary }]}>
              Skip
            </Text>
          </Pressable>

          <Pressable
            onPress={() => {
              Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
              handleNext();
            }}
          >
            <LinearGradient
              colors={['#3B82F6', '#2563EB']}
              style={styles.nextBtn}
            >
              <Text style={styles.nextBtnText}>
                {currentPage === PAGES.length - 1 ? 'Get Started' : 'Next'}
              </Text>
              <Ionicons name="arrow-forward" size={16} color="#FFF" />
            </LinearGradient>
          </Pressable>
        </View>
      </View>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, paddingBottom: 40 },
  page: {
    alignItems: 'center', justifyContent: 'center',
    paddingHorizontal: 40,
  },
  iconCircle: {
    width: 120, height: 120, borderRadius: 60,
    alignItems: 'center', justifyContent: 'center', marginBottom: 32,
  },
  pageTitle: {
    fontSize: 26, fontWeight: '800', textAlign: 'center',
    letterSpacing: -0.5, marginBottom: 12,
  },
  pageDesc: {
    fontSize: 15, textAlign: 'center', lineHeight: 22,
  },
  dotsRow: {
    flexDirection: 'row', justifyContent: 'center',
    alignItems: 'center', gap: 6, marginBottom: 32,
  },
  dot: { height: 8, borderRadius: 4 },
  buttonsRow: {
    flexDirection: 'row', justifyContent: 'space-between',
    alignItems: 'center', paddingHorizontal: 24,
  },
  skipText: { fontSize: 14, fontWeight: '600' },
  nextBtn: {
    flexDirection: 'row', alignItems: 'center', gap: 8,
    paddingHorizontal: 24, paddingVertical: 14, borderRadius: 14,
    shadowColor: '#3B82F6', shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25, shadowRadius: 12, elevation: 6,
  },
  nextBtnText: { fontSize: 15, fontWeight: '700', color: '#FFF' },
});
