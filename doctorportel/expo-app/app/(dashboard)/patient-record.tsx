import { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator, Linking } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import { getPatientById, getPatientVitals, getPatientRecords, getPatientMedications, getPatientFamily, generateAISummary, PatientData, VitalRecord, MedicalRecord, Medication, FamilyMember, AISummary } from '../../services/patientService';

export default function PatientRecordScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string; }>();

  const [loading, setLoading] = useState(true);
  const [patient, setPatient] = useState<PatientData | null>(null);
  const [vitals, setVitals] = useState<VitalRecord[]>([]);
  const [records, setRecords] = useState<MedicalRecord[]>([]);
  const [meds, setMeds] = useState<Medication[]>([]);
  const [family, setFamily] = useState<FamilyMember[]>([]);
  
  const [aiLoading, setAiLoading] = useState(false);
  const [aiSummary, setAiSummary] = useState<AISummary | null>(null);

  useEffect(() => {
    if (id) loadData(id);
  }, [id]);

  const loadData = async (patientId: string) => {
    setLoading(true);
    try {
      const p = await getPatientById(patientId);
      if (!p) return;
      setPatient(p);
      
      const [v, r, m, f] = await Promise.all([
        getPatientVitals(patientId),
        getPatientRecords(patientId),
        getPatientMedications(patientId),
        getPatientFamily(patientId)
      ]);
      
      setVitals(v);
      setRecords(r);
      setMeds(m);
      setFamily(f);

      // Load AI summary
      setAiLoading(true);
      const summary = await generateAISummary(p, v, r, m);
      setAiSummary(summary);
    } catch (e) {
      console.warn(e);
    } finally {
      setLoading(false);
      setAiLoading(false);
    }
  };

  const handleCall = (phone: string) => {
    Linking.openURL(`tel:${phone}`);
  };

  const recordIcon = (type: string) => {
    switch (type) {
      case 'prescription': return { icon: 'medkit' as const, color: Colors.brandBlue, bg: Colors.blueBg };
      case 'lab_report': return { icon: 'flask' as const, color: Colors.purple, bg: Colors.purpleBg };
      case 'imaging': return { icon: 'scan' as const, color: Colors.emerald, bg: Colors.emeraldBg };
      default: return { icon: 'document' as const, color: Colors.slate600, bg: Colors.slate100 };
    }
  };

  if (loading || !patient) {
    return (
      <View style={[styles.container, { justifyContent: 'center', alignItems: 'center' }]}>
        <ActivityIndicator size="large" color={Colors.brandBlue} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={22} color={Colors.textPrimary} />
        </TouchableOpacity>
        <View style={{ flex: 1, paddingRight: 40 }}>
          <Text style={styles.pageTitle} numberOfLines={1}>{patient.name}</Text>
          <Text style={styles.pageSubtitle}>ID: {patient.id} • {patient.age}y {patient.gender}</Text>
        </View>
      </View>

      <ScrollView contentContainerStyle={{ padding: 16, paddingBottom: 150 }}>
        
        {/* Patient Info */}
        <View style={styles.card}>
          <View style={styles.infoRow}>
            <View style={styles.infoCol}>
              <Text style={styles.infoLabel}>Blood Group</Text>
              <Text style={styles.infoValue}>{patient.blood_group}</Text>
            </View>
            <View style={styles.infoCol}>
              <Text style={styles.infoLabel}>Last Visit</Text>
              <Text style={styles.infoValue}>{patient.lastVisit}</Text>
            </View>
            <View style={styles.infoCol}>
              <Text style={styles.infoLabel}>Visits</Text>
              <Text style={styles.infoValue}>{patient.visitCount}</Text>
            </View>
          </View>
          
          {patient.allergies.length > 0 && (
            <View style={styles.tagBox}>
              <Text style={styles.tagLabel}>Allergies:</Text>
              <View style={styles.tagRow}>
                {patient.allergies.map(a => (
                  <View key={a} style={styles.allergyTag}><Text style={styles.allergyText}>{a}</Text></View>
                ))}
              </View>
            </View>
          )}

          {patient.chronic_conditions.length > 0 && (
            <View style={styles.tagBox}>
              <Text style={styles.tagLabel}>Chronic Conditions:</Text>
              <View style={styles.tagRow}>
                {patient.chronic_conditions.map(c => (
                  <View key={c} style={styles.chronicTag}><Text style={styles.chronicText}>{c}</Text></View>
                ))}
              </View>
            </View>
          )}
        </View>

        {/* AI AIInsights */}
        <View style={styles.aiCard}>
          <View style={styles.aiHeader}>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
              <Ionicons name="sparkles" size={16} color="#C4B5FD" />
              <Text style={styles.aiLabel}>AI CLINICAL INSIGHTS</Text>
            </View>
            {aiLoading && <ActivityIndicator size="small" color="#C4B5FD" />}
          </View>

          {!aiLoading && aiSummary ? (
            <View>
              <View style={[styles.riskBadge, 
                aiSummary.risk_level === 'high' ? styles.riskHigh : 
                aiSummary.risk_level === 'medium' ? styles.riskMedium : styles.riskLow]}>
                <Text style={styles.riskBadgeText}>Risk Level: {aiSummary.risk_level.toUpperCase()}</Text>
              </View>

              <Text style={styles.aiText}>{aiSummary.summary}</Text>
              
              <View style={styles.aiAlerts}>
                {aiSummary.alerts.map((alert, i) => (
                  <View key={i} style={[styles.aiAlert,
                    alert.severity === 'critical' ? { backgroundColor: 'rgba(239,68,68,0.2)' } :
                    alert.severity === 'warning' ? { backgroundColor: 'rgba(245,158,11,0.2)' } :
                    { backgroundColor: 'rgba(56,189,248,0.2)' }
                  ]}>
                    <Ionicons name={alert.severity === 'critical' ? 'alert-circle' : alert.severity === 'warning' ? 'warning' : 'information-circle'} size={14}
                      color={alert.severity === 'critical' ? '#FCA5A5' : alert.severity === 'warning' ? '#FCD34D' : '#7DD3FC'} />
                    <Text style={[styles.aiAlertText, { color: alert.severity === 'critical' ? '#FCA5A5' : alert.severity === 'warning' ? '#FCD34D' : '#7DD3FC' }]}>{alert.text}</Text>
                  </View>
                ))}
              </View>
            </View>
          ) : (
            <Text style={styles.aiText}>Analyzing patient records...</Text>
          )}
        </View>

        {/* Vitals */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>🫀 Recent Vitals</Text>
          <View style={styles.vitalsTable}>
            <View style={styles.vitalsHeaderRow}>
              <Text style={styles.vitalsHeaderCell}>Date</Text>
              <Text style={styles.vitalsHeaderCell}>BP</Text>
              <Text style={styles.vitalsHeaderCell}>HR</Text>
              <Text style={styles.vitalsHeaderCell}>SpO2</Text>
            </View>
            {vitals.slice(0, 3).map((v, i) => {
              const highBP = parseInt(v.bp) > 140;
              return (
                <View key={i} style={styles.vitalsRow}>
                  <Text style={styles.vitalsCell}>{v.date}</Text>
                  <Text style={[styles.vitalsCell, { color: highBP ? Colors.red : Colors.textPrimary, fontWeight: highBP ? '800' : '500' }]}>{v.bp}</Text>
                  <Text style={styles.vitalsCell}>{v.hr}</Text>
                  <Text style={styles.vitalsCell}>{v.spo2}</Text>
                </View>
              );
            })}
          </View>
        </View>

        {/* Medical Records */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>📂 Medical Records</Text>
          {records.length > 0 ? records.map((record) => {
            const ri = recordIcon(record.type);
            return (
              <View key={record.id} style={styles.recordItem}>
                <View style={[styles.recordIconBox, { backgroundColor: ri.bg }]}>
                  <Ionicons name={ri.icon} size={20} color={ri.color} />
                </View>
                <View style={{ flex: 1 }}>
                  <Text style={styles.recordTitle}>{record.title}</Text>
                  <Text style={styles.recordMeta}>{record.date} • {record.doctor}</Text>
                  <Text style={styles.recordDiagnosis}>{record.diagnosis}</Text>
                </View>
              </View>
            );
          }) : (
            <Text style={styles.emptyText}>No records found</Text>
          )}
        </View>

        {/* Family & Emergency */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>👨👩👧 Family & Emergency</Text>
          {family.length > 0 ? family.map((member, i) => (
            <View key={i} style={styles.familyItem}>
              <View style={{ flex: 1 }}>
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                  <Text style={styles.familyTitle}>{member.name}</Text>
                  {member.isEmergency && <View style={styles.emergencyPill}><Text style={styles.emergencyPillText}>Emergency</Text></View>}
                </View>
                <Text style={styles.familyRelation}>{member.relation}</Text>
                <Text style={styles.familyPhone}>{member.phone}</Text>
              </View>
              <TouchableOpacity style={styles.callBtn} onPress={() => handleCall(member.phone)}>
                <Ionicons name="call" size={18} color="#FFF" />
              </TouchableOpacity>
            </View>
          )) : (
             <Text style={styles.emptyText}>No family members linked</Text>
          )}
        </View>

      </ScrollView>

      {/* Quick Actions (Sticky Bottom) */}
      <View style={styles.quickActionsContainer}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.quickActionsScroll}>
          <TouchableOpacity style={styles.qaBtn} onPress={() => router.push('/(dashboard)/prescription')}>
            <View style={[styles.qaIcon, { backgroundColor: Colors.brandBlue }]}><Ionicons name="medkit" size={20} color="#FFF" /></View>
            <Text style={styles.qaText}>Prescribe</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.qaBtn}>
            <View style={[styles.qaIcon, { backgroundColor: Colors.purple }]}><Ionicons name="document-text" size={20} color="#FFF" /></View>
            <Text style={styles.qaText}>Order Test</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.qaBtn} onPress={() => router.push('/(dashboard)/schedule')}>
            <View style={[styles.qaIcon, { backgroundColor: Colors.emerald }]}><Ionicons name="calendar" size={20} color="#FFF" /></View>
            <Text style={styles.qaText}>Follow-up</Text>
          </TouchableOpacity>
          {!!patient.phone && (
            <TouchableOpacity style={styles.qaBtn} onPress={() => handleCall(patient.phone)}>
              <View style={[styles.qaIcon, { backgroundColor: Colors.amber }]}><Ionicons name="call" size={20} color="#FFF" /></View>
              <Text style={styles.qaText}>Call</Text>
            </TouchableOpacity>
          )}
          <TouchableOpacity style={styles.qaBtn}>
            <View style={[styles.qaIcon, { backgroundColor: Colors.slate600 }]}><Ionicons name="add" size={20} color="#FFF" /></View>
            <Text style={styles.qaText}>Add Note</Text>
          </TouchableOpacity>
        </ScrollView>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.background },
  header: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingTop: 56, paddingBottom: 12, backgroundColor: Colors.surface, borderBottomWidth: 1, borderBottomColor: Colors.border },
  backBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.surface, justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: Colors.border },
  pageTitle: { fontSize: FontSize.xl, fontWeight: '900', color: Colors.textPrimary },
  pageSubtitle: { fontSize: FontSize.sm, color: Colors.textSecondary, fontWeight: '600' },
  
  card: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 16, borderWidth: 1, borderColor: Colors.borderLight, gap: 14, marginBottom: 16 },
  cardTitle: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary },
  
  // Info
  infoRow: { flexDirection: 'row', justifyContent: 'space-between' },
  infoCol: { flex: 1 },
  infoLabel: { fontSize: FontSize.xs, fontWeight: '700', color: Colors.textSecondary, textTransform: 'uppercase', marginBottom: 2 },
  infoValue: { fontSize: FontSize.md, fontWeight: '800', color: Colors.textPrimary },
  tagBox: { marginTop: 4 },
  tagLabel: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.textSecondary, marginBottom: 6 },
  tagRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 6 },
  allergyTag: { backgroundColor: Colors.redBg, paddingHorizontal: 10, paddingVertical: 4, borderRadius: 6, borderWidth: 1, borderColor: Colors.redLight },
  allergyText: { color: Colors.red, fontSize: FontSize.sm, fontWeight: '700' },
  chronicTag: { backgroundColor: Colors.amberBg, paddingHorizontal: 10, paddingVertical: 4, borderRadius: 6, borderWidth: 1, borderColor: Colors.amberLight },
  chronicText: { color: Colors.amber, fontSize: FontSize.sm, fontWeight: '700' },

  // AI Summary
  aiCard: { backgroundColor: '#1E1B4B', borderRadius: BorderRadius.xxl, padding: 20, marginBottom: 16 },
  aiHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 },
  aiLabel: { color: '#C4B5FD', fontSize: FontSize.xs, fontWeight: '800', letterSpacing: 1.5 },
  riskBadge: { alignSelf: 'flex-start', paddingHorizontal: 10, paddingVertical: 4, borderRadius: 6, marginBottom: 12, borderWidth: 1 },
  riskHigh: { backgroundColor: 'rgba(239,68,68,0.2)', borderColor: 'rgba(239,68,68,0.5)' },
  riskMedium: { backgroundColor: 'rgba(245,158,11,0.2)', borderColor: 'rgba(245,158,11,0.5)' },
  riskLow: { backgroundColor: 'rgba(52,211,153,0.2)', borderColor: 'rgba(52,211,153,0.5)' },
  riskBadgeText: { color: '#FFF', fontSize: 10, fontWeight: '800', letterSpacing: 1 },
  aiText: { color: '#E2E8F0', fontSize: FontSize.md, lineHeight: 22, marginBottom: 16 },
  aiAlerts: { gap: 8 },
  aiAlert: { flexDirection: 'row', alignItems: 'center', gap: 8, paddingHorizontal: 12, paddingVertical: 8, borderRadius: 8 },
  aiAlertText: { fontSize: FontSize.sm, fontWeight: '700' },

  // Vitals
  vitalsTable: { gap: 0 },
  vitalsHeaderRow: { flexDirection: 'row', paddingVertical: 8, borderBottomWidth: 1, borderBottomColor: Colors.border },
  vitalsHeaderCell: { flex: 1, fontSize: FontSize.xs, fontWeight: '800', color: Colors.textSecondary, textTransform: 'uppercase' },
  vitalsRow: { flexDirection: 'row', paddingVertical: 10, borderBottomWidth: 1, borderBottomColor: Colors.borderLight },
  vitalsCell: { flex: 1, fontSize: FontSize.sm, color: Colors.textPrimary, fontWeight: '600' },

  // Records
  recordItem: { flexDirection: 'row', gap: 12, paddingVertical: 8, borderBottomWidth: 1, borderBottomColor: Colors.borderLight },
  recordIconBox: { width: 44, height: 44, borderRadius: 12, justifyContent: 'center', alignItems: 'center' },
  recordTitle: { fontSize: FontSize.base, fontWeight: '700', color: Colors.textPrimary },
  recordMeta: { fontSize: FontSize.xs, color: Colors.textSecondary, marginTop: 2, fontWeight: '600' },
  recordDiagnosis: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 4 },

  // Family
  familyItem: { flexDirection: 'row', alignItems: 'center', paddingVertical: 8, borderBottomWidth: 1, borderBottomColor: Colors.borderLight },
  familyTitle: { fontSize: FontSize.base, fontWeight: '700', color: Colors.textPrimary },
  familyRelation: { fontSize: FontSize.xs, color: Colors.textSecondary, textTransform: 'uppercase', fontWeight: '800', marginTop: 2 },
  familyPhone: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 4 },
  emergencyPill: { backgroundColor: Colors.redBg, paddingHorizontal: 6, paddingVertical: 2, borderRadius: 4 },
  emergencyPillText: { color: Colors.red, fontSize: 10, fontWeight: '800', textTransform: 'uppercase' },
  callBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.emerald, justifyContent: 'center', alignItems: 'center' },

  emptyText: { color: Colors.slate400, fontStyle: 'italic', paddingVertical: 8 },

  // Quick Actions
  quickActionsContainer: { position: 'absolute', bottom: 0, left: 0, right: 0, backgroundColor: Colors.surface, borderTopWidth: 1, borderTopColor: Colors.border, paddingVertical: 12 },
  quickActionsScroll: { paddingHorizontal: 16, gap: 16 },
  qaBtn: { alignItems: 'center', gap: 6 },
  qaIcon: { width: 48, height: 48, borderRadius: 24, justifyContent: 'center', alignItems: 'center', shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.1, shadowRadius: 4, elevation: 4 },
  qaText: { fontSize: 11, fontWeight: '700', color: Colors.textSecondary },
});
