import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';

const ALERTS = [
  { id: '1', patient: 'Michael J.', age: 58, condition: 'Chest Pain — possible MI', severity: 'critical', time: '2 min ago', vitals: 'BP: 180/100 • HR: 110 • SpO2: 94%' },
  { id: '2', patient: 'Sarah K.', age: 32, condition: 'Severe Allergic Reaction', severity: 'high', time: '15 min ago', vitals: 'BP: 90/60 • HR: 120 • SpO2: 96%' },
  { id: '3', patient: 'David L.', age: 45, condition: 'Asthma Exacerbation', severity: 'medium', time: '1 hr ago', vitals: 'BP: 130/85 • HR: 95 • SpO2: 91%' },
];

export default function EmergencyScreen() {
  const router = useRouter();

  const severityStyle = (s: string) => {
    if (s === 'critical') return { bg: Colors.red, text: '#FFF', border: Colors.red };
    if (s === 'high') return { bg: Colors.amberBg, text: Colors.amber, border: Colors.amberLight };
    return { bg: Colors.blueBg, text: Colors.brandBlue, border: Colors.blueLight };
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={22} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.pageTitle}>🚨 Emergency</Text>
      </View>

      <View style={{ padding: 16, gap: 12 }}>
        {/* Alert Banner */}
        <View style={styles.alertBanner}>
          <Ionicons name="alert-circle" size={24} color="#FFF" />
          <View style={{ flex: 1 }}>
            <Text style={styles.alertBannerTitle}>{ALERTS.length} Active Alerts</Text>
            <Text style={styles.alertBannerDesc}>Critical cases require immediate attention</Text>
          </View>
        </View>

        {ALERTS.map(alert => {
          const ss = severityStyle(alert.severity);
          return (
            <View key={alert.id} style={[styles.alertCard, { borderLeftColor: ss.bg, borderLeftWidth: 4 }]}>
              <View style={styles.alertHeader}>
                <View style={{ flex: 1 }}>
                  <Text style={styles.alertPatient}>{alert.patient}, {alert.age}y</Text>
                  <Text style={styles.alertCondition}>{alert.condition}</Text>
                </View>
                <View style={[styles.severityBadge, { backgroundColor: ss.bg }]}>
                  <Text style={[styles.severityText, { color: ss.text }]}>{alert.severity.toUpperCase()}</Text>
                </View>
              </View>
              <Text style={styles.alertVitals}>{alert.vitals}</Text>
              <Text style={styles.alertTime}>{alert.time}</Text>
              <View style={styles.alertActions}>
                <TouchableOpacity style={[styles.alertBtn, { backgroundColor: Colors.red }]}>
                  <Ionicons name="call" size={16} color="#FFF" />
                  <Text style={styles.alertBtnText}>Respond Now</Text>
                </TouchableOpacity>
                <TouchableOpacity style={[styles.alertBtn, { backgroundColor: Colors.blueBg }]}>
                  <Ionicons name="document-text" size={16} color={Colors.brandBlue} />
                  <Text style={[styles.alertBtnText, { color: Colors.brandBlue }]}>View Record</Text>
                </TouchableOpacity>
              </View>
            </View>
          );
        })}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.background },
  header: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingTop: 56, paddingBottom: 12 },
  backBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.surface, justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: Colors.border },
  pageTitle: { fontSize: FontSize.h1, fontWeight: '900', color: Colors.textPrimary },
  alertBanner: { flexDirection: 'row', alignItems: 'center', gap: 12, backgroundColor: Colors.red, borderRadius: BorderRadius.xl, padding: 16 },
  alertBannerTitle: { color: '#FFF', fontSize: FontSize.lg, fontWeight: '800' },
  alertBannerDesc: { color: 'rgba(255,255,255,0.8)', fontSize: FontSize.sm, marginTop: 2 },
  alertCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xl, padding: 16, borderWidth: 1, borderColor: Colors.borderLight },
  alertHeader: { flexDirection: 'row', alignItems: 'flex-start', marginBottom: 8 },
  alertPatient: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary },
  alertCondition: { fontSize: FontSize.md, color: Colors.red, fontWeight: '600', marginTop: 2 },
  severityBadge: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 6 },
  severityText: { fontSize: FontSize.xs, fontWeight: '800' },
  alertVitals: { fontSize: FontSize.sm, color: Colors.textSecondary, fontWeight: '500', marginBottom: 4, backgroundColor: Colors.slate50, padding: 8, borderRadius: 8 },
  alertTime: { fontSize: FontSize.xs, fontWeight: '700', color: Colors.textTertiary, textTransform: 'uppercase', marginBottom: 12 },
  alertActions: { flexDirection: 'row', gap: 10 },
  alertBtn: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, paddingVertical: 12, borderRadius: BorderRadius.md },
  alertBtnText: { fontSize: FontSize.sm, fontWeight: '700', color: '#FFF' },
});
