import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable, Switch,
} from 'react-native';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const WEARABLES = [
  { id: 'apple_watch', name: 'Apple Watch', icon: 'watch', connected: true, lastSync: '2 min ago', color: '#3B82F6' },
  { id: 'fitbit', name: 'Fitbit', icon: 'fitness', connected: false, lastSync: 'Never', color: '#10B981' },
  { id: 'google_fit', name: 'Google Fit', icon: 'logo-google', connected: true, lastSync: '1 hr ago', color: '#F59E0B' },
  { id: 'samsung', name: 'Samsung Health', icon: 'heart', connected: false, lastSync: 'Never', color: '#8B5CF6' },
];

const DATA_TYPES = [
  { id: 'heart_rate', label: 'Heart Rate', icon: 'heart', enabled: true, color: '#EF4444' },
  { id: 'steps', label: 'Steps', icon: 'footsteps', enabled: true, color: '#3B82F6' },
  { id: 'sleep', label: 'Sleep', icon: 'moon', enabled: true, color: '#8B5CF6' },
  { id: 'blood_oxygen', label: 'Blood Oxygen', icon: 'water', enabled: false, color: '#06B6D4' },
  { id: 'blood_pressure', label: 'Blood Pressure', icon: 'pulse', enabled: false, color: '#EF4444' },
  { id: 'weight', label: 'Weight', icon: 'scale', enabled: true, color: '#F59E0B' },
];

export default function HealthConnectScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const [wearables, setWearables] = useState(WEARABLES);
  const [dataTypes, setDataTypes] = useState(DATA_TYPES);

  const toggleWearable = (id: string) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setWearables((prev) =>
      prev.map((w) => w.id === id ? { ...w, connected: !w.connected, lastSync: !w.connected ? 'Just now' : 'Never' } : w)
    );
  };

  const toggleDataType = (id: string) => {
    setDataTypes((prev) =>
      prev.map((d) => d.id === id ? { ...d, enabled: !d.enabled } : d)
    );
  };

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Health Connect</Text>
        </View>
        <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
          Connect wearables & health apps for real-time monitoring
        </Text>

        {/* Wearable devices */}
        <Text style={[styles.sectionLabel, { color: colors.textSecondary }]}>DEVICES & APPS</Text>
        {wearables.map((w) => (
          <Pressable key={w.id} onPress={() => toggleWearable(w.id)}>
            <GlassCard radius={18} blur={14} padding={14} style={{ marginBottom: 8 }}>
              <View style={styles.deviceRow}>
                <View style={[styles.deviceIcon, { backgroundColor: `${w.color}14` }]}>
                  <Ionicons name={w.icon as any} size={20} color={w.color} />
                </View>
                <View style={styles.deviceInfo}>
                  <Text style={[styles.deviceName, { color: colors.textPrimary }]}>{w.name}</Text>
                  <Text style={[styles.deviceSync, { color: colors.textSecondary }]}>
                    {w.connected ? `Last synced: ${w.lastSync}` : 'Not connected'}
                  </Text>
                </View>
                <View style={[styles.statusBadge, {
                  backgroundColor: w.connected ? 'rgba(16,185,129,0.12)' : (isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.04)'),
                }]}>
                  <View style={[styles.statusDot, { backgroundColor: w.connected ? '#10B981' : '#94A3B8' }]} />
                  <Text style={[styles.statusText, { color: w.connected ? '#10B981' : colors.textSecondary }]}>
                    {w.connected ? 'Connected' : 'Connect'}
                  </Text>
                </View>
              </View>
            </GlassCard>
          </Pressable>
        ))}

        {/* Data types */}
        <Text style={[styles.sectionLabel, { color: colors.textSecondary, marginTop: 16 }]}>DATA TYPES</Text>
        <GlassCard radius={18} blur={14} padding={0}>
          {dataTypes.map((d, i) => (
            <View
              key={d.id}
              style={[
                styles.dataRow,
                i < dataTypes.length - 1 && {
                  borderBottomWidth: 0.5,
                  borderBottomColor: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.06)',
                },
              ]}
            >
              <View style={[styles.dataIcon, { backgroundColor: `${d.color}14` }]}>
                <Ionicons name={d.icon as any} size={16} color={d.color} />
              </View>
              <Text style={[styles.dataLabel, { color: colors.textPrimary }]}>{d.label}</Text>
              <Switch
                value={d.enabled}
                onValueChange={() => toggleDataType(d.id)}
                trackColor={{ false: isDark ? '#333' : '#D1D5DB', true: '#10B981' }}
                thumbColor="#FFF"
              />
            </View>
          ))}
        </GlassCard>

        {/* Sync info */}
        <GlassCard radius={16} blur={12} padding={14} style={{ marginTop: 16 }}>
          <View style={styles.infoRow}>
            <Ionicons name="information-circle" size={16} color="#3B82F6" />
            <Text style={[styles.infoText, { color: colors.textSecondary }]}>
              Health data syncs automatically every 15 minutes when connected. All data is encrypted and stored securely.
            </Text>
          </View>
        </GlassCard>

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
  sectionLabel: { fontSize: 11, fontWeight: '700', letterSpacing: 0.5, marginBottom: 8, marginLeft: 4 },
  deviceRow: { flexDirection: 'row', alignItems: 'center' },
  deviceIcon: { width: 42, height: 42, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  deviceInfo: { flex: 1, marginLeft: 12 },
  deviceName: { fontSize: 14, fontWeight: '600' },
  deviceSync: { fontSize: 11, marginTop: 2 },
  statusBadge: { flexDirection: 'row', alignItems: 'center', gap: 4, paddingHorizontal: 10, paddingVertical: 5, borderRadius: 10 },
  statusDot: { width: 6, height: 6, borderRadius: 3 },
  statusText: { fontSize: 11, fontWeight: '600' },
  dataRow: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16, paddingVertical: 12 },
  dataIcon: { width: 30, height: 30, borderRadius: 8, alignItems: 'center', justifyContent: 'center' },
  dataLabel: { flex: 1, fontSize: 14, fontWeight: '600', marginLeft: 12 },
  infoRow: { flexDirection: 'row', alignItems: 'flex-start', gap: 8 },
  infoText: { flex: 1, fontSize: 12, lineHeight: 17 },
});
