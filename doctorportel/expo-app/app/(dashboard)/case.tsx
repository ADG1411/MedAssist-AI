import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';

const CASES = [
  { id: 'case-1', patient: 'Rahul Sharma', stage: 'Diagnosis', progress: 40, diagnosis: 'Suspected Typhoid', priority: 'high', lastUpdate: '2 hours ago' },
  { id: 'case-2', patient: 'Emma Watson', stage: 'Treatment', progress: 70, diagnosis: 'Iron Deficiency Anaemia', priority: 'medium', lastUpdate: '1 day ago' },
  { id: 'case-3', patient: 'Arjun Mehta', stage: 'Follow-up', progress: 90, diagnosis: 'Coronary Artery Disease', priority: 'critical', lastUpdate: '30 min ago' },
];

const STAGES = ['Intake', 'Diagnosis', 'Treatment', 'Follow-up', 'Closed'];

export default function CaseScreen() {
  const router = useRouter();

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

        {CASES.map(c => {
          const ps = priorityStyle(c.priority);
          return (
            <TouchableOpacity key={c.id} style={styles.caseCard}>
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
