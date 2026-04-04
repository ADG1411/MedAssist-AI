import React from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable,
} from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

export default function PostConsultScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        {/* Success header */}
        <View style={styles.successWrap}>
          <View style={styles.checkCircle}>
            <Ionicons name="checkmark" size={40} color="#FFF" />
          </View>
          <Text style={[styles.successTitle, { color: colors.textPrimary }]}>Consultation Complete</Text>
          <Text style={[styles.successSub, { color: colors.textSecondary }]}>
            Your session with Dr. Priya Sharma has ended
          </Text>
        </View>

        {/* Summary */}
        <GlassCard radius={24} blur={20} padding={18}>
          <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>Session Summary</Text>
          <View style={styles.summaryRow}>
            <Ionicons name="time" size={16} color="#6366F1" />
            <Text style={[styles.summaryText, { color: colors.textPrimary }]}>Duration: 15 minutes</Text>
          </View>
          <View style={styles.summaryRow}>
            <Ionicons name="medical" size={16} color="#3B82F6" />
            <Text style={[styles.summaryText, { color: colors.textPrimary }]}>Diagnosis: Acute Gastritis</Text>
          </View>
          <View style={styles.summaryRow}>
            <Ionicons name="document-text" size={16} color="#10B981" />
            <Text style={[styles.summaryText, { color: colors.textPrimary }]}>Prescription: Updated</Text>
          </View>
          <View style={styles.summaryRow}>
            <Ionicons name="calendar" size={16} color="#F59E0B" />
            <Text style={[styles.summaryText, { color: colors.textPrimary }]}>Follow-up: 5 days</Text>
          </View>
        </GlassCard>

        {/* Prescription */}
        <GlassCard radius={20} blur={16} padding={16} style={{ marginTop: 14 }}>
          <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>
            <Ionicons name="document-text" size={16} color="#10B981" /> Prescription
          </Text>
          {[
            { name: 'Omeprazole 20mg', dose: '1 tablet before breakfast', duration: '14 days' },
            { name: 'Antacid Gel', dose: '10ml after meals', duration: '7 days' },
            { name: 'Probiotics', dose: '1 capsule daily', duration: '30 days' },
          ].map((med, i) => (
            <View key={i} style={[styles.medRow, {
              borderColor: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.04)',
            }]}>
              <View style={[styles.medIcon, { backgroundColor: 'rgba(16,185,129,0.10)' }]}>
                <Ionicons name="medkit" size={14} color="#10B981" />
              </View>
              <View style={styles.medInfo}>
                <Text style={[styles.medName, { color: colors.textPrimary }]}>{med.name}</Text>
                <Text style={[styles.medDose, { color: colors.textSecondary }]}>{med.dose} · {med.duration}</Text>
              </View>
            </View>
          ))}
        </GlassCard>

        {/* Actions */}
        <View style={styles.actionsCol}>
          <Pressable onPress={() => { Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium); router.push('/pharmacy'); }}>
            <LinearGradient colors={['#10B981', '#059669']} style={styles.actionBtn}>
              <Ionicons name="medkit" size={18} color="#FFF" />
              <Text style={styles.actionBtnText}>Order Medicines</Text>
            </LinearGradient>
          </Pressable>

          <Pressable
            onPress={() => { Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light); router.replace('/(tabs)/home'); }}
            style={[styles.homeBtn, { backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : '#F1F5F9' }]}
          >
            <Ionicons name="home" size={18} color="#2A7FFF" />
            <Text style={styles.homeBtnText}>Back to Dashboard</Text>
          </Pressable>
        </View>

        <View style={{ height: 40 }} />
      </ScrollView>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingHorizontal: 16, paddingTop: 60 },
  successWrap: { alignItems: 'center', marginBottom: 24 },
  checkCircle: {
    width: 72, height: 72, borderRadius: 36, backgroundColor: '#10B981',
    alignItems: 'center', justifyContent: 'center', marginBottom: 16,
    shadowColor: '#10B981', shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.35, shadowRadius: 16, elevation: 8,
  },
  successTitle: { fontSize: 22, fontWeight: '800' },
  successSub: { fontSize: 13, marginTop: 6, textAlign: 'center' },
  sectionTitle: { fontSize: 15, fontWeight: '700', marginBottom: 12 },
  summaryRow: { flexDirection: 'row', alignItems: 'center', gap: 10, marginBottom: 10 },
  summaryText: { fontSize: 13, fontWeight: '600' },
  medRow: {
    flexDirection: 'row', alignItems: 'center', paddingVertical: 10,
    borderBottomWidth: 0.5, gap: 10,
  },
  medIcon: { width: 32, height: 32, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  medInfo: { flex: 1 },
  medName: { fontSize: 13, fontWeight: '700' },
  medDose: { fontSize: 11, marginTop: 2 },
  actionsCol: { gap: 10, marginTop: 20 },
  actionBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    height: 52, borderRadius: 14,
    shadowColor: '#10B981', shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25, shadowRadius: 12, elevation: 6,
  },
  actionBtnText: { fontSize: 15, fontWeight: '700', color: '#FFF' },
  homeBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    height: 48, borderRadius: 14,
  },
  homeBtnText: { fontSize: 14, fontWeight: '600', color: '#2A7FFF' },
});
