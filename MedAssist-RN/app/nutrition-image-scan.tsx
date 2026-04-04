import React from 'react';
import {
  View, Text, StyleSheet, Pressable, Dimensions,
} from 'react-native';
import { useRouter } from 'expo-router';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const { width: W } = Dimensions.get('window');

export default function NutritionImageScanScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();

  return (
    <AppBackground>
      <View style={styles.container}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Photo Scan</Text>
        </View>

        <View style={[styles.cameraPlaceholder, {
          backgroundColor: isDark ? 'rgba(255,255,255,0.04)' : 'rgba(0,0,0,0.04)',
          borderColor: isDark ? 'rgba(255,255,255,0.10)' : 'rgba(0,0,0,0.08)',
        }]}>
          <Ionicons name="camera-outline" size={64} color={colors.textSecondary} style={{ opacity: 0.3 }} />
          <Text style={[styles.scanHint, { color: colors.textPrimary }]}>
            Take a photo of your meal
          </Text>
          <Text style={[styles.scanNote, { color: colors.textSecondary }]}>
            AI will analyze the food and estimate calories & macros
          </Text>
        </View>

        <View style={styles.btnRow}>
          <Pressable style={[styles.actionBtn, { backgroundColor: isDark ? 'rgba(139,92,246,0.12)' : 'rgba(139,92,246,0.08)' }]}>
            <Ionicons name="camera" size={24} color="#8B5CF6" />
            <Text style={[styles.actionLabel, { color: '#8B5CF6' }]}>Take Photo</Text>
          </Pressable>
          <Pressable style={[styles.actionBtn, { backgroundColor: isDark ? 'rgba(59,130,246,0.12)' : 'rgba(59,130,246,0.08)' }]}>
            <Ionicons name="images" size={24} color="#3B82F6" />
            <Text style={[styles.actionLabel, { color: '#3B82F6' }]}>From Gallery</Text>
          </Pressable>
        </View>

        <GlassCard radius={18} blur={14} padding={14} style={{ marginTop: 16 }}>
          <View style={styles.tipRow}>
            <Ionicons name="bulb-outline" size={16} color="#F59E0B" />
            <Text style={[styles.tipText, { color: colors.textSecondary }]}>
              Tip: Place food on a plain surface with good lighting for best results
            </Text>
          </View>
        </GlassCard>
      </View>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, paddingHorizontal: 16, paddingTop: 60 },
  headerRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginBottom: 16 },
  backBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 22, fontWeight: '800' },
  cameraPlaceholder: {
    width: W - 32, height: W * 0.7, borderRadius: 24, borderWidth: 1,
    alignItems: 'center', justifyContent: 'center', gap: 12,
  },
  scanHint: { fontSize: 16, fontWeight: '700' },
  scanNote: { fontSize: 12, textAlign: 'center', paddingHorizontal: 40 },
  btnRow: { flexDirection: 'row', gap: 12, marginTop: 16 },
  actionBtn: {
    flex: 1, height: 80, borderRadius: 18, alignItems: 'center', justifyContent: 'center', gap: 6,
  },
  actionLabel: { fontSize: 12, fontWeight: '700' },
  tipRow: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  tipText: { flex: 1, fontSize: 12, lineHeight: 17 },
});
