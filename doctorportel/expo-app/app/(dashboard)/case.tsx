import { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import { supabase } from '../../services/supabase';

const MOCK_CASES = [
  { id: 'case-1', patient: 'Rahul Sharma', patientId: '1', stage: 'Diagnosis', progress: 40, diagnosis: 'Suspected Typhoid', priority: 'high', lastUpdate: '2 hours ago' },
  { id: 'case-2', patient: 'Emma Watson', patientId: '2', stage: 'Treatment', progress: 70, diagnosis: 'Iron Deficiency Anaemia', priority: 'medium', lastUpdate: '1 day ago' },
  { id: 'case-3', patient: 'Arjun Mehta', patientId: '3', stage: 'Follow-up', progress: 90, diagnosis: 'Coronary Artery Disease', priority: 'critical', lastUpdate: '30 min ago' },
];

const STAGES = ['Intake', 'Diagnosis', 'Treatment', 'Follow-up', 'Closed'];

export default function CaseScreen() {
  const router = useRouter();
  
  const [cases, setCases] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchCases();
  }, []);

  const fetchCases = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Not logged in');

      // Get all active patients the doctor has access to
      const { data: accessData } = await supabase
        .from('doctor_patient_access')
        .select('patient_id, granted_at')
        .eq('doctor_id', user.id)
        .eq('is_active', true);

      if (!accessData || accessData.length === 0) {
        setCases(MOCK_CASES);
        setLoading(false);
        return;
      }

      const builtCases = [];
      
      for (const grant of accessData) {
        // Fetch patient profile
        const { data: profile } = await supabase.from('profiles').select('name').eq('id', grant.patient_id).maybeSingle();
        // Fetch their latest AI result / symptoms
        const { data: aiResult } = await supabase.from('ai_results').select('conditions, risk_level, created_at').eq('user_id', grant.patient_id).order('created_at', { ascending: false }).limit(1).maybeSingle();
        
        let priority = 'info';
        if (aiResult?.risk_level) {
          const rl = String(aiResult.risk_level).toLowerCase();
          if (rl.includes('high') || rl.includes('critical')) priority = 'critical';
          else if (rl.includes('medium') || rl.includes('elevated')) priority = 'high';
          else priority = 'medium';
        }

        let diagnosis = 'Awaiting Assessment';
        if (aiResult?.conditions && Array.isArray(aiResult.conditions) && aiResult.conditions.length > 0) {
          diagnosis = aiResult.conditions[0].name || diagnosis;
        }

        // Relative time helper
        let lastUpdate = 'Recently';
        if (aiResult?.created_at) {
          const hours = Math.round((Date.now() - new Date(aiResult.created_at).getTime()) / (1000 * 60 * 60));
          lastUpdate = hours > 24 ? `${Math.round(hours / 24)} days ago` : `${hours} hours ago`;
        }

        builtCases.push({
          id: `case-${grant.patient_id}`,
          patientId: grant.patient_id,
          patient: profile?.name || `Patient ${grant.patient_id.substring(0, 5)}`,
          stage: aiResult ? 'Treatment' : 'Intake',
          progress: aiResult ? 60 : 20,
          diagnosis,
          priority,
          lastUpdate
        });
      }

      setCases(builtCases.length > 0 ? builtCases : MOCK_CASES);
    } catch (e) {
      console.warn('Failed to fetch cases from Supabase:', e);
      setCases(MOCK_CASES);
    } finally {
      setLoading(false);
    }
  };

  const priorityStyle = (p: string) => {
    if (p === 'critical') return { bg: Colors.redBg, text: Colors.red, icon: 'alert-circle' as const };
    if (p === 'high') return { bg: Colors.amberBg, text: Colors.amber, icon: 'warning' as const };
    return { bg: Colors.blueBg, text: Colors.brandBlue, icon: 'information-circle' as const };
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={22} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.pageTitle}>Case Workflow</Text>
      </View>

      <View style={{ padding: 16, gap: 12 }}>
        {/* Stage Overview */}
        <View style={styles.stageOverview}>
          {STAGES.map((s, i) => (
            <View key={s} style={styles.stageItem}>
              <View style={[styles.stageDot, { backgroundColor: i <= 2 ? Colors.brandBlue : Colors.slate300 }]}>
                {i <= 2 && <Ionicons name="checkmark" size={10} color="#FFF" />}
              </View>
              <Text style={[styles.stageLabel, { color: i <= 2 ? Colors.brandBlue : Colors.textTertiary }]}>{s}</Text>
              {i < STAGES.length - 1 && <View style={[styles.stageLine, { backgroundColor: i < 2 ? Colors.brandBlue : Colors.slate200 }]} />}
            </View>
          ))}
        </View>

        {/* Quick Actions */}
        <View style={{ flexDirection: 'row', gap: 12, marginBottom: 8 }}>
          <TouchableOpacity 
            style={[styles.caseCard, { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, padding: 12, backgroundColor: Colors.brandBlue }]}
            onPress={() => router.push('/(dashboard)/bookings')}
          >
            <Ionicons name="calendar" size={18} color="#FFF" />
            <Text style={{ color: '#FFF', fontWeight: '800', fontSize: FontSize.sm }}>View Bookings</Text>
          </TouchableOpacity>
        </View>

        {loading ? (
          <ActivityIndicator size="large" color={Colors.brandBlue} style={{ marginTop: 40 }} />
        ) : (
          cases.map(c => {
            const ps = priorityStyle(c.priority);
            return (
              <TouchableOpacity 
                key={c.id} 
                style={styles.caseCard}
                onPress={() => router.push(`/(dashboard)/patient-record?id=${c.patientId}&name=${encodeURIComponent(c.patient)}`)}
              >
                <View style={styles.caseHeader}>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.caseName}>{c.patient}</Text>
                    <Text style={styles.caseDiag}>{c.diagnosis}</Text>
                  </View>
                  <View style={[styles.priorityBadge, { backgroundColor: ps.bg }]}>
                    <Ionicons name={ps.icon} size={12} color={ps.text} />
                    <Text style={[styles.priorityText, { color: ps.text }]}>{c.priority}</Text>
                  </View>
                </View>
                <View style={styles.caseProgress}>
                  <View style={styles.caseProgressHeader}>
                    <Text style={styles.caseStage}>Stage: {c.stage}</Text>
                    <Text style={styles.casePercent}>{c.progress}%</Text>
                  </View>
                  <View style={styles.progressTrack}>
                    <View style={[styles.progressFill, { width: `${c.progress}%`, backgroundColor: ps.text }]} />
                  </View>
                </View>
                <Text style={styles.caseUpdate}>Updated {c.lastUpdate}</Text>
              </TouchableOpacity>
            );
          })
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
  stageOverview: { flexDirection: 'row', backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 20, borderWidth: 1, borderColor: Colors.borderLight, justifyContent: 'space-between' },
  stageItem: { alignItems: 'center', flex: 1 },
  stageDot: { width: 20, height: 20, borderRadius: 10, justifyContent: 'center', alignItems: 'center', marginBottom: 4 },
  stageLabel: { fontSize: 9, fontWeight: '700', textTransform: 'uppercase' },
  stageLine: { position: 'absolute', top: 10, left: '60%', right: '-40%', height: 2 },
  caseCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xl, padding: 16, borderWidth: 1, borderColor: Colors.borderLight },
  caseHeader: { flexDirection: 'row', alignItems: 'flex-start', marginBottom: 12 },
  caseName: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary },
  caseDiag: { fontSize: FontSize.md, color: Colors.textSecondary, marginTop: 2 },
  priorityBadge: { flexDirection: 'row', alignItems: 'center', gap: 4, paddingHorizontal: 8, paddingVertical: 4, borderRadius: 6 },
  priorityText: { fontSize: FontSize.xs, fontWeight: '700', textTransform: 'capitalize' },
  caseProgress: { marginBottom: 8 },
  caseProgressHeader: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 6 },
  caseStage: { fontSize: FontSize.sm, fontWeight: '600', color: Colors.textSecondary },
  casePercent: { fontSize: FontSize.sm, fontWeight: '800', color: Colors.brandBlue },
  progressTrack: { height: 6, backgroundColor: Colors.slate100, borderRadius: 3, overflow: 'hidden' },
  progressFill: { height: '100%', borderRadius: 3 },
  caseUpdate: { fontSize: FontSize.xs, fontWeight: '600', color: Colors.textTertiary },
});
