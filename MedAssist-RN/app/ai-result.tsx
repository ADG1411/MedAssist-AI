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

const MOCK_RESULT = {
  condition: 'Acute Gastritis',
  confidence: 82,
  risk: 'moderate',
  reasoning: 'Based on reported symptoms of epigastric pain, nausea, and burning sensation after meals, combined with medication history.',
  recommendations: [
    'Continue prescribed Omeprazole 20mg before breakfast',
    'Avoid spicy, acidic, and fried foods for 2 weeks',
    'Increase water intake to 8-10 glasses daily',
    'Schedule follow-up if symptoms persist beyond 5 days',
  ],
  differentials: [
    { name: 'GERD', probability: 65 },
    { name: 'Peptic Ulcer', probability: 25 },
    { name: 'Functional Dyspepsia', probability: 10 },
  ],
};

export default function AiResultScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const riskColor = MOCK_RESULT.risk === 'high' ? '#EF4444' : MOCK_RESULT.risk === 'moderate' ? '#F59E0B' : '#10B981';

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>AI Analysis</Text>
        </View>

        {/* Main diagnosis card */}
        <GlassCard radius={24} blur={20} padding={20}>
          <View style={styles.diagHeader}>
            <View style={[styles.diagIcon, { backgroundColor: `${riskColor}14` }]}>
              <Ionicons name="medical" size={28} color={riskColor} />
            </View>
            <View style={styles.diagInfo}>
              <Text style={[styles.diagName, { color: colors.textPrimary }]}>{MOCK_RESULT.condition}</Text>
              <View style={styles.diagMeta}>
                <View style={[styles.confBadge, { backgroundColor: `${riskColor}14` }]}>
                  <Text style={[styles.confText, { color: riskColor }]}>{MOCK_RESULT.confidence}% confidence</Text>
                </View>
                <View style={[styles.riskBadge, { backgroundColor: `${riskColor}14` }]}>
                  <Text style={[styles.riskText, { color: riskColor }]}>{MOCK_RESULT.risk.toUpperCase()} RISK</Text>
                </View>
              </View>
            </View>
          </View>

          <Text style={[styles.reasoning, { color: colors.textSecondary }]}>{MOCK_RESULT.reasoning}</Text>
        </GlassCard>

        {/* Recommendations */}
        <GlassCard radius={20} blur={16} padding={18} style={{ marginTop: 14 }}>
          <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>
            <Ionicons name="checkmark-circle" size={16} color="#10B981" /> Recommendations
          </Text>
          {MOCK_RESULT.recommendations.map((rec, i) => (
            <View key={i} style={styles.recRow}>
              <View style={styles.recDot} />
              <Text style={[styles.recText, { color: colors.textPrimary }]}>{rec}</Text>
            </View>
          ))}
        </GlassCard>

        {/* Differentials */}
        <GlassCard radius={20} blur={16} padding={18} style={{ marginTop: 14 }}>
          <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>
            <Ionicons name="analytics" size={16} color="#6366F1" /> Differential Diagnoses
          </Text>
          {MOCK_RESULT.differentials.map((d, i) => (
            <View key={i} style={styles.diffRow}>
              <Text style={[styles.diffName, { color: colors.textPrimary }]}>{d.name}</Text>
              <View style={[styles.diffBarBg, { backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)' }]}>
                <View style={[styles.diffBarFill, { width: `${d.probability}%`, backgroundColor: '#6366F1' }]} />
              </View>
              <Text style={[styles.diffPct, { color: '#6366F1' }]}>{d.probability}%</Text>
            </View>
          ))}
        </GlassCard>

        {/* Actions */}
        <View style={styles.actionsRow}>
          <Pressable
            onPress={() => { Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium); router.push('/(tabs)/doctors'); }}
            style={{ flex: 1 }}
          >
            <LinearGradient colors={['#6366F1', '#4F46E5']} style={styles.actionBtn}>
              <Ionicons name="people" size={16} color="#FFF" />
              <Text style={styles.actionBtnText}>Book Doctor</Text>
            </LinearGradient>
          </Pressable>
          <Pressable
            onPress={() => { Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium); router.push('/deep-check'); }}
            style={{ flex: 1 }}
          >
            <LinearGradient colors={['#3B82F6', '#2563EB']} style={styles.actionBtn}>
              <Ionicons name="search" size={16} color="#FFF" />
              <Text style={styles.actionBtnText}>Deep Check</Text>
            </LinearGradient>
          </Pressable>
        </View>

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
  diagHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 14 },
  diagIcon: { width: 56, height: 56, borderRadius: 18, alignItems: 'center', justifyContent: 'center' },
  diagInfo: { flex: 1, marginLeft: 14 },
  diagName: { fontSize: 20, fontWeight: '800' },
  diagMeta: { flexDirection: 'row', gap: 8, marginTop: 6 },
  confBadge: { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 8 },
  confText: { fontSize: 10, fontWeight: '700' },
  riskBadge: { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 8 },
  riskText: { fontSize: 10, fontWeight: '800', letterSpacing: 0.3 },
  reasoning: { fontSize: 13, lineHeight: 19 },
  sectionTitle: { fontSize: 15, fontWeight: '700', marginBottom: 12 },
  recRow: { flexDirection: 'row', alignItems: 'flex-start', gap: 8, marginBottom: 8 },
  recDot: { width: 6, height: 6, borderRadius: 3, backgroundColor: '#10B981', marginTop: 6 },
  recText: { flex: 1, fontSize: 13, lineHeight: 19 },
  diffRow: { flexDirection: 'row', alignItems: 'center', gap: 10, marginBottom: 10 },
  diffName: { width: 110, fontSize: 13, fontWeight: '600' },
  diffBarBg: { flex: 1, height: 6, borderRadius: 3, overflow: 'hidden' },
  diffBarFill: { height: 6, borderRadius: 3 },
  diffPct: { width: 35, fontSize: 12, fontWeight: '700', textAlign: 'right' },
  actionsRow: { flexDirection: 'row', gap: 10, marginTop: 16 },
  actionBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    height: 48, borderRadius: 14,
    shadowColor: '#000', shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15, shadowRadius: 12, elevation: 6,
  },
  actionBtnText: { fontSize: 14, fontWeight: '700', color: '#FFF' },
});
