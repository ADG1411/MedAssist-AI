import { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Image, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import { authService } from '../../services/authService';
import { supabase } from '../../services/supabase';

export default function ProfileScreen() {
  const router = useRouter();
  const [doctorName, setDoctorName] = useState('Dr. Smith');
  const [specialization, setSpecialization] = useState('Cardiologist');
  const [completion, setCompletion] = useState(0);
  const [email, setEmail] = useState('');

  useEffect(() => {
    loadProfile();
  }, []);

  const loadProfile = async () => {
    try {
      const { data } = await authService.getCurrentUser();
      if (data?.user) {
        setEmail(data.user.email || '');
        const { data: profile } = await supabase.from('doctor_profiles').select('overview, completion_percent').eq('id', data.user.id).maybeSingle();
        if (profile) {
          setDoctorName(profile.overview?.full_name || 'Dr. Smith');
          setSpecialization(profile.overview?.specialization || 'General');
          setCompletion(profile.completion_percent || 0);
        }
      }
    } catch (e) { /* ignore */ }
  };

  const handleLogout = async () => {
    Alert.alert('Logout', 'Are you sure you want to logout?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Logout', style: 'destructive', onPress: async () => {
        await authService.logout();
        router.replace('/(auth)/login');
      }},
    ]);
  };

  const NAV_SECTIONS = [
    {
      title: 'Practice',
      items: [
        { icon: 'calendar' as const, label: 'Schedule', desc: 'Manage your availability', route: '/(dashboard)/schedule', color: Colors.emerald },
        { icon: 'medkit' as const, label: 'Prescription', desc: 'Write smart prescriptions', route: '/(dashboard)/prescription', color: Colors.purple },
        { icon: 'videocam' as const, label: 'Consultation', desc: 'Start a video call', route: '/(dashboard)/consultation', color: Colors.brandBlue },
        { icon: 'share-social' as const, label: 'Referrals', desc: 'Create & manage referrals', route: '/(dashboard)/referral', color: Colors.indigo },
      ],
    },
    {
      title: 'Management',
      items: [
        { icon: 'document-text' as const, label: 'Case Workflow', desc: 'Track case progress', route: '/(dashboard)/case', color: Colors.amber },
        { icon: 'warning' as const, label: 'Emergency Alerts', desc: 'Critical patient alerts', route: '/(dashboard)/emergency', color: Colors.red },
      ],
    },
    {
      title: 'Account',
      items: [
        { icon: 'person-circle' as const, label: 'Edit Profile', desc: 'Update your doctor profile', route: '/(dashboard)/profile-setup', color: Colors.brandBlue },
      ],
    },
  ];

  return (
    <ScrollView style={styles.container} contentContainerStyle={{ paddingBottom: 100 }} showsVerticalScrollIndicator={false}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.pageTitle}>More</Text>
      </View>

      {/* Profile Card */}
      <View style={styles.profileCard}>
        <Image source={{ uri: `https://ui-avatars.com/api/?name=${encodeURIComponent(doctorName)}&background=1A6BFF&color=fff&size=128` }}
          style={styles.avatar} />
        <View style={{ flex: 1 }}>
          <Text style={styles.name}>{doctorName}</Text>
          <Text style={styles.spec}>{specialization}</Text>
          <Text style={styles.email}>{email}</Text>
        </View>
        <TouchableOpacity style={styles.editBtn} onPress={() => router.push('/(dashboard)/profile-setup')}>
          <Ionicons name="create-outline" size={18} color={Colors.brandBlue} />
        </TouchableOpacity>
      </View>

      {/* Completion Bar */}
      <View style={styles.completionCard}>
        <View style={styles.completionRow}>
          <Ionicons name="shield-checkmark" size={18} color={Colors.brandBlue} />
          <Text style={styles.completionLabel}>Profile Completion</Text>
          <Text style={styles.completionValue}>{completion}%</Text>
        </View>
        <View style={styles.completionTrack}>
          <View style={[styles.completionFill, { width: `${completion}%` }]} />
        </View>
        {completion < 80 && (
          <TouchableOpacity style={styles.completeBtn} onPress={() => router.push('/(dashboard)/profile-setup')}>
            <Text style={styles.completeBtnText}>Complete Setup →</Text>
          </TouchableOpacity>
        )}
      </View>

      {/* Navigation Sections */}
      {NAV_SECTIONS.map((section) => (
        <View key={section.title} style={styles.navSection}>
          <Text style={styles.sectionTitle}>{section.title}</Text>
          {section.items.map((item) => (
            <TouchableOpacity key={item.label} style={styles.navItem} onPress={() => router.push(item.route as any)} activeOpacity={0.6}>
              <View style={[styles.navIcon, { backgroundColor: item.color + '15' }]}>
                <Ionicons name={item.icon} size={22} color={item.color} />
              </View>
              <View style={{ flex: 1 }}>
                <Text style={styles.navLabel}>{item.label}</Text>
                <Text style={styles.navDesc}>{item.desc}</Text>
              </View>
              <Ionicons name="chevron-forward" size={18} color={Colors.slate300} />
            </TouchableOpacity>
          ))}
        </View>
      ))}

      {/* Logout */}
      <TouchableOpacity style={styles.logoutBtn} onPress={handleLogout}>
        <Ionicons name="log-out-outline" size={20} color={Colors.red} />
        <Text style={styles.logoutText}>Logout</Text>
      </TouchableOpacity>

      <Text style={styles.version}>MedAssist Doctor v1.0.0</Text>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.background },
  header: { paddingHorizontal: 16, paddingTop: 56, paddingBottom: 8 },
  pageTitle: { fontSize: FontSize.h1, fontWeight: '900', color: Colors.textPrimary },
  // Profile Card
  profileCard: { flexDirection: 'row', alignItems: 'center', gap: 14, backgroundColor: Colors.surface, margin: 16, marginBottom: 10, borderRadius: BorderRadius.xxl, padding: 16, borderWidth: 1, borderColor: Colors.borderLight },
  avatar: { width: 56, height: 56, borderRadius: 18, borderWidth: 2, borderColor: Colors.blueLight },
  name: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary },
  spec: { fontSize: FontSize.sm, color: Colors.brandBlue, fontWeight: '600', marginTop: 1 },
  email: { fontSize: FontSize.xs, color: Colors.textTertiary, marginTop: 2 },
  editBtn: { width: 36, height: 36, borderRadius: 12, backgroundColor: Colors.blueBg, justifyContent: 'center', alignItems: 'center' },
  // Completion
  completionCard: { backgroundColor: Colors.surface, marginHorizontal: 16, borderRadius: BorderRadius.xl, padding: 14, marginBottom: 16, borderWidth: 1, borderColor: Colors.borderLight },
  completionRow: { flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 8 },
  completionLabel: { flex: 1, fontSize: FontSize.sm, fontWeight: '700', color: Colors.textSecondary },
  completionValue: { fontSize: FontSize.sm, fontWeight: '900', color: Colors.brandBlue },
  completionTrack: { height: 6, backgroundColor: Colors.slate100, borderRadius: 3, overflow: 'hidden' },
  completionFill: { height: '100%', backgroundColor: Colors.brandBlue, borderRadius: 3 },
  completeBtn: { marginTop: 10 },
  completeBtnText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.brandBlue },
  // Nav Sections
  navSection: { paddingHorizontal: 16, marginBottom: 16 },
  sectionTitle: { fontSize: FontSize.xs, fontWeight: '800', color: Colors.textTertiary, textTransform: 'uppercase', letterSpacing: 1.2, marginBottom: 8, paddingLeft: 4 },
  navItem: { flexDirection: 'row', alignItems: 'center', gap: 14, backgroundColor: Colors.surface, padding: 14, borderRadius: BorderRadius.lg, marginBottom: 6, borderWidth: 1, borderColor: Colors.borderLight },
  navIcon: { width: 42, height: 42, borderRadius: 12, justifyContent: 'center', alignItems: 'center' },
  navLabel: { fontSize: FontSize.base, fontWeight: '700', color: Colors.textPrimary },
  navDesc: { fontSize: FontSize.xs, color: Colors.textSecondary, marginTop: 1 },
  // Logout
  logoutBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, marginHorizontal: 16, paddingVertical: 14, backgroundColor: Colors.redBg, borderRadius: BorderRadius.lg, borderWidth: 1, borderColor: Colors.redLight },
  logoutText: { fontSize: FontSize.md, fontWeight: '700', color: Colors.red },
  version: { textAlign: 'center', color: Colors.textTertiary, fontSize: FontSize.xs, marginTop: 16, marginBottom: 8, fontWeight: '500' },
});
