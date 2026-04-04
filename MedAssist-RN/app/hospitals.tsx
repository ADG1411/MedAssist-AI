import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable, TextInput, Linking,
} from 'react-native';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const MOCK_HOSPITALS = [
  { id: '1', name: 'Apollo Hospital', distance: '2.3 km', rating: 4.8, emergency: true, beds: 12, type: 'Multi-Specialty', phone: '+91-1234567890' },
  { id: '2', name: 'Fortis Healthcare', distance: '4.1 km', rating: 4.7, emergency: true, beds: 8, type: 'Multi-Specialty', phone: '+91-1234567891' },
  { id: '3', name: 'City General Hospital', distance: '1.8 km', rating: 4.3, emergency: true, beds: 3, type: 'Government', phone: '+91-1234567892' },
  { id: '4', name: 'Medanta Clinic', distance: '5.6 km', rating: 4.9, emergency: false, beds: 20, type: 'Private', phone: '+91-1234567893' },
  { id: '5', name: 'Max Super Specialty', distance: '6.2 km', rating: 4.6, emergency: true, beds: 15, type: 'Multi-Specialty', phone: '+91-1234567894' },
];

export default function HospitalsScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const [search, setSearch] = useState('');

  const filtered = MOCK_HOSPITALS.filter((h) =>
    h.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Nearby Hospitals</Text>
        </View>

        {/* Search */}
        <View style={[styles.searchBar, {
          backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : '#F1F5F9',
          borderColor: isDark ? 'rgba(255,255,255,0.08)' : '#E2E8F0',
        }]}>
          <Ionicons name="search" size={18} color={colors.textSecondary} />
          <TextInput
            style={[styles.searchInput, { color: colors.textPrimary }]}
            placeholder="Search hospitals..."
            placeholderTextColor={colors.textSecondary}
            value={search}
            onChangeText={setSearch}
          />
        </View>

        {/* Map placeholder */}
        <View style={[styles.mapPlaceholder, {
          backgroundColor: isDark ? 'rgba(255,255,255,0.04)' : 'rgba(0,0,0,0.03)',
          borderColor: isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)',
        }]}>
          <Ionicons name="map" size={40} color={colors.textSecondary} style={{ opacity: 0.3 }} />
          <Text style={[styles.mapText, { color: colors.textSecondary }]}>Map view (requires native build)</Text>
        </View>

        {/* Hospital list */}
        {filtered.map((hosp) => (
          <GlassCard key={hosp.id} radius={18} blur={14} padding={16} style={{ marginBottom: 10 }}>
            <View style={styles.hospRow}>
              <View style={[styles.hospIcon, { backgroundColor: hosp.emergency ? 'rgba(239,68,68,0.10)' : 'rgba(59,130,246,0.10)' }]}>
                <Ionicons name="business" size={20} color={hosp.emergency ? '#EF4444' : '#3B82F6'} />
              </View>
              <View style={styles.hospInfo}>
                <Text style={[styles.hospName, { color: colors.textPrimary }]}>{hosp.name}</Text>
                <View style={styles.hospMeta}>
                  <Text style={[styles.hospDist, { color: colors.textSecondary }]}>{hosp.distance}</Text>
                  <View style={styles.ratingBadge}>
                    <Ionicons name="star" size={10} color="#F59E0B" />
                    <Text style={styles.ratingText}>{hosp.rating}</Text>
                  </View>
                  <Text style={[styles.hospType, { color: colors.textSecondary }]}>{hosp.type}</Text>
                </View>
                <View style={styles.hospChips}>
                  {hosp.emergency && (
                    <View style={styles.emergencyChip}>
                      <Text style={styles.emergencyText}>24/7 Emergency</Text>
                    </View>
                  )}
                  <View style={[styles.bedChip, {
                    backgroundColor: hosp.beds > 5 ? 'rgba(16,185,129,0.10)' : 'rgba(245,158,11,0.10)',
                  }]}>
                    <Text style={[styles.bedText, {
                      color: hosp.beds > 5 ? '#10B981' : '#F59E0B',
                    }]}>{hosp.beds} beds available</Text>
                  </View>
                </View>
              </View>
            </View>
            <View style={styles.hospActions}>
              <Pressable
                onPress={() => {
                  Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                  Linking.openURL(`tel:${hosp.phone}`);
                }}
                style={[styles.hospActionBtn, { backgroundColor: isDark ? 'rgba(16,185,129,0.12)' : 'rgba(16,185,129,0.08)' }]}
              >
                <Ionicons name="call" size={14} color="#10B981" />
                <Text style={[styles.hospActionText, { color: '#10B981' }]}>Call</Text>
              </Pressable>
              <Pressable
                onPress={() => Linking.openURL(`https://maps.google.com/?q=${encodeURIComponent(hosp.name)}`)}
                style={[styles.hospActionBtn, { backgroundColor: isDark ? 'rgba(59,130,246,0.12)' : 'rgba(59,130,246,0.08)' }]}
              >
                <Ionicons name="navigate" size={14} color="#3B82F6" />
                <Text style={[styles.hospActionText, { color: '#3B82F6' }]}>Directions</Text>
              </Pressable>
            </View>
          </GlassCard>
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
    paddingHorizontal: 14, borderWidth: 0.6, marginBottom: 14, gap: 10,
  },
  searchInput: { flex: 1, fontSize: 14 },
  mapPlaceholder: {
    height: 140, borderRadius: 18, borderWidth: 1,
    alignItems: 'center', justifyContent: 'center', marginBottom: 16, gap: 6,
  },
  mapText: { fontSize: 12 },
  hospRow: { flexDirection: 'row', alignItems: 'flex-start' },
  hospIcon: { width: 44, height: 44, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  hospInfo: { flex: 1, marginLeft: 12 },
  hospName: { fontSize: 15, fontWeight: '700' },
  hospMeta: { flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 4 },
  hospDist: { fontSize: 11 },
  ratingBadge: { flexDirection: 'row', alignItems: 'center', gap: 2 },
  ratingText: { fontSize: 11, fontWeight: '700', color: '#F59E0B' },
  hospType: { fontSize: 11 },
  hospChips: { flexDirection: 'row', gap: 6, marginTop: 6 },
  emergencyChip: { backgroundColor: 'rgba(239,68,68,0.10)', paddingHorizontal: 6, paddingVertical: 2, borderRadius: 6 },
  emergencyText: { fontSize: 9, fontWeight: '700', color: '#EF4444' },
  bedChip: { paddingHorizontal: 6, paddingVertical: 2, borderRadius: 6 },
  bedText: { fontSize: 9, fontWeight: '700' },
  hospActions: { flexDirection: 'row', gap: 8, marginTop: 12 },
  hospActionBtn: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, paddingVertical: 8, borderRadius: 10 },
  hospActionText: { fontSize: 12, fontWeight: '600' },
});
