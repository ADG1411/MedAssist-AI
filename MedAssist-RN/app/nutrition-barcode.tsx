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

export default function NutritionBarcodeScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();

  return (
    <AppBackground>
      <View style={styles.container}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Scan Barcode</Text>
        </View>

        {/* Camera placeholder */}
        <View style={[styles.cameraPlaceholder, {
          backgroundColor: isDark ? 'rgba(255,255,255,0.04)' : 'rgba(0,0,0,0.04)',
          borderColor: isDark ? 'rgba(255,255,255,0.10)' : 'rgba(0,0,0,0.08)',
        }]}>
          <View style={styles.scanFrame}>
            <View style={[styles.cornerTL, styles.corner]} />
            <View style={[styles.cornerTR, styles.corner]} />
            <View style={[styles.cornerBL, styles.corner]} />
            <View style={[styles.cornerBR, styles.corner]} />
          </View>
          <Ionicons name="barcode-outline" size={64} color={colors.textSecondary} style={{ opacity: 0.3 }} />
          <Text style={[styles.scanHint, { color: colors.textSecondary }]}>
            Point your camera at a food barcode
          </Text>
          <Text style={[styles.scanNote, { color: colors.textSecondary }]}>
            Camera requires native build (not available in Expo Go web)
          </Text>
        </View>

        {/* Manual entry */}
        <GlassCard radius={18} blur={14} padding={16} style={{ marginTop: 16 }}>
          <Text style={[styles.altTitle, { color: colors.textPrimary }]}>Or search manually</Text>
          <Pressable
            onPress={() => router.push('/nutrition-search')}
            style={[styles.searchBtn, {
              backgroundColor: isDark ? 'rgba(42,127,255,0.12)' : 'rgba(42,127,255,0.08)',
            }]}
          >
            <Ionicons name="search" size={18} color="#2A7FFF" />
            <Text style={styles.searchBtnText}>Search Food Database</Text>
          </Pressable>
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
    width: W - 32, height: W - 32, borderRadius: 24, borderWidth: 1,
    alignItems: 'center', justifyContent: 'center',
  },
  scanFrame: {
    position: 'absolute', width: '60%', height: '40%',
  },
  corner: {
    position: 'absolute', width: 24, height: 24,
    borderColor: '#2A7FFF', borderWidth: 3,
  },
  cornerTL: { top: 0, left: 0, borderRightWidth: 0, borderBottomWidth: 0, borderTopLeftRadius: 8 },
  cornerTR: { top: 0, right: 0, borderLeftWidth: 0, borderBottomWidth: 0, borderTopRightRadius: 8 },
  cornerBL: { bottom: 0, left: 0, borderRightWidth: 0, borderTopWidth: 0, borderBottomLeftRadius: 8 },
  cornerBR: { bottom: 0, right: 0, borderLeftWidth: 0, borderTopWidth: 0, borderBottomRightRadius: 8 },
  scanHint: { fontSize: 14, fontWeight: '600', marginTop: 16 },
  scanNote: { fontSize: 11, marginTop: 6, textAlign: 'center', paddingHorizontal: 40 },
  altTitle: { fontSize: 14, fontWeight: '700', marginBottom: 10 },
  searchBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    height: 44, borderRadius: 12,
  },
  searchBtnText: { fontSize: 14, fontWeight: '600', color: '#2A7FFF' },
});
