import { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Share } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import QRCode from 'react-native-qrcode-svg';
import { getBookingByQR } from '../../services/referralService';

export default function TicketScreen() {
  const router = useRouter();
  const { id, qr } = useLocalSearchParams<{ id: string, qr: string }>();
  
  const [ticketData, setTicketData] = useState<any>(null);

  useEffect(() => {
    if (qr) {
      getBookingByQR(qr).then(data => setTicketData(data));
    }
  }, [qr]);

  const handleShare = async () => {
    try {
      await Share.share({
        message: `MedAssist Booking Slip\nProvider: ${ticketData?.provider.name}\nDate: ${ticketData?.booking.date}\nTime: ${ticketData?.booking.time}`,
      });
    } catch (error) {}
  };

  if (!ticketData) {
    return <View style={styles.container} />; // Loading state can be added
  }

  const { booking, referral, provider } = ticketData;

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.iconBtn} onPress={() => router.replace('/(dashboard)')}>
          <Ionicons name="home" size={20} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.pageTitle}>Booking Slip</Text>
        <TouchableOpacity style={styles.iconBtn} onPress={handleShare}>
          <Ionicons name="share-outline" size={20} color={Colors.textPrimary} />
        </TouchableOpacity>
      </View>

      <ScrollView contentContainerStyle={{ padding: 20, paddingBottom: 100 }}>
        
        {/* Ticket Container */}
        <View style={styles.ticketCard}>
          {/* Top Half */}
          <View style={styles.ticketTop}>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
              <View style={styles.badge}><Text style={styles.badgeText}>CONFIRMED</Text></View>
              <Text style={styles.ticketId}>ID: {id?.replace('tkt_', '')}</Text>
            </View>
            
            <Text style={styles.serviceTitle}>{referral.tests}</Text>
            <Text style={styles.providerName}>{provider.name}</Text>

            <View style={styles.infoRow}>
              <View style={styles.infoCol}>
                <Text style={styles.infoLabel}>DATE</Text>
                <Text style={styles.infoValue}>{booking.date}</Text>
              </View>
              <View style={styles.infoCol}>
                <Text style={styles.infoLabel}>TIME</Text>
                <Text style={styles.infoValue}>{booking.time}</Text>
              </View>
            </View>
          </View>

          {/* Ticket Tear Line */}
          <View style={styles.tearLineContainer}>
             <View style={styles.holeLeft} />
             <View style={styles.dashLine} />
             <View style={styles.holeRight} />
          </View>

          {/* Bottom Half (QR) */}
          <View style={styles.ticketBottom}>
            <Text style={styles.qrHelper}>Show this QR code at the reception</Text>
            <View style={styles.qrBox}>
               <QRCode value={decodeURIComponent(qr || '')} size={180} backgroundColor="#FFF" color={Colors.textPrimary} />
            </View>
            <Text style={styles.tokenText}>{decodeURIComponent(qr || '').split('::')[1]}</Text>
          </View>
        </View>

        <View style={styles.actionRow}>
          <TouchableOpacity style={styles.downloadBtn}>
            <Ionicons name="download" size={18} color={Colors.brandBlue} />
            <Text style={styles.downloadText}>Download PDF</Text>
          </TouchableOpacity>
        </View>

      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.brandBlue }, // Blue background to make white ticket pop
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: 20, paddingTop: 60, paddingBottom: 16 },
  pageTitle: { fontSize: FontSize.lg, fontWeight: '800', color: '#FFF' },
  iconBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: 'rgba(255,255,255,0.2)', justifyContent: 'center', alignItems: 'center' },
  
  ticketCard: { backgroundColor: '#FFF', borderRadius: 24, marginTop: 20, shadowColor: '#000', shadowOffset: { width: 0, height: 10 }, shadowOpacity: 0.2, shadowRadius: 20, elevation: 15 },
  
  ticketTop: { padding: 32 },
  badge: { alignSelf: 'flex-start', backgroundColor: Colors.emeraldBg, paddingHorizontal: 12, paddingVertical: 6, borderRadius: BorderRadius.full },
  badgeText: { color: Colors.emerald, fontWeight: '900', fontSize: 10, letterSpacing: 1 },
  ticketId: { color: Colors.slate400, fontSize: FontSize.xs, fontWeight: '700' },
  
  serviceTitle: { fontSize: FontSize.xxl, fontWeight: '900', color: Colors.textPrimary, marginBottom: 8, lineHeight: 32 },
  providerName: { fontSize: FontSize.md, color: Colors.textSecondary, fontWeight: '600', marginBottom: 24 },
  
  infoRow: { flexDirection: 'row', backgroundColor: Colors.slate50, padding: 16, borderRadius: BorderRadius.lg },
  infoCol: { flex: 1 },
  infoLabel: { fontSize: 10, color: Colors.textTertiary, fontWeight: '800', letterSpacing: 1, marginBottom: 4 },
  infoValue: { fontSize: FontSize.lg, color: Colors.brandBlue, fontWeight: '900' },

  tearLineContainer: { flexDirection: 'row', alignItems: 'center', height: 40, overflow: 'hidden' },
  holeLeft: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.brandBlue, marginLeft: -20 },
  dashLine: { flex: 1, height: 2, borderStyle: 'dashed', borderWidth: 1, borderColor: Colors.border, marginHorizontal: 10 },
  holeRight: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.brandBlue, marginRight: -20 },

  ticketBottom: { padding: 32, alignItems: 'center' },
  qrHelper: { fontSize: FontSize.sm, color: Colors.textSecondary, fontWeight: '600', marginBottom: 20,textAlign: 'center' },
  qrBox: { padding: 16, backgroundColor: '#FFF', borderRadius: 16, borderWidth: 1, borderColor: Colors.borderLight },
  tokenText: { marginTop: 16, fontSize: 10, color: Colors.slate400, fontFamily: 'monospace', textAlign: 'center' },

  actionRow: { marginTop: 32, alignItems: 'center' },
  downloadBtn: { flexDirection: 'row', alignItems: 'center', gap: 8, backgroundColor: '#FFF', paddingVertical: 14, paddingHorizontal: 24, borderRadius: BorderRadius.full },
  downloadText: { color: Colors.brandBlue, fontWeight: '800', fontSize: FontSize.sm },
});
