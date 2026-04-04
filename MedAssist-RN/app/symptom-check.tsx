import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable, Dimensions,
} from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import Svg, { Circle as SvgCircle, Ellipse, Line } from 'react-native-svg';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const { width: W } = Dimensions.get('window');

const BODY_REGIONS = [
  { id: 'head', label: 'Head', x: 0.5, y: 0.08, icon: 'ellipse' },
  { id: 'chest', label: 'Chest', x: 0.5, y: 0.28, icon: 'square' },
  { id: 'abdomen', label: 'Abdomen', x: 0.5, y: 0.42, icon: 'square' },
  { id: 'left_arm', label: 'Left Arm', x: 0.28, y: 0.32, icon: 'ellipse' },
  { id: 'right_arm', label: 'Right Arm', x: 0.72, y: 0.32, icon: 'ellipse' },
  { id: 'left_leg', label: 'Left Leg', x: 0.4, y: 0.7, icon: 'ellipse' },
  { id: 'right_leg', label: 'Right Leg', x: 0.6, y: 0.7, icon: 'ellipse' },
  { id: 'back', label: 'Back', x: 0.5, y: 0.35, icon: 'square' },
];

const SENSATIONS = ['Sharp', 'Dull', 'Burning', 'Throbbing', 'Tingling', 'Cramping', 'Pressure', 'Stabbing'];

export default function SymptomCheckScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const [selectedRegion, setSelectedRegion] = useState<string | null>(null);
  const [severity, setSeverity] = useState(5);
  const [selectedSensations, setSelectedSensations] = useState<string[]>([]);

  const bodyH = W * 0.9;

  const toggleSensation = (s: string) => {
    setSelectedSensations((prev) =>
      prev.includes(s) ? prev.filter((x) => x !== s) : [...prev, s]
    );
  };

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Symptom Check</Text>
        </View>
        <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
          Tap the body area where you feel discomfort
        </Text>

        {/* Body Map */}
        <GlassCard radius={24} blur={18} padding={16}>
          <View style={[styles.bodyMap, { height: bodyH }]}>
            {/* Simple body silhouette using SVG */}
            <Svg width="100%" height="100%" viewBox="0 0 200 400">
              {/* Head */}
              <SvgCircle cx={100} cy={35} r={25} fill={selectedRegion === 'head' ? '#3B82F620' : (isDark ? '#ffffff08' : '#00000008')} stroke={selectedRegion === 'head' ? '#3B82F6' : (isDark ? '#ffffff20' : '#00000015')} strokeWidth={1.5} />
              {/* Body */}
              <Ellipse cx={100} cy={130} rx={45} ry={70} fill={selectedRegion === 'chest' || selectedRegion === 'abdomen' ? '#3B82F620' : (isDark ? '#ffffff08' : '#00000008')} stroke={selectedRegion === 'chest' || selectedRegion === 'abdomen' ? '#3B82F6' : (isDark ? '#ffffff20' : '#00000015')} strokeWidth={1.5} />
              {/* Arms */}
              <Line x1={55} y1={80} x2={20} y2={180} stroke={selectedRegion === 'left_arm' ? '#3B82F6' : (isDark ? '#ffffff25' : '#00000020')} strokeWidth={12} strokeLinecap="round" />
              <Line x1={145} y1={80} x2={180} y2={180} stroke={selectedRegion === 'right_arm' ? '#3B82F6' : (isDark ? '#ffffff25' : '#00000020')} strokeWidth={12} strokeLinecap="round" />
              {/* Legs */}
              <Line x1={80} y1={195} x2={70} y2={350} stroke={selectedRegion === 'left_leg' ? '#3B82F6' : (isDark ? '#ffffff25' : '#00000020')} strokeWidth={14} strokeLinecap="round" />
              <Line x1={120} y1={195} x2={130} y2={350} stroke={selectedRegion === 'right_leg' ? '#3B82F6' : (isDark ? '#ffffff25' : '#00000020')} strokeWidth={14} strokeLinecap="round" />
            </Svg>

            {/* Tap targets */}
            {BODY_REGIONS.map((r) => (
              <Pressable
                key={r.id}
                onPress={() => {
                  Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                  setSelectedRegion(r.id);
                }}
                style={[styles.bodyTap, { left: `${r.x * 100 - 8}%`, top: `${r.y * 100 - 3}%` }]}
              >
                {selectedRegion === r.id && (
                  <View style={styles.selectedDot} />
                )}
              </Pressable>
            ))}
          </View>

          {selectedRegion && (
            <View style={styles.selectedLabel}>
              <Ionicons name="location" size={14} color="#3B82F6" />
              <Text style={[styles.selectedText, { color: colors.textPrimary }]}>
                {BODY_REGIONS.find((r) => r.id === selectedRegion)?.label}
              </Text>
            </View>
          )}
        </GlassCard>

        {/* Severity slider */}
        {selectedRegion && (
          <>
            <GlassCard radius={18} blur={14} padding={16} style={{ marginTop: 14 }}>
              <Text style={[styles.sectionLabel, { color: colors.textPrimary }]}>Pain Severity</Text>
              <View style={styles.severityRow}>
                {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((n) => (
                  <Pressable
                    key={n}
                    onPress={() => setSeverity(n)}
                    style={[
                      styles.sevDot,
                      {
                        backgroundColor: n <= severity
                          ? (n <= 3 ? '#10B981' : n <= 6 ? '#F59E0B' : '#EF4444')
                          : (isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)'),
                      },
                    ]}
                  >
                    <Text style={[styles.sevNum, { color: n <= severity ? '#FFF' : colors.textSecondary }]}>{n}</Text>
                  </Pressable>
                ))}
              </View>
            </GlassCard>

            {/* Sensations */}
            <GlassCard radius={18} blur={14} padding={16} style={{ marginTop: 14 }}>
              <Text style={[styles.sectionLabel, { color: colors.textPrimary }]}>Sensation Type</Text>
              <View style={styles.chipGrid}>
                {SENSATIONS.map((s) => {
                  const active = selectedSensations.includes(s);
                  return (
                    <Pressable
                      key={s}
                      onPress={() => toggleSensation(s)}
                      style={[styles.sensChip, {
                        backgroundColor: active ? 'rgba(59,130,246,0.12)' : (isDark ? 'rgba(255,255,255,0.05)' : '#F1F5F9'),
                        borderColor: active ? '#3B82F6' : (isDark ? 'rgba(255,255,255,0.08)' : '#E2E8F0'),
                      }]}
                    >
                      <Text style={[styles.sensText, { color: active ? '#3B82F6' : colors.textSecondary }]}>{s}</Text>
                    </Pressable>
                  );
                })}
              </View>
            </GlassCard>

            {/* Continue button */}
            <Pressable
              onPress={() => {
                Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
                router.push('/symptom-chat');
              }}
              style={{ marginTop: 16 }}
            >
              <LinearGradient colors={['#3B82F6', '#2563EB']} style={styles.continueBtn}>
                <Ionicons name="chatbubble-ellipses" size={18} color="#FFF" />
                <Text style={styles.continueBtnText}>Start AI Consultation</Text>
              </LinearGradient>
            </Pressable>
          </>
        )}

        <View style={{ height: 40 }} />
      </ScrollView>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingHorizontal: 16, paddingTop: 60 },
  headerRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginBottom: 4 },
  backBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 22, fontWeight: '800' },
  subtitle: { fontSize: 13, marginBottom: 16 },
  bodyMap: { position: 'relative' },
  bodyTap: {
    position: 'absolute', width: 40, height: 40, borderRadius: 20,
  },
  selectedDot: {
    width: 16, height: 16, borderRadius: 8, backgroundColor: '#3B82F6',
    borderWidth: 3, borderColor: '#FFF',
    shadowColor: '#3B82F6', shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.5, shadowRadius: 8, elevation: 6,
    alignSelf: 'center', marginTop: 12,
  },
  selectedLabel: { flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: 10, alignSelf: 'center' },
  selectedText: { fontSize: 14, fontWeight: '700' },
  sectionLabel: { fontSize: 14, fontWeight: '700', marginBottom: 10 },
  severityRow: { flexDirection: 'row', justifyContent: 'space-between' },
  sevDot: {
    width: 28, height: 28, borderRadius: 14, alignItems: 'center', justifyContent: 'center',
  },
  sevNum: { fontSize: 11, fontWeight: '700' },
  chipGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  sensChip: { paddingHorizontal: 14, paddingVertical: 8, borderRadius: 20, borderWidth: 0.6 },
  sensText: { fontSize: 12, fontWeight: '600' },
  continueBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    height: 52, borderRadius: 14,
    shadowColor: '#3B82F6', shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.30, shadowRadius: 12, elevation: 6,
  },
  continueBtnText: { fontSize: 15, fontWeight: '700', color: '#FFF' },
});
