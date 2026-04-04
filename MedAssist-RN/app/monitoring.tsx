import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable, TextInput,
} from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const LOG_FIELDS = [
  { key: 'pain', label: 'Pain Level', icon: 'flash', color: '#EF4444', type: 'slider', max: 10 },
  { key: 'sleep', label: 'Sleep Hours', icon: 'moon', color: '#8B5CF6', type: 'number', unit: 'hrs' },
  { key: 'hydration', label: 'Water Intake', icon: 'water', color: '#06B6D4', type: 'number', unit: 'cups' },
  { key: 'mood', label: 'Mood', icon: 'happy', color: '#F59E0B', type: 'mood' },
  { key: 'energy', label: 'Energy Level', icon: 'battery-charging', color: '#10B981', type: 'slider', max: 10 },
];

const MOODS = ['😫', '😟', '😐', '🙂', '😄'];

const HISTORY = [
  { date: 'Today', pain: 3, sleep: 6.2, hydration: 5, mood: '🙂', energy: 6 },
  { date: 'Yesterday', pain: 4, sleep: 5.8, hydration: 4, mood: '😐', energy: 5 },
  { date: 'Apr 2', pain: 5, sleep: 7.0, hydration: 6, mood: '🙂', energy: 7 },
];

export default function MonitoringScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const [values, setValues] = useState<Record<string, any>>({
    pain: 3, sleep: '6.5', hydration: '5', mood: 3, energy: 6,
  });

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Daily Monitoring</Text>
        </View>
        <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
          Log your daily health metrics for AI analysis
        </Text>

        {/* Log fields */}
        {LOG_FIELDS.map((field) => (
          <GlassCard key={field.key} radius={18} blur={14} padding={16} style={{ marginBottom: 10 }}>
            <View style={styles.fieldHeader}>
              <View style={[styles.fieldIcon, { backgroundColor: `${field.color}14` }]}>
                <Ionicons name={field.icon as any} size={16} color={field.color} />
              </View>
              <Text style={[styles.fieldLabel, { color: colors.textPrimary }]}>{field.label}</Text>
            </View>

            {field.type === 'slider' && (
              <View style={styles.sliderRow}>
                {Array.from({ length: field.max! }, (_, i) => i + 1).map((n) => (
                  <Pressable
                    key={n}
                    onPress={() => setValues({ ...values, [field.key]: n })}
                    style={[styles.sliderDot, {
                      backgroundColor: n <= (values[field.key] ?? 0)
                        ? (n <= 3 ? '#10B981' : n <= 6 ? '#F59E0B' : '#EF4444')
                        : (isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)'),
                    }]}
                  >
                    <Text style={[styles.sliderNum, {
                      color: n <= (values[field.key] ?? 0) ? '#FFF' : colors.textSecondary,
                    }]}>{n}</Text>
                  </Pressable>
                ))}
              </View>
            )}

            {field.type === 'number' && (
              <View style={styles.numberRow}>
                <TextInput
                  style={[styles.numberInput, {
                    color: colors.textPrimary,
                    backgroundColor: isDark ? 'rgba(255,255,255,0.05)' : '#F1F5F9',
                    borderColor: isDark ? 'rgba(255,255,255,0.08)' : '#E2E8F0',
                  }]}
                  keyboardType="numeric"
                  value={String(values[field.key] ?? '')}
                  onChangeText={(t) => setValues({ ...values, [field.key]: t })}
                />
                <Text style={[styles.unitText, { color: colors.textSecondary }]}>{field.unit}</Text>
              </View>
            )}

            {field.type === 'mood' && (
              <View style={styles.moodRow}>
                {MOODS.map((m, i) => (
                  <Pressable
                    key={i}
                    onPress={() => setValues({ ...values, mood: i })}
                    style={[styles.moodBtn, {
                      backgroundColor: values.mood === i ? 'rgba(245,158,11,0.15)' : 'transparent',
                      borderColor: values.mood === i ? '#F59E0B' : 'transparent',
                    }]}
                  >
                    <Text style={styles.moodEmoji}>{m}</Text>
                  </Pressable>
                ))}
              </View>
            )}
          </GlassCard>
        ))}

        {/* Submit */}
        <Pressable
          onPress={() => {
            Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
            router.back();
          }}
          style={{ marginTop: 6 }}
        >
          <LinearGradient colors={['#3B82F6', '#2563EB']} style={styles.submitBtn}>
            <Ionicons name="cloud-upload" size={18} color="#FFF" />
            <Text style={styles.submitBtnText}>Save Today's Log</Text>
          </LinearGradient>
        </Pressable>

        {/* History */}
        <Text style={[styles.historyTitle, { color: colors.textPrimary }]}>Recent Logs</Text>
        {HISTORY.map((h, i) => (
          <GlassCard key={i} radius={14} blur={12} padding={12} style={{ marginBottom: 6 }}>
            <View style={styles.histRow}>
              <Text style={[styles.histDate, { color: colors.textPrimary }]}>{h.date}</Text>
              <View style={styles.histChips}>
                <Text style={styles.histChip}>😴 {h.sleep}h</Text>
                <Text style={styles.histChip}>💧 {h.hydration}</Text>
                <Text style={styles.histChip}>⚡ {h.pain}/10</Text>
                <Text style={styles.histChip}>{h.mood}</Text>
              </View>
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
  headerRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginBottom: 4 },
  backBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 22, fontWeight: '800' },
  subtitle: { fontSize: 13, marginBottom: 16 },
  fieldHeader: { flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 10 },
  fieldIcon: { width: 28, height: 28, borderRadius: 8, alignItems: 'center', justifyContent: 'center' },
  fieldLabel: { fontSize: 14, fontWeight: '700' },
  sliderRow: { flexDirection: 'row', justifyContent: 'space-between' },
  sliderDot: { width: 26, height: 26, borderRadius: 13, alignItems: 'center', justifyContent: 'center' },
  sliderNum: { fontSize: 10, fontWeight: '700' },
  numberRow: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  numberInput: { width: 70, height: 40, borderRadius: 10, borderWidth: 0.6, textAlign: 'center', fontSize: 16, fontWeight: '700' },
  unitText: { fontSize: 13, fontWeight: '500' },
  moodRow: { flexDirection: 'row', justifyContent: 'space-around' },
  moodBtn: { padding: 8, borderRadius: 14, borderWidth: 1.5 },
  moodEmoji: { fontSize: 28 },
  submitBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    height: 52, borderRadius: 14,
    shadowColor: '#3B82F6', shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25, shadowRadius: 12, elevation: 6,
  },
  submitBtnText: { fontSize: 15, fontWeight: '700', color: '#FFF' },
  historyTitle: { fontSize: 16, fontWeight: '700', marginTop: 24, marginBottom: 10 },
  histRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  histDate: { fontSize: 13, fontWeight: '600' },
  histChips: { flexDirection: 'row', gap: 6 },
  histChip: { fontSize: 11 },
});
