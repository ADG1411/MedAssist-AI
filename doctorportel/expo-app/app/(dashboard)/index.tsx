import { useState, useEffect } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity, Image, RefreshControl
} from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius, Spacing } from '../../constants/Colors';

const STATS = [
  { label: 'Total Patients', value: '1,284', trend: '+12%', isPositive: true, icon: 'people' as const, color: Colors.brandBlue, bg: Colors.blueLight },
  { label: 'Appointments', value: '14', trend: '4 left', isPositive: true, icon: 'calendar' as const, color: Colors.emerald, bg: Colors.emeraldLight },
  { label: 'Active Tickets', value: '7', trend: '2 urgent', isPositive: false, icon: 'document-text' as const, color: Colors.purple, bg: Colors.purpleLight },
  { label: 'Earnings Today', value: '₹840', trend: '+5%', isPositive: true, icon: 'trending-up' as const, color: Colors.amber, bg: Colors.amberLight },
];

const APPOINTMENTS = [
  { id: 1, name: 'Rahul Sharma', time: '10:30 AM', status: 'Waiting', type: 'Follow up', avatar: 'https://ui-avatars.com/api/?name=Rahul+Sharma&background=f87171&color=fff' },
  { id: 2, name: 'Emma Watson', time: '11:00 AM', status: 'In Progress', type: 'Checkup', avatar: 'https://ui-avatars.com/api/?name=Emma+Watson&background=60a5fa&color=fff' },
  { id: 3, name: 'Sarah Smith', time: '11:45 AM', status: 'Scheduled', type: 'Consultation', avatar: 'https://ui-avatars.com/api/?name=Sarah+Smith&background=34d399&color=fff' },
];

const NOTIFICATIONS = [
  { id: 1, title: 'Follow-up missed', desc: 'John Doe did not attend 9:00 AM.', time: '1 hr ago', type: 'warning' },
  { id: 2, title: 'New Lab Report', desc: 'CBC results for Emma Watson ready.', time: '2 hrs ago', type: 'info' },
  { id: 3, title: 'Case Transfer', desc: 'Case #893 approved by Dr. Lee.', time: '4 hrs ago', type: 'success' },
];

export default function DashboardScreen() {
  const router = useRouter();
  const [currentDate, setCurrentDate] = useState('');
  const [refreshing, setRefreshing] = useState(false);
  const [appointments, setAppointments] = useState(APPOINTMENTS);
  const [notifications, setNotifications] = useState(NOTIFICATIONS);

  useEffect(() => {
    setCurrentDate(new Intl.DateTimeFormat('en-US', { weekday: 'long', month: 'long', day: 'numeric' }).format(new Date()));
  }, []);

  const onRefresh = () => {
    setRefreshing(true);
    setTimeout(() => setRefreshing(false), 1000);
  };

  const statusColor = (status: string) => {
    switch (status) {
      case 'Waiting': return { bg: Colors.amberLight, text: Colors.amber };
      case 'In Progress': return { bg: Colors.blueLight, text: Colors.brandBlue };
      case 'Completed': return { bg: Colors.emeraldLight, text: Colors.emerald };
      default: return { bg: Colors.slate100, text: Colors.slate600 };
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={Colors.brandBlue} />}
      showsVerticalScrollIndicator={false}>

      {/* Header */}
      <View style={styles.headerCard}>
        <Text style={styles.dateText}>{currentDate}</Text>
        <Text style={styles.greeting}>Good morning,{'\n'}<Text style={styles.greetingName}>Dr. Smith!</Text> 👋</Text>
        <Text style={styles.headerSub}>Here is your control hub for today.</Text>

        <View style={styles.quickActions}>
          <TouchableOpacity style={styles.quickBtn} onPress={() => router.push('/(dashboard)/patients')}>
            <Ionicons name="person-add" size={18} color={Colors.slate700} />
            <Text style={styles.quickBtnText}>Add Patient</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[styles.quickBtn, styles.quickBtnBlue]} onPress={() => router.push('/(dashboard)/prescription')}>
            <Ionicons name="medkit" size={18} color={Colors.brandBlue} />
            <Text style={[styles.quickBtnText, { color: Colors.brandBlue }]}>Prescription</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[styles.quickBtn, styles.quickBtnRed]} onPress={() => router.push('/(dashboard)/emergency')}>
            <Text style={styles.quickBtnTextWhite}>🚨 SOS</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* AI Brief Panel */}
      <View style={styles.aiBriefCard}>
        <View style={styles.aiBriefHeader}>
          <Ionicons name="sparkles" size={16} color="#C4B5FD" />
          <Text style={styles.aiBriefLabel}>SMART DAILY BRIEF</Text>
        </View>
        <Text style={styles.aiBriefTitle}>You have <Text style={{ color: '#F87171' }}>1</Text> critical case today.</Text>
        <View style={styles.aiBriefItems}>
          <View style={styles.aiBriefItem}>
            <View style={[styles.aiBriefIcon, { backgroundColor: 'rgba(239,68,68,0.15)' }]}>
              <Ionicons name="heart" size={16} color="#F87171" />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.aiBriefItemTitle}>Rahul Sharma (10:30 AM)</Text>
              <Text style={styles.aiBriefItemDesc}>Severe hypertension check</Text>
            </View>
          </View>
          <View style={styles.aiBriefItem}>
            <View style={[styles.aiBriefIcon, { backgroundColor: 'rgba(16,185,129,0.15)' }]}>
              <Ionicons name="checkmark-circle" size={16} color="#10B981" />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.aiBriefItemTitle}>2 Follow-ups Pending</Text>
              <Text style={styles.aiBriefItemDesc}>Review lab results from yesterday</Text>
            </View>
          </View>
        </View>
        <TouchableOpacity style={styles.startBtn} onPress={() => router.push('/(dashboard)/schedule')}>
          <Text style={styles.startBtnText}>Start Next Appointment</Text>
          <Ionicons name="chevron-forward" size={16} color="#312E81" />
        </TouchableOpacity>
      </View>

      {/* Stats Cards */}
      <View style={styles.statsGrid}>
        {STATS.map((stat) => (
          <View key={stat.label} style={styles.statCard}>
            <View style={[styles.statIcon, { backgroundColor: stat.bg }]}>
              <Ionicons name={stat.icon} size={22} color={stat.color} />
            </View>
            <Text style={styles.statValue}>{stat.value}</Text>
            <Text style={styles.statLabel}>{stat.label}</Text>
            <View style={styles.statTrendRow}>
              <Ionicons name={stat.isPositive ? 'trending-up' : 'alert-circle'} size={12}
                color={stat.isPositive ? Colors.emerald : Colors.amber} />
              <Text style={[styles.statTrend, { color: stat.isPositive ? Colors.emerald : Colors.amber }]}>{stat.trend}</Text>
            </View>
          </View>
        ))}
      </View>

      {/* Quick Shortcuts */}
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.shortcutsScroll} contentContainerStyle={{ gap: 10, paddingHorizontal: 4 }}>
        {[
          { icon: 'person-add' as const, label: 'Add Patient', route: '/(dashboard)/patients' },
          { icon: 'medkit' as const, label: 'Prescription', route: '/(dashboard)/prescription' },
          { icon: 'videocam' as const, label: 'Start Video', route: '/(dashboard)/consultation' },
          { icon: 'bar-chart' as const, label: 'Reports', route: '/(dashboard)/analytics' },
          { icon: 'chatbubbles' as const, label: 'AI Chat', route: '/(dashboard)/ai' },
          { icon: 'qr-code' as const, label: 'Scan QR', route: '/(dashboard)/scan' },
        ].map((s) => (
          <TouchableOpacity key={s.label} style={styles.shortcutBtn} onPress={() => router.push(s.route as any)}>
            <Ionicons name={s.icon} size={18} color={Colors.brandBlue} />
            <Text style={styles.shortcutText}>{s.label}</Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* Today's Pipeline */}
      <View style={styles.sectionCard}>
        <View style={styles.sectionHeader}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <Ionicons name="calendar" size={18} color={Colors.brandBlue} />
            <Text style={styles.sectionTitle}>Today's Pipeline</Text>
          </View>
          <TouchableOpacity onPress={() => router.push('/(dashboard)/schedule')}>
            <Text style={styles.viewAllText}>View All</Text>
          </TouchableOpacity>
        </View>
        {appointments.map((apt) => {
          const sc = statusColor(apt.status);
          return (
            <TouchableOpacity key={apt.id} style={styles.appointmentRow} onPress={() => router.push('/(dashboard)/patients')}>
              <Image source={{ uri: apt.avatar }} style={styles.appointmentAvatar} />
              <View style={{ flex: 1 }}>
                <Text style={styles.appointmentName}>{apt.name}</Text>
                <Text style={styles.appointmentMeta}>
                  <Ionicons name="time-outline" size={12} color={Colors.slate400} /> {apt.time} • {apt.type}
                </Text>
              </View>
              <View style={[styles.statusBadge, { backgroundColor: sc.bg }]}>
                <Text style={[styles.statusText, { color: sc.text }]}>{apt.status}</Text>
              </View>
            </TouchableOpacity>
          );
        })}
      </View>

      {/* Feature Cards */}
      <View style={styles.featureGrid}>
        <TouchableOpacity style={[styles.featureCard, { backgroundColor: '#FAF5FF', borderColor: '#E9D5FF' }]} onPress={() => router.push('/(dashboard)/prescription')}>
          <View style={[styles.featureIconBox, { backgroundColor: '#FFF' }]}>
            <Ionicons name="medkit" size={24} color={Colors.purple} />
          </View>
          <Text style={styles.featureTitle}>Smart Prescription</Text>
          <Text style={styles.featureDesc}>Write, estimate cost, and generate Rx</Text>
          <View style={styles.featureLink}>
            <Text style={[styles.featureLinkText, { color: Colors.purple }]}>Open Writer</Text>
            <Ionicons name="chevron-forward" size={14} color={Colors.purple} />
          </View>
        </TouchableOpacity>
        <TouchableOpacity style={[styles.featureCard, { borderColor: Colors.border }]} onPress={() => router.push('/(dashboard)/scan')}>
          <View style={[styles.featureIconBox, { backgroundColor: Colors.slate50 }]}>
            <Ionicons name="qr-code" size={24} color={Colors.slate700} />
          </View>
          <Text style={styles.featureTitle}>Patient MedCards</Text>
          <Text style={styles.featureDesc}>Scan QR or search for history</Text>
          <View style={styles.featureLink}>
            <Text style={[styles.featureLinkText, { color: Colors.brandBlue }]}>Scan / Search</Text>
            <Ionicons name="chevron-forward" size={14} color={Colors.brandBlue} />
          </View>
        </TouchableOpacity>
      </View>

      {/* Emergency Alert */}
      <TouchableOpacity style={styles.emergencyCard} onPress={() => router.push('/(dashboard)/emergency')}>
        <View style={styles.emergencyStripe} />
        <Ionicons name="alert-circle" size={20} color={Colors.red} />
        <View style={{ flex: 1 }}>
          <Text style={styles.emergencyTitle}>Emergency Cases <View style={styles.emergencyBadge}><Text style={styles.emergencyBadgeText}>1</Text></View></Text>
          <Text style={styles.emergencyDesc}>Michael J. (Chest Pain)</Text>
        </View>
        <Ionicons name="chevron-forward" size={18} color={Colors.redLight} />
      </TouchableOpacity>

      {/* Notifications */}
      <View style={styles.sectionCard}>
        <View style={styles.sectionHeader}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <Ionicons name="notifications" size={18} color={Colors.slate400} />
            <Text style={styles.sectionTitle}>Notifications</Text>
          </View>
          {notifications.length > 0 && (
            <TouchableOpacity onPress={() => setNotifications([])}>
              <Text style={[styles.viewAllText, { color: Colors.red }]}>Clear all</Text>
            </TouchableOpacity>
          )}
        </View>
        {notifications.length === 0 ? (
          <Text style={styles.emptyText}>No new notifications 🎉</Text>
        ) : notifications.map((n) => (
          <View key={n.id} style={styles.notifRow}>
            <View style={[styles.notifDot, {
              backgroundColor: n.type === 'warning' ? Colors.amber : n.type === 'success' ? Colors.emerald : Colors.brandBlue
            }]} />
            <View style={{ flex: 1 }}>
              <Text style={styles.notifTitle}>{n.title}</Text>
              <Text style={styles.notifDesc}>{n.desc}</Text>
              <Text style={styles.notifTime}>{n.time}</Text>
            </View>
            <TouchableOpacity onPress={() => setNotifications(prev => prev.filter(x => x.id !== n.id))}>
              <Ionicons name="close" size={16} color={Colors.slate400} />
            </TouchableOpacity>
          </View>
        ))}
      </View>

      <View style={{ height: 20 }} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.background },
  content: { padding: 16, paddingTop: 56 },
  headerCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 20, marginBottom: 16, borderWidth: 1, borderColor: Colors.borderLight, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.04, shadowRadius: 8, elevation: 2 },
  dateText: { color: Colors.brandBlue, fontSize: FontSize.sm, fontWeight: '700', marginBottom: 4 },
  greeting: { fontSize: FontSize.h1, fontWeight: '900', color: Colors.textPrimary, lineHeight: 36 },
  greetingName: { color: Colors.brandBlue },
  headerSub: { color: Colors.textSecondary, fontSize: FontSize.md, fontWeight: '500', marginTop: 4, marginBottom: 16 },
  quickActions: { flexDirection: 'row', gap: 8 },
  quickBtn: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, backgroundColor: Colors.slate100, paddingVertical: 12, borderRadius: BorderRadius.md },
  quickBtnBlue: { backgroundColor: Colors.blueBg, borderWidth: 1, borderColor: Colors.blueLight },
  quickBtnRed: { backgroundColor: Colors.red, flex: 0.6 },
  quickBtnText: { fontSize: FontSize.xs, fontWeight: '700', color: Colors.slate700 },
  quickBtnTextWhite: { fontSize: FontSize.xs, fontWeight: '700', color: '#FFF' },

  aiBriefCard: { backgroundColor: '#1E1B4B', borderRadius: BorderRadius.xxl, padding: 20, marginBottom: 16, overflow: 'hidden' },
  aiBriefHeader: { flexDirection: 'row', alignItems: 'center', gap: 6, marginBottom: 8 },
  aiBriefLabel: { color: '#C4B5FD', fontSize: FontSize.xs, fontWeight: '800', letterSpacing: 1.5 },
  aiBriefTitle: { color: '#FFF', fontSize: FontSize.xxl, fontWeight: '900', marginBottom: 16 },
  aiBriefItems: { gap: 10, marginBottom: 16 },
  aiBriefItem: { flexDirection: 'row', alignItems: 'center', gap: 12, backgroundColor: 'rgba(0,0,0,0.2)', borderRadius: BorderRadius.md, padding: 12, borderWidth: 1, borderColor: 'rgba(255,255,255,0.08)' },
  aiBriefIcon: { width: 32, height: 32, borderRadius: 8, justifyContent: 'center', alignItems: 'center' },
  aiBriefItemTitle: { color: '#FFF', fontSize: FontSize.md, fontWeight: '700' },
  aiBriefItemDesc: { color: '#94A3B8', fontSize: FontSize.sm, marginTop: 2 },
  startBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, backgroundColor: '#FFF', borderRadius: BorderRadius.md, paddingVertical: 14 },
  startBtnText: { color: '#1E1B4B', fontSize: FontSize.md, fontWeight: '800' },

  statsGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 12, marginBottom: 16 },
  statCard: { width: '47%' as any, backgroundColor: Colors.surface, borderRadius: BorderRadius.xl, padding: 16, borderWidth: 1, borderColor: Colors.border, shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.03, shadowRadius: 4, elevation: 1 },
  statIcon: { width: 44, height: 44, borderRadius: 12, justifyContent: 'center', alignItems: 'center', marginBottom: 12 },
  statValue: { fontSize: FontSize.h1, fontWeight: '900', color: Colors.textPrimary },
  statLabel: { fontSize: FontSize.xs, fontWeight: '800', color: Colors.textSecondary, textTransform: 'uppercase', letterSpacing: 0.5, marginTop: 2, marginBottom: 6 },
  statTrendRow: { flexDirection: 'row', alignItems: 'center', gap: 4 },
  statTrend: { fontSize: FontSize.xs, fontWeight: '600' },

  shortcutsScroll: { marginBottom: 16 },
  shortcutBtn: { flexDirection: 'row', alignItems: 'center', gap: 8, backgroundColor: Colors.surface, borderRadius: BorderRadius.md, paddingHorizontal: 14, paddingVertical: 12, borderWidth: 1, borderColor: Colors.borderLight },
  shortcutText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.slate700 },

  sectionCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 20, marginBottom: 16, borderWidth: 1, borderColor: Colors.borderLight },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 },
  sectionTitle: { fontSize: FontSize.lg, fontWeight: '900', color: Colors.textPrimary },
  viewAllText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.brandBlue },

  appointmentRow: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 12, borderRadius: BorderRadius.lg, borderWidth: 1, borderColor: Colors.borderLight, marginBottom: 8 },
  appointmentAvatar: { width: 44, height: 44, borderRadius: 14, borderWidth: 2, borderColor: '#FFF' },
  appointmentName: { fontSize: FontSize.base, fontWeight: '700', color: Colors.textPrimary },
  appointmentMeta: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2, fontWeight: '500' },
  statusBadge: { paddingHorizontal: 10, paddingVertical: 5, borderRadius: 8 },
  statusText: { fontSize: FontSize.xs, fontWeight: '700' },

  featureGrid: { flexDirection: 'row', gap: 12, marginBottom: 16 },
  featureCard: { flex: 1, backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 18, borderWidth: 1 },
  featureIconBox: { width: 44, height: 44, borderRadius: 12, justifyContent: 'center', alignItems: 'center', marginBottom: 12, shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.05, shadowRadius: 4, elevation: 1 },
  featureTitle: { fontSize: FontSize.lg, fontWeight: '900', color: Colors.textPrimary, marginBottom: 4 },
  featureDesc: { fontSize: FontSize.sm, color: Colors.textSecondary, fontWeight: '500', marginBottom: 12 },
  featureLink: { flexDirection: 'row', alignItems: 'center', gap: 4 },
  featureLinkText: { fontSize: FontSize.sm, fontWeight: '700' },

  emergencyCard: { flexDirection: 'row', alignItems: 'center', gap: 12, backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 16, marginBottom: 16, borderWidth: 1, borderColor: Colors.redLight, overflow: 'hidden' },
  emergencyStripe: { position: 'absolute', left: 0, top: 0, bottom: 0, width: 4, backgroundColor: Colors.red },
  emergencyTitle: { fontSize: FontSize.md, fontWeight: '900', color: Colors.red },
  emergencyDesc: { fontSize: FontSize.sm, fontWeight: '600', color: Colors.slate600, marginTop: 2 },
  emergencyBadge: { backgroundColor: Colors.red, borderRadius: 4, paddingHorizontal: 5, paddingVertical: 1 },
  emergencyBadgeText: { color: '#FFF', fontSize: 9, fontWeight: '800' },

  notifRow: { flexDirection: 'row', gap: 10, marginBottom: 14, alignItems: 'flex-start' },
  notifDot: { width: 8, height: 8, borderRadius: 4, marginTop: 6 },
  notifTitle: { fontSize: FontSize.md, fontWeight: '700', color: Colors.textPrimary },
  notifDesc: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 },
  notifTime: { fontSize: FontSize.xs, fontWeight: '700', color: Colors.textTertiary, marginTop: 4, textTransform: 'uppercase' },
  emptyText: { textAlign: 'center', color: Colors.textSecondary, paddingVertical: 20, fontSize: FontSize.md },
});
