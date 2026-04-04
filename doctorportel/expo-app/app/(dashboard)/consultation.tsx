import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';

export default function ConsultationScreen() {
  const router = useRouter();

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={22} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.pageTitle}>Consultation</Text>
      </View>

      <View style={styles.content}>
        {/* Video Area */}
        <View style={styles.videoArea}>
          <View style={styles.videoPlaceholder}>
            <Ionicons name="videocam" size={60} color={Colors.slate300} />
            <Text style={styles.videoText}>Video call will start here</Text>
          </View>

          {/* Self view */}
          <View style={styles.selfView}>
            <Ionicons name="person" size={24} color={Colors.slate400} />
          </View>
        </View>

        {/* Patient Info */}
        <View style={styles.patientInfo}>
          <View style={styles.patientAvatar}>
            <Ionicons name="person" size={24} color={Colors.brandBlue} />
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.patientName}>Waiting for patient...</Text>
            <Text style={styles.patientMeta}>Select a booking to start</Text>
          </View>
        </View>

        {/* Controls */}
        <View style={styles.controls}>
          <TouchableOpacity style={[styles.controlBtn, { backgroundColor: Colors.slate100 }]}>
            <Ionicons name="mic" size={24} color={Colors.textPrimary} />
          </TouchableOpacity>
          <TouchableOpacity style={[styles.controlBtn, { backgroundColor: Colors.slate100 }]}>
            <Ionicons name="videocam" size={24} color={Colors.textPrimary} />
          </TouchableOpacity>
          <TouchableOpacity style={[styles.controlBtn, { backgroundColor: Colors.red }]}>
            <Ionicons name="call" size={24} color="#FFF" />
          </TouchableOpacity>
          <TouchableOpacity style={[styles.controlBtn, { backgroundColor: Colors.slate100 }]}>
            <Ionicons name="chatbubble" size={24} color={Colors.textPrimary} />
          </TouchableOpacity>
          <TouchableOpacity style={[styles.controlBtn, { backgroundColor: Colors.slate100 }]}>
            <Ionicons name="document-text" size={24} color={Colors.textPrimary} />
          </TouchableOpacity>
        </View>

        {/* Quick Actions */}
        <View style={styles.quickActions}>
          <TouchableOpacity style={styles.quickAction} onPress={() => router.push('/(dashboard)/prescription')}>
            <Ionicons name="medkit" size={18} color={Colors.purple} />
            <Text style={styles.quickActionText}>Write Rx</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.quickAction} onPress={() => router.push('/(dashboard)/referral')}>
            <Ionicons name="share-social" size={18} color={Colors.brandBlue} />
            <Text style={styles.quickActionText}>Referral</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.quickAction}>
            <Ionicons name="document-attach" size={18} color={Colors.emerald} />
            <Text style={styles.quickActionText}>Reports</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.background },
  header: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingTop: 56, paddingBottom: 12 },
  backBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.surface, justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: Colors.border },
  pageTitle: { fontSize: FontSize.h1, fontWeight: '900', color: Colors.textPrimary },
  content: { flex: 1, padding: 16, gap: 16 },
  videoArea: { flex: 1, backgroundColor: Colors.slate900, borderRadius: BorderRadius.xxl, justifyContent: 'center', alignItems: 'center', minHeight: 300, overflow: 'hidden' },
  videoPlaceholder: { alignItems: 'center', gap: 12 },
  videoText: { color: Colors.slate400, fontSize: FontSize.md, fontWeight: '600' },
  selfView: { position: 'absolute', bottom: 16, right: 16, width: 80, height: 100, borderRadius: 16, backgroundColor: Colors.slate800, justifyContent: 'center', alignItems: 'center', borderWidth: 2, borderColor: 'rgba(255,255,255,0.2)' },
  patientInfo: { flexDirection: 'row', alignItems: 'center', gap: 12, backgroundColor: Colors.surface, padding: 16, borderRadius: BorderRadius.xl, borderWidth: 1, borderColor: Colors.borderLight },
  patientAvatar: { width: 44, height: 44, borderRadius: 14, backgroundColor: Colors.blueBg, justifyContent: 'center', alignItems: 'center' },
  patientName: { fontSize: FontSize.base, fontWeight: '700', color: Colors.textPrimary },
  patientMeta: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 },
  controls: { flexDirection: 'row', justifyContent: 'center', gap: 16 },
  controlBtn: { width: 52, height: 52, borderRadius: 26, justifyContent: 'center', alignItems: 'center' },
  quickActions: { flexDirection: 'row', gap: 10 },
  quickAction: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, backgroundColor: Colors.surface, paddingVertical: 12, borderRadius: BorderRadius.md, borderWidth: 1, borderColor: Colors.borderLight },
  quickActionText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.textPrimary },
});
