import { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator, Alert } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import { getBookingByQR } from '../../services/referralService';

export default function ProviderTicketView() {
  const router = useRouter();
  const { qr } = useLocalSearchParams<{ qr: string }>();
  
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [status, setStatus] = useState('Pending');

  useEffect(() => {
    if (qr) {
      getBookingByQR(qr).then(res => {
        setData(res);
        if (res) setStatus(res.booking.status);
        setLoading(false);
      });
    }
  }, [qr]);

  if (loading) {
    return <View style={[styles.container, { justifyContent: 'center' }]}><ActivityIndicator size="large" color={Colors.brandBlue} /></View>;
  }

  if (!data) {
    return (
      <View style={[styles.container, { justifyContent: 'center', alignItems: 'center' }]}>
        <Ionicons name="warning" size={48} color={Colors.red} />
        <Text style={{ marginTop: 16, fontSize: FontSize.lg }}>Invalid or Expired Ticket Token</Text>
        <TouchableOpacity style={{ marginTop: 24 }} onPress={() => router.back()}>
          <Text style={{ color: Colors.brandBlue, fontWeight: '700' }}>Back to Scanner</Text>
        </TouchableOpacity>
      </View>
    );
  }

  const { booking, referral, provider } = data;

  const markComplete = () => {
    setStatus('Completed');
    Alert.alert('Service Completed', 'The booking has been fulfilled and results will be sent to the referring doctor.');
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.iconBtn} onPress={() => router.back()}>
          <Ionicons name="close" size={20} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.pageTitle}>Provider Portal</Text>
        <View style={{ width: 40 }} />
      </View>

      <ScrollView contentContainerStyle={{ padding: 20 }}>
        
        {/* Verification Alert */}
        <View style={styles.verifiedBox}>
          <Ionicons name="checkmark-circle" size={24} color="#FFF" />
          <View style={{ marginLeft: 12 }}>
            <Text style={styles.verifiedTitle}>Ticket Verified</Text>
            <Text style={styles.verifiedSub}>Booking ID: {booking.id}</Text>
          </View>
        </View>

        <Text style={styles.sectionLabel}>Service Requirements</Text>
        <View style={styles.moduleCard}>
          <View style={styles.row}><Text style={styles.label}>Requested By</Text><Text style={styles.value}>Dr. MedAssist User</Text></View>
          <View style={styles.row}><Text style={styles.label}>Patient Diagnosis</Text><Text style={styles.value}>{referral.diagnosis}</Text></View>
          <View style={styles.divider} />
          
          <Text style={[styles.label, { marginBottom: 6 }]}>Tests / Procedures to Perform</Text>
          <View style={styles.highlightBox}>
             <Text style={styles.highlightText}>{referral.tests}</Text>
          </View>

          {referral.notes ? (
            <View style={{ marginTop: 16 }}>
               <Text style={[styles.label, { marginBottom: 6 }]}>Referring Doctor Notes</Text>
               <View style={styles.notesBox}>
                 <Ionicons name="information-circle" size={16} color={Colors.slate500} style={{ marginRight: 6 }} />
                 <Text style={styles.notesContent}>{referral.notes}</Text>
               </View>
            </View>
          ) : null}
        </View>

        <Text style={styles.sectionLabel}>Booking Metadata</Text>
        <View style={styles.moduleCard}>
           <View style={styles.row}><Text style={styles.label}>Scheduled For</Text><Text style={styles.value}>{booking.date} at {booking.time}</Text></View>
           <View style={styles.row}><Text style={styles.label}>Amount Paid</Text><Text style={styles.value}>₹{booking.amount}</Text></View>
           <View style={styles.row}><Text style={styles.label}>Payment Status</Text><Text style={{ color: Colors.emerald, fontWeight: '800' }}>PAID</Text></View>
        </View>

        {status === 'Pending' || status === 'Confirmed' ? (
          <TouchableOpacity style={styles.actionBtn} onPress={markComplete}>
            <Ionicons name="checkmark-done" size={20} color="#FFF" />
            <Text style={styles.actionText}>Mark Service Completed</Text>
          </TouchableOpacity>
        ) : (
          <View style={styles.completedBox}>
            <Ionicons name="checkmark-circle" size={20} color={Colors.emerald} />
            <Text style={styles.completedText}>Service marked as fulfilled</Text>
          </View>
        )}

      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.slate50 },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: 20, paddingTop: 60, paddingBottom: 16, backgroundColor: Colors.surface, borderBottomWidth: 1, borderBottomColor: Colors.borderLight },
  pageTitle: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.brandBlue },
  iconBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.blueBg, justifyContent: 'center', alignItems: 'center' },

  verifiedBox: { flexDirection: 'row', alignItems: 'center', backgroundColor: Colors.emerald, padding: 16, borderRadius: BorderRadius.lg, marginBottom: 24, shadowColor: Colors.emerald, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.2, shadowRadius: 8, elevation: 4 },
  verifiedTitle: { color: '#FFF', fontSize: FontSize.lg, fontWeight: '900' },
  verifiedSub: { color: 'rgba(255,255,255,0.8)', fontSize: FontSize.sm, fontWeight: '600' },

  sectionLabel: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary, marginBottom: 12 },
  moduleCard: { backgroundColor: Colors.surface, padding: 20, borderRadius: BorderRadius.xl, marginBottom: 24, borderWidth: 1, borderColor: Colors.borderLight },
  
  row: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 },
  label: { fontSize: FontSize.sm, color: Colors.textSecondary, fontWeight: '700' },
  value: { fontSize: FontSize.md, color: Colors.textPrimary, fontWeight: '800' },
  divider: { height: 1, backgroundColor: Colors.borderLight, marginVertical: 16 },

  highlightBox: { backgroundColor: Colors.blueBg, padding: 16, borderRadius: BorderRadius.md, borderWidth: 1, borderColor: Colors.blueLight },
  highlightText: { color: Colors.brandBlue, fontSize: FontSize.lg, fontWeight: '800' },

  notesBox: { flexDirection: 'row', backgroundColor: Colors.slate50, padding: 12, borderRadius: BorderRadius.md },
  notesContent: { flex: 1, color: Colors.slate700, fontSize: FontSize.sm, fontStyle: 'italic', lineHeight: 20 },

  actionBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, backgroundColor: Colors.textPrimary, paddingVertical: 16, borderRadius: BorderRadius.lg, marginTop: 10 },
  actionText: { color: '#FFF', fontSize: FontSize.md, fontWeight: '700' },

  completedBox: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, backgroundColor: Colors.emeraldBg, paddingVertical: 16, borderRadius: BorderRadius.lg, marginTop: 10, borderWidth: 1, borderColor: Colors.emeraldLight },
  completedText: { color: Colors.emerald, fontSize: FontSize.md, fontWeight: '800' },
});
