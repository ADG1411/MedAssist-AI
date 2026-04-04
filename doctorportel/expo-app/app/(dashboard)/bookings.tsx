import { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Image, RefreshControl, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import { supabase } from '../../services/supabase';

interface BookingItem {
  id: string; patient_id: string; slot_time: string; status: string; amount: number;
  payment_status: string; doctor_name: string; jitsi_room_id: string | null; created_at: string;
  patientName?: string;
}

export default function BookingsScreen() {
  const router = useRouter();
  const [bookings, setBookings] = useState<BookingItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const loadBookings = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { setLoading(false); return; }

      const { data, error } = await supabase.from('bookings').select('*')
        .eq('doctor_id', user.id).in('status', ['confirmed', 'pending'])
        .order('created_at', { ascending: false });

      if (data && !error) {
        const enriched = await Promise.all(data.map(async (b: any) => {
          const { data: p } = await supabase.from('profiles').select('name').eq('id', b.patient_id).maybeSingle();
          return { ...b, patientName: p?.name || `Patient ${b.patient_id.substring(0, 8)}` };
        }));
        setBookings(enriched);
      }
    } catch (e) { console.warn(e); }
    setLoading(false);
    setRefreshing(false);
  };

  useEffect(() => { loadBookings(); }, []);

  const statusColor = (s: string) => {
    if (s === 'confirmed') return { bg: Colors.emeraldBg, text: Colors.emerald };
    if (s === 'pending') return { bg: Colors.amberBg, text: Colors.amber };
    if (s === 'completed') return { bg: Colors.blueBg, text: Colors.brandBlue };
    return { bg: Colors.slate100, text: Colors.slate600 };
  };

  return (
    <ScrollView style={styles.container} refreshControl={<RefreshControl refreshing={refreshing} onRefresh={() => { setRefreshing(true); loadBookings(); }} tintColor={Colors.brandBlue} />}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={22} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.pageTitle}>Live Bookings</Text>
      </View>

      {loading ? (
        <View style={styles.loadingBox}><ActivityIndicator size="large" color={Colors.brandBlue} /></View>
      ) : bookings.length === 0 ? (
        <View style={styles.emptyBox}>
          <Ionicons name="calendar-outline" size={48} color={Colors.slate300} />
          <Text style={styles.emptyTitle}>No Active Bookings</Text>
          <Text style={styles.emptyDesc}>Patient bookings from the MedAssist app will appear here</Text>
        </View>
      ) : (
        <View style={{ padding: 16, gap: 10 }}>
          {bookings.map(b => {
            const sc = statusColor(b.status);
            return (
              <View key={b.id} style={styles.bookingCard}>
                <View style={styles.bookingHeader}>
                  <Image source={{ uri: `https://ui-avatars.com/api/?name=${encodeURIComponent(b.patientName || '')}&background=3b82f6&color=fff` }} style={styles.bookingAvatar} />
                  <View style={{ flex: 1 }}>
                    <Text style={styles.bookingName}>{b.patientName}</Text>
                    <Text style={styles.bookingTime}>🕐 {b.slot_time}</Text>
                  </View>
                  <View style={[styles.statusBadge, { backgroundColor: sc.bg }]}>
                    <Text style={[styles.statusText, { color: sc.text }]}>{b.status}</Text>
                  </View>
                </View>
                <View style={styles.bookingMeta}>
                  <Text style={styles.bookingMetaText}>💰 ₹{b.amount || 0} • {b.payment_status}</Text>
                  <Text style={styles.bookingMetaText}>📅 {new Date(b.created_at).toLocaleDateString()}</Text>
                </View>
                <View style={styles.bookingActions}>
                  <TouchableOpacity style={[styles.actionBtn, { backgroundColor: Colors.emeraldBg }]}>
                    <Ionicons name="videocam" size={16} color={Colors.emerald} />
                    <Text style={[styles.actionBtnText, { color: Colors.emerald }]}>Start Call</Text>
                  </TouchableOpacity>
                  <TouchableOpacity style={[styles.actionBtn, { backgroundColor: Colors.blueBg }]}>
                    <Ionicons name="checkmark-circle" size={16} color={Colors.brandBlue} />
                    <Text style={[styles.actionBtnText, { color: Colors.brandBlue }]}>Complete</Text>
                  </TouchableOpacity>
                </View>
              </View>
            );
          })}
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.background },
  header: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingTop: 56, paddingBottom: 12 },
  backBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.surface, justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: Colors.border },
  pageTitle: { fontSize: FontSize.h1, fontWeight: '900', color: Colors.textPrimary },
  loadingBox: { flex: 1, justifyContent: 'center', alignItems: 'center', paddingTop: 100 },
  emptyBox: { alignItems: 'center', paddingTop: 80, gap: 12, paddingHorizontal: 40 },
  emptyTitle: { fontSize: FontSize.xl, fontWeight: '800', color: Colors.textPrimary },
  emptyDesc: { fontSize: FontSize.md, color: Colors.textSecondary, textAlign: 'center' },
  bookingCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xl, padding: 16, borderWidth: 1, borderColor: Colors.borderLight },
  bookingHeader: { flexDirection: 'row', alignItems: 'center', gap: 12, marginBottom: 12 },
  bookingAvatar: { width: 44, height: 44, borderRadius: 14 },
  bookingName: { fontSize: FontSize.base, fontWeight: '700', color: Colors.textPrimary },
  bookingTime: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 },
  statusBadge: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 8 },
  statusText: { fontSize: FontSize.xs, fontWeight: '700' },
  bookingMeta: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 12 },
  bookingMetaText: { fontSize: FontSize.sm, color: Colors.textSecondary, fontWeight: '500' },
  bookingActions: { flexDirection: 'row', gap: 10 },
  actionBtn: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, paddingVertical: 10, borderRadius: BorderRadius.md },
  actionBtnText: { fontSize: FontSize.sm, fontWeight: '700' },
});
