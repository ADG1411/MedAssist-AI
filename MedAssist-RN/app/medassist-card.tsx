import React from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable, Dimensions,
} from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';
import { useAuthStore } from '../src/core/store/authStore';

const { width: W } = Dimensions.get('window');

export default function MedAssistCardScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const { profile } = useAuthStore();

  const fullName = (profile as any)?.full_name ?? 'Patient Name';
  const email = (profile as any)?.email ?? 'user@medassist.ai';
  const memberId = 'MA-2026-' + ((profile as any)?.id?.substring(0, 6)?.toUpperCase() ?? '7A3F2B');

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Health ID Card</Text>
        </View>

        {/* Card front */}
        <LinearGradient
          colors={['#1E40AF', '#3B82F6', '#60A5FA']}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={styles.card}
        >
          <View style={styles.cardHeader}>
            <View style={styles.cardLogoRow}>
              <View style={styles.cardLogo}>
                <Text style={styles.cardLogoText}>+</Text>
              </View>
              <Text style={styles.cardBrand}>MedAssist AI</Text>
            </View>
            <View style={styles.cardTypeBadge}>
              <Text style={styles.cardTypeText}>Premium</Text>
            </View>
          </View>

          <View style={styles.cardBody}>
            <Text style={styles.cardName}>{fullName}</Text>
            <Text style={styles.cardId}>ID: {memberId}</Text>
          </View>

          <View style={styles.cardFooter}>
            <View>
              <Text style={styles.cardLabel}>Blood Group</Text>
              <Text style={styles.cardValue}>O+</Text>
            </View>
            <View>
              <Text style={styles.cardLabel}>Allergies</Text>
              <Text style={styles.cardValue}>None</Text>
            </View>
            <View>
              <Text style={styles.cardLabel}>Emergency</Text>
              <Text style={styles.cardValue}>+91-9876543210</Text>
            </View>
          </View>

          {/* Decorative circles */}
          <View style={styles.decoCircle1} />
          <View style={styles.decoCircle2} />
        </LinearGradient>

        {/* Details */}
        <GlassCard radius={20} blur={16} padding={16} style={{ marginTop: 16 }}>
          <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>Card Details</Text>
          {[
            { label: 'Member Since', value: 'January 2026', icon: 'calendar' },
            { label: 'Email', value: email, icon: 'mail' },
            { label: 'Plan', value: 'Premium', icon: 'diamond' },
            { label: 'Chronic Conditions', value: 'None reported', icon: 'medical' },
            { label: 'Current Medications', value: 'Omeprazole 20mg', icon: 'medkit' },
            { label: 'Insurance', value: 'Not linked', icon: 'shield-checkmark' },
          ].map((item, i) => (
            <View key={i} style={[styles.detailRow, {
              borderBottomWidth: i < 5 ? 0.5 : 0,
              borderBottomColor: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.06)',
            }]}>
              <Ionicons name={item.icon as any} size={16} color="#3B82F6" />
              <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>{item.label}</Text>
              <Text style={[styles.detailValue, { color: colors.textPrimary }]}>{item.value}</Text>
            </View>
          ))}
        </GlassCard>

        {/* QR placeholder */}
        <GlassCard radius={20} blur={16} padding={20} style={{ marginTop: 14, alignItems: 'center' }}>
          <View style={[styles.qrPlaceholder, {
            backgroundColor: isDark ? 'rgba(255,255,255,0.04)' : 'rgba(0,0,0,0.03)',
          }]}>
            <Ionicons name="qr-code" size={64} color={isDark ? 'rgba(255,255,255,0.20)' : 'rgba(0,0,0,0.15)'} />
          </View>
          <Text style={[styles.qrHint, { color: colors.textSecondary }]}>
            Show this QR code at hospitals for instant record access
          </Text>
        </GlassCard>

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
  card: {
    width: W - 32, borderRadius: 20, padding: 24, overflow: 'hidden',
    shadowColor: '#1E40AF', shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.35, shadowRadius: 20, elevation: 12,
  },
  cardHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 },
  cardLogoRow: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  cardLogo: {
    width: 28, height: 28, borderRadius: 14, backgroundColor: 'rgba(255,255,255,0.20)',
    alignItems: 'center', justifyContent: 'center',
  },
  cardLogoText: { fontSize: 16, fontWeight: '300', color: '#FFF' },
  cardBrand: { fontSize: 14, fontWeight: '700', color: '#FFF', letterSpacing: 0.5 },
  cardTypeBadge: { backgroundColor: 'rgba(255,255,255,0.20)', paddingHorizontal: 8, paddingVertical: 3, borderRadius: 8 },
  cardTypeText: { fontSize: 10, fontWeight: '700', color: '#FFF' },
  cardBody: { marginBottom: 24 },
  cardName: { fontSize: 20, fontWeight: '800', color: '#FFF', letterSpacing: 0.3 },
  cardId: { fontSize: 12, color: 'rgba(255,255,255,0.70)', marginTop: 4, fontWeight: '600', letterSpacing: 1 },
  cardFooter: { flexDirection: 'row', justifyContent: 'space-between' },
  cardLabel: { fontSize: 9, color: 'rgba(255,255,255,0.50)', fontWeight: '600', letterSpacing: 0.3 },
  cardValue: { fontSize: 12, color: '#FFF', fontWeight: '700', marginTop: 2 },
  decoCircle1: {
    position: 'absolute', top: -30, right: -30,
    width: 100, height: 100, borderRadius: 50, backgroundColor: 'rgba(255,255,255,0.08)',
  },
  decoCircle2: {
    position: 'absolute', bottom: -20, left: -20,
    width: 80, height: 80, borderRadius: 40, backgroundColor: 'rgba(255,255,255,0.05)',
  },
  sectionTitle: { fontSize: 15, fontWeight: '700', marginBottom: 12 },
  detailRow: { flexDirection: 'row', alignItems: 'center', gap: 10, paddingVertical: 10 },
  detailLabel: { flex: 1, fontSize: 12 },
  detailValue: { fontSize: 12, fontWeight: '600' },
  qrPlaceholder: {
    width: 120, height: 120, borderRadius: 14,
    alignItems: 'center', justifyContent: 'center', marginBottom: 12,
  },
  qrHint: { fontSize: 12, textAlign: 'center' },
});
