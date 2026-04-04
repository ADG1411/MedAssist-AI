import React from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable,
} from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

export default function DoctorDetailScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const { doctor: docJSON } = useLocalSearchParams<{ doctor?: string }>();

  const doc = docJSON ? JSON.parse(docJSON) : {
    name: 'Dr. Priya Sharma', specialty: 'General Medicine', rating: 4.9,
    reviews: 234, experience: '12 yrs', fee: '₹500', available: true,
  };

  const SLOTS = ['10:00 AM', '11:30 AM', '2:00 PM', '3:30 PM', '5:00 PM'];
  const [selectedSlot, setSelectedSlot] = React.useState<string | null>(null);

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Doctor Profile</Text>
        </View>

        {/* Profile card */}
        <GlassCard radius={24} blur={20} padding={24}>
          <View style={styles.profileRow}>
            <View style={[styles.avatar, { backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#EAF3FF' }]}>
              <Text style={styles.avatarText}>{doc.name?.[4] ?? 'D'}</Text>
            </View>
            <View style={styles.profileInfo}>
              <Text style={[styles.docName, { color: colors.textPrimary }]}>{doc.name}</Text>
              <Text style={[styles.docSpec, { color: colors.textSecondary }]}>{doc.specialty}</Text>
              <View style={styles.ratingRow}>
                <Ionicons name="star" size={14} color="#F59E0B" />
                <Text style={styles.ratingText}>{doc.rating}</Text>
                <Text style={[styles.reviewsText, { color: colors.textSecondary }]}>({doc.reviews} reviews)</Text>
              </View>
            </View>
          </View>

          {/* Stats */}
          <View style={styles.statsRow}>
            {[
              { label: 'Experience', value: doc.experience, icon: 'time' },
              { label: 'Fee', value: doc.fee, icon: 'cash' },
              { label: 'Patients', value: '2.4K+', icon: 'people' },
            ].map((s, i) => (
              <View key={i} style={[styles.statCard, {
                backgroundColor: isDark ? 'rgba(255,255,255,0.04)' : 'rgba(0,0,0,0.02)',
              }]}>
                <Ionicons name={s.icon as any} size={16} color="#2A7FFF" />
                <Text style={[styles.statValue, { color: colors.textPrimary }]}>{s.value}</Text>
                <Text style={[styles.statLabel, { color: colors.textSecondary }]}>{s.label}</Text>
              </View>
            ))}
          </View>
        </GlassCard>

        {/* About */}
        <GlassCard radius={20} blur={16} padding={16} style={{ marginTop: 14 }}>
          <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>About</Text>
          <Text style={[styles.aboutText, { color: colors.textSecondary }]}>
            Experienced physician specializing in {doc.specialty?.toLowerCase() ?? 'general medicine'} with {doc.experience} of clinical practice.
            Committed to patient-centered care with a focus on preventive medicine and holistic health management.
          </Text>
        </GlassCard>

        {/* Appointment slots */}
        <GlassCard radius={20} blur={16} padding={16} style={{ marginTop: 14 }}>
          <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>Available Slots</Text>
          <Text style={[styles.dateLabel, { color: colors.textSecondary }]}>Tomorrow</Text>
          <View style={styles.slotsGrid}>
            {SLOTS.map((slot) => (
              <Pressable
                key={slot}
                onPress={() => {
                  Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                  setSelectedSlot(slot);
                }}
                style={[styles.slotChip, {
                  backgroundColor: selectedSlot === slot ? '#2A7FFF' : (isDark ? 'rgba(255,255,255,0.06)' : '#F1F5F9'),
                  borderColor: selectedSlot === slot ? '#2A7FFF' : (isDark ? 'rgba(255,255,255,0.10)' : '#E2E8F0'),
                }]}
              >
                <Text style={[styles.slotText, {
                  color: selectedSlot === slot ? '#FFF' : colors.textPrimary,
                }]}>{slot}</Text>
              </Pressable>
            ))}
          </View>
        </GlassCard>

        {/* Book button */}
        <Pressable
          onPress={() => {
            Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
            router.push('/consultation');
          }}
          disabled={!selectedSlot}
          style={{ marginTop: 16, opacity: selectedSlot ? 1 : 0.4 }}
        >
          <LinearGradient colors={['#3B82F6', '#2563EB']} style={styles.bookBtn}>
            <Ionicons name="videocam" size={18} color="#FFF" />
            <Text style={styles.bookBtnText}>Book Consultation</Text>
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
  title: { fontSize: 22, fontWeight: '800' },
  profileRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 20 },
  avatar: { width: 64, height: 64, borderRadius: 32, alignItems: 'center', justifyContent: 'center' },
  avatarText: { fontSize: 26, fontWeight: '700', color: '#2A7FFF' },
  profileInfo: { flex: 1, marginLeft: 16 },
  docName: { fontSize: 20, fontWeight: '800' },
  docSpec: { fontSize: 13, marginTop: 2 },
  ratingRow: { flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 6 },
  ratingText: { fontSize: 13, fontWeight: '700', color: '#F59E0B' },
  reviewsText: { fontSize: 11 },
  statsRow: { flexDirection: 'row', gap: 8 },
  statCard: { flex: 1, alignItems: 'center', paddingVertical: 12, borderRadius: 14, gap: 4 },
  statValue: { fontSize: 14, fontWeight: '800' },
  statLabel: { fontSize: 10, fontWeight: '500' },
  sectionTitle: { fontSize: 15, fontWeight: '700', marginBottom: 10 },
  aboutText: { fontSize: 13, lineHeight: 19 },
  dateLabel: { fontSize: 12, fontWeight: '600', marginBottom: 8 },
  slotsGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  slotChip: { paddingHorizontal: 16, paddingVertical: 10, borderRadius: 12, borderWidth: 0.6 },
  slotText: { fontSize: 13, fontWeight: '600' },
  bookBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    height: 52, borderRadius: 14,
    shadowColor: '#3B82F6', shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25, shadowRadius: 12, elevation: 6,
  },
  bookBtnText: { fontSize: 15, fontWeight: '700', color: '#FFF' },
});
