import React from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable, Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../../src/shared/components/AppBackground';
import { GlassCard } from '../../src/shared/components/GlassCard';
import { useAppTheme } from '../../src/core/theme/useTheme';
import { useAuthStore } from '../../src/core/store/authStore';
import { useThemeStore } from '../../src/core/theme/useTheme';

const MENU_SECTIONS = [
  {
    title: 'Health',
    items: [
      { icon: 'fitness', label: 'Health Connect', route: '/health-connect', color: '#EF4444' },
      { icon: 'pulse', label: 'Monitoring', route: '/monitoring', color: '#8B5CF6' },
      { icon: 'document-text', label: 'Recovery Report', route: '/recovery-report', color: '#10B981' },
    ],
  },
  {
    title: 'Services',
    items: [
      { icon: 'medkit', label: 'Pharmacy', route: '/pharmacy', color: '#06B6D4' },
      { icon: 'location', label: 'Hospitals', route: '/hospitals', color: '#EC4899' },
      { icon: 'card', label: 'MedAssist Card', route: '/medassist-card', color: '#F59E0B' },
    ],
  },
  {
    title: 'Settings',
    items: [
      { icon: 'moon', label: 'Dark Mode', route: '__theme', color: '#6366F1' },
      { icon: 'shield-checkmark', label: 'Privacy', route: '__privacy', color: '#10B981' },
      { icon: 'information-circle', label: 'About', route: '__about', color: '#3B82F6' },
    ],
  },
];

export default function ProfileScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const { profile, signOut } = useAuthStore();
  const { mode, setMode } = useThemeStore();

  const fullName = (profile as any)?.full_name ?? 'Patient';
  const email = (profile as any)?.email ?? 'user@medassist.ai';

  const handleLogout = () => {
    Alert.alert('Sign Out', 'Are you sure you want to sign out?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Sign Out',
        style: 'destructive',
        onPress: async () => {
          await signOut();
          router.replace('/login');
        },
      },
    ]);
  };

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        {/* Profile header */}
        <GlassCard radius={24} blur={20} padding={20}>
          <View style={styles.profileRow}>
            <View style={[styles.avatar, { backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#EAF3FF' }]}>
              <Text style={styles.avatarText}>{fullName[0]?.toUpperCase() ?? 'P'}</Text>
            </View>
            <View style={styles.profileInfo}>
              <Text style={[styles.profileName, { color: colors.textPrimary }]}>{fullName}</Text>
              <Text style={[styles.profileEmail, { color: colors.textSecondary }]}>{email}</Text>
            </View>
            <Pressable style={[styles.editBtn, { backgroundColor: isDark ? 'rgba(42,127,255,0.15)' : 'rgba(42,127,255,0.08)' }]}>
              <Ionicons name="create-outline" size={16} color="#2A7FFF" />
            </Pressable>
          </View>
        </GlassCard>

        {/* Menu sections */}
        {MENU_SECTIONS.map((section, si) => (
          <View key={si} style={styles.section}>
            <Text style={[styles.sectionTitle, { color: colors.textSecondary }]}>{section.title}</Text>
            <GlassCard radius={18} blur={14} padding={0}>
              {section.items.map((item, ii) => (
                <Pressable
                  key={ii}
                  onPress={() => {
                    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                    if (item.route === '__theme') {
                      setMode(mode === 'dark' ? 'light' : mode === 'light' ? 'system' : 'dark');
                    } else if (item.route.startsWith('__')) {
                      // placeholder
                    } else {
                      router.push(item.route as any);
                    }
                  }}
                  style={[
                    styles.menuRow,
                    ii < section.items.length - 1 && {
                      borderBottomWidth: 0.5,
                      borderBottomColor: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.06)',
                    },
                  ]}
                >
                  <View style={[styles.menuIcon, { backgroundColor: `${item.color}14` }]}>
                    <Ionicons name={item.icon as any} size={18} color={item.color} />
                  </View>
                  <Text style={[styles.menuLabel, { color: colors.textPrimary }]}>{item.label}</Text>
                  {item.route === '__theme' ? (
                    <Text style={[styles.themeVal, { color: colors.textSecondary }]}>
                      {mode === 'system' ? 'System' : mode === 'dark' ? 'Dark' : 'Light'}
                    </Text>
                  ) : (
                    <Ionicons name="chevron-forward" size={16} color={colors.textSecondary} />
                  )}
                </Pressable>
              ))}
            </GlassCard>
          </View>
        ))}

        {/* Logout */}
        <Pressable onPress={handleLogout} style={styles.logoutBtn}>
          <Ionicons name="log-out-outline" size={18} color="#EF4444" />
          <Text style={styles.logoutText}>Sign Out</Text>
        </Pressable>

        <Text style={[styles.version, { color: colors.textSecondary }]}>MedAssist AI v1.0.0</Text>

        <View style={{ height: 120 }} />
      </ScrollView>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingHorizontal: 16, paddingTop: 60 },
  profileRow: { flexDirection: 'row', alignItems: 'center' },
  avatar: { width: 56, height: 56, borderRadius: 28, alignItems: 'center', justifyContent: 'center' },
  avatarText: { fontSize: 22, fontWeight: '700', color: '#2A7FFF' },
  profileInfo: { flex: 1, marginLeft: 14 },
  profileName: { fontSize: 18, fontWeight: '700' },
  profileEmail: { fontSize: 12, marginTop: 2 },
  editBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  section: { marginTop: 20 },
  sectionTitle: { fontSize: 12, fontWeight: '600', letterSpacing: 0.5, marginBottom: 8, marginLeft: 4 },
  menuRow: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16, paddingVertical: 14 },
  menuIcon: { width: 34, height: 34, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  menuLabel: { flex: 1, fontSize: 14, fontWeight: '600', marginLeft: 12 },
  themeVal: { fontSize: 12 },
  logoutBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    marginTop: 24, paddingVertical: 14, borderRadius: 14,
    backgroundColor: 'rgba(239,68,68,0.08)', borderWidth: 0.5, borderColor: 'rgba(239,68,68,0.20)',
  },
  logoutText: { fontSize: 14, fontWeight: '700', color: '#EF4444' },
  version: { textAlign: 'center', fontSize: 11, marginTop: 16 },
});
