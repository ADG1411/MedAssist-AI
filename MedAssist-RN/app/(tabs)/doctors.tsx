import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TextInput, Pressable, Image,
} from 'react-native';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../../src/shared/components/AppBackground';
import { GlassCard } from '../../src/shared/components/GlassCard';
import { useAppTheme } from '../../src/core/theme/useTheme';

const SPECIALTIES = ['All', 'General', 'Cardiology', 'Dermatology', 'Neurology', 'Orthopedics', 'Pediatrics'];

const MOCK_DOCTORS = [
  { id: '1', name: 'Dr. Priya Sharma', specialty: 'General', rating: 4.9, reviews: 234, experience: '12 yrs', fee: '₹500', available: true, avatar: null },
  { id: '2', name: 'Dr. Arun Mehta', specialty: 'Cardiology', rating: 4.8, reviews: 189, experience: '15 yrs', fee: '₹800', available: true, avatar: null },
  { id: '3', name: 'Dr. Kavitha R.', specialty: 'Dermatology', rating: 4.7, reviews: 156, experience: '8 yrs', fee: '₹600', available: false, avatar: null },
  { id: '4', name: 'Dr. Rajesh Kumar', specialty: 'Neurology', rating: 4.9, reviews: 201, experience: '20 yrs', fee: '₹1000', available: true, avatar: null },
  { id: '5', name: 'Dr. Sneha Patel', specialty: 'Pediatrics', rating: 4.6, reviews: 145, experience: '10 yrs', fee: '₹550', available: true, avatar: null },
  { id: '6', name: 'Dr. Vikram Singh', specialty: 'Orthopedics', rating: 4.8, reviews: 178, experience: '14 yrs', fee: '₹750', available: true, avatar: null },
];

export default function DoctorsScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const [search, setSearch] = useState('');
  const [selectedSpec, setSelectedSpec] = useState('All');

  const filtered = MOCK_DOCTORS.filter((d) => {
    const matchSearch = d.name.toLowerCase().includes(search.toLowerCase());
    const matchSpec = selectedSpec === 'All' || d.specialty === selectedSpec;
    return matchSearch && matchSpec;
  });

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <Text style={[styles.title, { color: colors.textPrimary }]}>Find Doctors</Text>
        <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
          Book consultations with top specialists
        </Text>

        {/* Search */}
        <View style={[styles.searchBar, {
          backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : '#F1F5F9',
          borderColor: isDark ? 'rgba(255,255,255,0.08)' : '#E2E8F0',
        }]}>
          <Ionicons name="search" size={18} color={colors.textSecondary} />
          <TextInput
            style={[styles.searchInput, { color: colors.textPrimary }]}
            placeholder="Search doctors..."
            placeholderTextColor={colors.textSecondary}
            value={search}
            onChangeText={setSearch}
          />
        </View>

        {/* Specialty chips */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.chipScroll} contentContainerStyle={styles.chipRow}>
          {SPECIALTIES.map((s) => (
            <Pressable
              key={s}
              onPress={() => setSelectedSpec(s)}
              style={[
                styles.chip,
                {
                  backgroundColor: s === selectedSpec ? '#2A7FFF' : (isDark ? 'rgba(255,255,255,0.06)' : '#F1F5F9'),
                  borderColor: s === selectedSpec ? '#2A7FFF' : (isDark ? 'rgba(255,255,255,0.10)' : '#E2E8F0'),
                },
              ]}
            >
              <Text style={[styles.chipText, {
                color: s === selectedSpec ? '#FFF' : colors.textSecondary,
                fontWeight: s === selectedSpec ? '700' : '500',
              }]}>{s}</Text>
            </Pressable>
          ))}
        </ScrollView>

        {/* Doctor cards */}
        {filtered.map((doc) => (
          <Pressable
            key={doc.id}
            onPress={() => {
              Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
              router.push({ pathname: '/doctor-detail', params: { doctor: JSON.stringify(doc) } });
            }}
          >
            <GlassCard radius={20} blur={16} padding={16} style={styles.doctorCard}>
              <View style={styles.docRow}>
                <View style={[styles.avatarCircle, { backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#EAF3FF' }]}>
                  <Text style={styles.avatarLetter}>{doc.name[4]}</Text>
                </View>
                <View style={styles.docInfo}>
                  <Text style={[styles.docName, { color: colors.textPrimary }]}>{doc.name}</Text>
                  <Text style={[styles.docSpec, { color: colors.textSecondary }]}>{doc.specialty} · {doc.experience}</Text>
                  <View style={styles.ratingRow}>
                    <Ionicons name="star" size={12} color="#F59E0B" />
                    <Text style={styles.ratingText}>{doc.rating}</Text>
                    <Text style={[styles.reviewsText, { color: colors.textSecondary }]}>({doc.reviews})</Text>
                  </View>
                </View>
                <View style={styles.docRight}>
                  <Text style={[styles.feeText, { color: colors.textPrimary }]}>{doc.fee}</Text>
                  <View style={[styles.availBadge, {
                    backgroundColor: doc.available ? 'rgba(16,185,129,0.12)' : 'rgba(239,68,68,0.12)',
                  }]}>
                    <View style={[styles.availDot, { backgroundColor: doc.available ? '#10B981' : '#EF4444' }]} />
                    <Text style={[styles.availText, { color: doc.available ? '#10B981' : '#EF4444' }]}>
                      {doc.available ? 'Available' : 'Busy'}
                    </Text>
                  </View>
                </View>
              </View>
            </GlassCard>
          </Pressable>
        ))}

        <View style={{ height: 120 }} />
      </ScrollView>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingHorizontal: 16, paddingTop: 60 },
  title: { fontSize: 26, fontWeight: '800', letterSpacing: -0.5 },
  subtitle: { fontSize: 13, marginTop: 4, marginBottom: 16 },
  searchBar: {
    flexDirection: 'row', alignItems: 'center', height: 46, borderRadius: 14,
    paddingHorizontal: 14, borderWidth: 0.6, marginBottom: 14, gap: 10,
  },
  searchInput: { flex: 1, fontSize: 14 },
  chipScroll: { marginBottom: 16 },
  chipRow: { gap: 8 },
  chip: { paddingHorizontal: 14, paddingVertical: 7, borderRadius: 20, borderWidth: 0.6 },
  chipText: { fontSize: 12 },
  doctorCard: { marginBottom: 10 },
  docRow: { flexDirection: 'row', alignItems: 'center' },
  avatarCircle: { width: 48, height: 48, borderRadius: 24, alignItems: 'center', justifyContent: 'center' },
  avatarLetter: { fontSize: 20, fontWeight: '700', color: '#2A7FFF' },
  docInfo: { flex: 1, marginLeft: 12 },
  docName: { fontSize: 15, fontWeight: '700' },
  docSpec: { fontSize: 11, marginTop: 2 },
  ratingRow: { flexDirection: 'row', alignItems: 'center', gap: 3, marginTop: 4 },
  ratingText: { fontSize: 11, fontWeight: '700', color: '#F59E0B' },
  reviewsText: { fontSize: 10 },
  docRight: { alignItems: 'flex-end' },
  feeText: { fontSize: 15, fontWeight: '800' },
  availBadge: { flexDirection: 'row', alignItems: 'center', gap: 4, paddingHorizontal: 8, paddingVertical: 3, borderRadius: 8, marginTop: 6 },
  availDot: { width: 5, height: 5, borderRadius: 2.5 },
  availText: { fontSize: 9, fontWeight: '700' },
});
