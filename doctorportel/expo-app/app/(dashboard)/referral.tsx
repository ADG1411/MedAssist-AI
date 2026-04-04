import { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import QRCode from 'react-native-qrcode-svg';
import { supabase } from '../../services/supabase';

const REFERRAL_TYPES = ['specialist', 'hospital', 'lab', 'emergency'] as const;

const MOCK_REFERRALS = [
  { id: '1', patient_name: 'Rahul Sharma', type: 'specialist', diagnosis: 'Hypertension', doctor_name: 'Dr. Lee', created_at: '2025-01-15', status: 'active' },
  { id: '2', patient_name: 'Priya Verma', type: 'lab', diagnosis: 'Iron Deficiency', doctor_name: 'PathLab', created_at: '2025-01-12', status: 'completed' },
];

export default function ReferralScreen() {
  const router = useRouter();
  const [tab, setTab] = useState<'list' | 'create'>('list');
  const [form, setForm] = useState({ patient_name: '', diagnosis: '', notes: '', reason: '', type: 'specialist' as string });
  const [selectedQR, setSelectedQR] = useState<string | null>(null);

  const handleCreate = async () => {
    if (!form.patient_name || !form.diagnosis || !form.reason) {
      Alert.alert('Error', 'Fill in patient name, diagnosis, and reason');
      return;
    }
    Alert.alert('✅ Referral Created', `Referral for ${form.patient_name} to ${form.type}`);
    setTab('list');
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={22} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.pageTitle}>Referrals</Text>
      </View>

      <View style={{ padding: 16 }}>
        {/* Tabs */}
        <View style={styles.tabs}>
          <TouchableOpacity style={[styles.tab, tab === 'list' && styles.tabActive]} onPress={() => setTab('list')}>
            <Text style={[styles.tabText, tab === 'list' && styles.tabTextActive]}>My Referrals</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[styles.tab, tab === 'create' && styles.tabActive]} onPress={() => setTab('create')}>
            <Text style={[styles.tabText, tab === 'create' && styles.tabTextActive]}>Create New</Text>
          </TouchableOpacity>
        </View>

        {tab === 'list' ? (
          <View style={{ gap: 10, marginTop: 16 }}>
            {MOCK_REFERRALS.map(r => (
              <View key={r.id} style={styles.referralCard}>
                <View style={styles.referralHeader}>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.referralName}>{r.patient_name}</Text>
                    <Text style={styles.referralDiag}>{r.diagnosis} → {r.doctor_name}</Text>
                  </View>
                  <View style={[styles.typeBadge, { backgroundColor: r.type === 'specialist' ? Colors.purpleBg : r.type === 'lab' ? Colors.blueBg : Colors.amberBg }]}>
                    <Text style={[styles.typeText, { color: r.type === 'specialist' ? Colors.purple : r.type === 'lab' ? Colors.brandBlue : Colors.amber }]}>
                      {r.type}
                    </Text>
                  </View>
                </View>
                <View style={styles.referralMeta}>
                  <Text style={styles.referralDate}>📅 {r.created_at}</Text>
                  <TouchableOpacity onPress={() => setSelectedQR(selectedQR === r.id ? null : r.id)}>
                    <Ionicons name="qr-code" size={20} color={Colors.brandBlue} />
                  </TouchableOpacity>
                </View>
                {selectedQR === r.id && (
                  <View style={styles.qrBox}>
                    <QRCode value={`REFQR::${r.id}::${r.patient_name}`} size={160} backgroundColor="#FFF" color={Colors.textPrimary} />
                    <Text style={styles.qrLabel}>Share this QR with the patient</Text>
                  </View>
                )}
              </View>
            ))}
          </View>
        ) : (
          <View style={styles.formCard}>
            <Text style={styles.formTitle}>New Referral</Text>
            <TextInput style={styles.input} placeholder="Patient Name" placeholderTextColor={Colors.slate400}
              value={form.patient_name} onChangeText={v => setForm(p => ({ ...p, patient_name: v }))} />
            <TextInput style={styles.input} placeholder="Diagnosis" placeholderTextColor={Colors.slate400}
              value={form.diagnosis} onChangeText={v => setForm(p => ({ ...p, diagnosis: v }))} />
            <TextInput style={[styles.input, { minHeight: 70, textAlignVertical: 'top' }]} placeholder="Reason for referral"
              placeholderTextColor={Colors.slate400} value={form.reason} onChangeText={v => setForm(p => ({ ...p, reason: v }))} multiline />
            <TextInput style={[styles.input, { minHeight: 70, textAlignVertical: 'top' }]} placeholder="Clinical notes..."
              placeholderTextColor={Colors.slate400} value={form.notes} onChangeText={v => setForm(p => ({ ...p, notes: v }))} multiline />

            <Text style={styles.typeLabel}>Referral Type</Text>
            <View style={styles.typeRow}>
              {REFERRAL_TYPES.map(t => (
                <TouchableOpacity key={t} style={[styles.typeChip, form.type === t && styles.typeChipActive]}
                  onPress={() => setForm(p => ({ ...p, type: t }))}>
                  <Text style={[styles.typeChipText, form.type === t && styles.typeChipTextActive]}>{t}</Text>
                </TouchableOpacity>
              ))}
            </View>

            <TouchableOpacity style={styles.createBtn} onPress={handleCreate}>
              <Text style={styles.createBtnText}>Create Referral</Text>
            </TouchableOpacity>
          </View>
        )}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.background },
  header: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingTop: 56, paddingBottom: 12 },
  backBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.surface, justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: Colors.border },
  pageTitle: { fontSize: FontSize.h1, fontWeight: '900', color: Colors.textPrimary },
  tabs: { flexDirection: 'row', backgroundColor: Colors.surface, borderRadius: BorderRadius.lg, padding: 4, borderWidth: 1, borderColor: Colors.border },
  tab: { flex: 1, alignItems: 'center', paddingVertical: 10, borderRadius: BorderRadius.md },
  tabActive: { backgroundColor: Colors.brandBlue },
  tabText: { fontSize: FontSize.md, fontWeight: '700', color: Colors.slate600 },
  tabTextActive: { color: '#FFF' },
  referralCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xl, padding: 16, borderWidth: 1, borderColor: Colors.borderLight },
  referralHeader: { flexDirection: 'row', alignItems: 'flex-start', marginBottom: 8 },
  referralName: { fontSize: FontSize.base, fontWeight: '700', color: Colors.textPrimary },
  referralDiag: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 },
  typeBadge: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 6 },
  typeText: { fontSize: FontSize.xs, fontWeight: '700', textTransform: 'capitalize' },
  referralMeta: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  referralDate: { fontSize: FontSize.sm, color: Colors.textTertiary },
  qrBox: { alignItems: 'center', paddingTop: 16, gap: 10 },
  qrLabel: { fontSize: FontSize.sm, color: Colors.textSecondary },
  formCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 20, marginTop: 16, gap: 12, borderWidth: 1, borderColor: Colors.borderLight },
  formTitle: { fontSize: FontSize.xl, fontWeight: '800', color: Colors.textPrimary },
  input: { backgroundColor: Colors.slate50, borderRadius: BorderRadius.md, padding: 14, fontSize: FontSize.md, color: Colors.textPrimary, borderWidth: 1, borderColor: Colors.border },
  typeLabel: { fontSize: FontSize.md, fontWeight: '700', color: Colors.textPrimary },
  typeRow: { flexDirection: 'row', gap: 8, flexWrap: 'wrap' },
  typeChip: { paddingHorizontal: 14, paddingVertical: 8, borderRadius: BorderRadius.full, backgroundColor: Colors.slate50, borderWidth: 1, borderColor: Colors.border },
  typeChipActive: { backgroundColor: Colors.brandBlue, borderColor: Colors.brandBlue },
  typeChipText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.slate600 },
  typeChipTextActive: { color: '#FFF' },
  createBtn: { backgroundColor: Colors.brandBlue, paddingVertical: 16, borderRadius: BorderRadius.lg, alignItems: 'center', marginTop: 8 },
  createBtnText: { color: '#FFF', fontSize: FontSize.lg, fontWeight: '700' },
});
