import { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';

interface Medicine { name: string; dosage: string; frequency: string; duration: string; }

export default function PrescriptionScreen() {
  const router = useRouter();
  const [patientName, setPatientName] = useState('');
  const [diagnosis, setDiagnosis] = useState('');
  const [medicines, setMedicines] = useState<Medicine[]>([{ name: '', dosage: '', frequency: 'OD', duration: '5 days' }]);
  const [notes, setNotes] = useState('');

  const addMedicine = () => setMedicines(prev => [...prev, { name: '', dosage: '', frequency: 'OD', duration: '5 days' }]);
  const removeMedicine = (i: number) => setMedicines(prev => prev.filter((_, idx) => idx !== i));
  const updateMedicine = (i: number, field: keyof Medicine, value: string) => {
    setMedicines(prev => prev.map((m, idx) => idx === i ? { ...m, [field]: value } : m));
  };

  const estimateCost = () => {
    const cost = medicines.filter(m => m.name).length * 150;
    return `₹${cost}`;
  };

  const handleGenerate = () => {
    if (!patientName || !diagnosis) { Alert.alert('Error', 'Enter patient name and diagnosis'); return; }
    if (!medicines.some(m => m.name)) { Alert.alert('Error', 'Add at least one medicine'); return; }
    Alert.alert('✅ Prescription Generated', `Rx for ${patientName}\nDiagnosis: ${diagnosis}\n${medicines.filter(m => m.name).length} medicine(s)\nEstimated cost: ${estimateCost()}`);
  };

  const FREQ_OPTIONS = ['OD', 'BD', 'TID', 'QID', 'SOS', 'HS'];

  return (
    <ScrollView style={styles.container} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={22} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.pageTitle}>Prescription Writer</Text>
      </View>

      <View style={{ padding: 16, gap: 16 }}>
        {/* Patient Info */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Patient Information</Text>
          <TextInput style={styles.input} placeholder="Patient Name" placeholderTextColor={Colors.slate400}
            value={patientName} onChangeText={setPatientName} />
          <TextInput style={styles.input} placeholder="Diagnosis" placeholderTextColor={Colors.slate400}
            value={diagnosis} onChangeText={setDiagnosis} />
        </View>

        {/* Medicines */}
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardTitle}>Medicines</Text>
            <TouchableOpacity onPress={addMedicine} style={styles.addChip}>
              <Ionicons name="add" size={16} color={Colors.brandBlue} />
              <Text style={styles.addChipText}>Add</Text>
            </TouchableOpacity>
          </View>
          {medicines.map((med, i) => (
            <View key={i} style={styles.medCard}>
              <View style={styles.medHeader}>
                <Text style={styles.medNum}>#{i + 1}</Text>
                {medicines.length > 1 && (
                  <TouchableOpacity onPress={() => removeMedicine(i)}><Ionicons name="trash-outline" size={18} color={Colors.red} /></TouchableOpacity>
                )}
              </View>
              <TextInput style={styles.input} placeholder="Medicine name" placeholderTextColor={Colors.slate400}
                value={med.name} onChangeText={v => updateMedicine(i, 'name', v)} />
              <TextInput style={styles.input} placeholder="Dosage (e.g. 500mg)" placeholderTextColor={Colors.slate400}
                value={med.dosage} onChangeText={v => updateMedicine(i, 'dosage', v)} />
              <View style={styles.freqRow}>
                {FREQ_OPTIONS.map(f => (
                  <TouchableOpacity key={f} style={[styles.freqChip, med.frequency === f && styles.freqChipActive]}
                    onPress={() => updateMedicine(i, 'frequency', f)}>
                    <Text style={[styles.freqText, med.frequency === f && styles.freqTextActive]}>{f}</Text>
                  </TouchableOpacity>
                ))}
              </View>
              <TextInput style={styles.input} placeholder="Duration (e.g. 5 days)" placeholderTextColor={Colors.slate400}
                value={med.duration} onChangeText={v => updateMedicine(i, 'duration', v)} />
            </View>
          ))}
        </View>

        {/* Notes */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Clinical Notes</Text>
          <TextInput style={[styles.input, { minHeight: 80, textAlignVertical: 'top' }]} placeholder="Additional instructions..."
            placeholderTextColor={Colors.slate400} value={notes} onChangeText={setNotes} multiline />
        </View>

        {/* Cost Estimate */}
        <View style={styles.costCard}>
          <Ionicons name="calculator" size={20} color={Colors.emerald} />
          <Text style={styles.costText}>Estimated Cost: <Text style={styles.costValue}>{estimateCost()}</Text></Text>
        </View>

        {/* Generate Button */}
        <TouchableOpacity style={styles.generateBtn} onPress={handleGenerate}>
          <Ionicons name="document-text" size={20} color="#FFF" />
          <Text style={styles.generateBtnText}>Generate Prescription</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.background },
  header: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingTop: 56, paddingBottom: 12 },
  backBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.surface, justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: Colors.border },
  pageTitle: { fontSize: FontSize.h1, fontWeight: '900', color: Colors.textPrimary },
  card: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 16, borderWidth: 1, borderColor: Colors.borderLight, gap: 10 },
  cardHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  cardTitle: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary },
  addChip: { flexDirection: 'row', alignItems: 'center', gap: 4, backgroundColor: Colors.blueBg, paddingHorizontal: 12, paddingVertical: 6, borderRadius: BorderRadius.full },
  addChipText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.brandBlue },
  input: { backgroundColor: Colors.slate50, borderRadius: BorderRadius.md, padding: 14, fontSize: FontSize.md, color: Colors.textPrimary, borderWidth: 1, borderColor: Colors.border },
  medCard: { backgroundColor: Colors.slate50, borderRadius: BorderRadius.lg, padding: 12, gap: 8, borderWidth: 1, borderColor: Colors.border },
  medHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  medNum: { fontSize: FontSize.sm, fontWeight: '800', color: Colors.brandBlue },
  freqRow: { flexDirection: 'row', gap: 6, flexWrap: 'wrap' },
  freqChip: { paddingHorizontal: 12, paddingVertical: 6, borderRadius: BorderRadius.full, backgroundColor: Colors.surface, borderWidth: 1, borderColor: Colors.border },
  freqChipActive: { backgroundColor: Colors.brandBlue, borderColor: Colors.brandBlue },
  freqText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.slate600 },
  freqTextActive: { color: '#FFF' },
  costCard: { flexDirection: 'row', alignItems: 'center', gap: 10, backgroundColor: Colors.emeraldBg, borderRadius: BorderRadius.lg, padding: 16, borderWidth: 1, borderColor: Colors.emeraldLight },
  costText: { fontSize: FontSize.md, fontWeight: '600', color: Colors.textPrimary },
  costValue: { fontWeight: '900', color: Colors.emerald },
  generateBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, backgroundColor: Colors.brandBlue, paddingVertical: 16, borderRadius: BorderRadius.lg, shadowColor: Colors.brandBlue, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.3, shadowRadius: 12, elevation: 8 },
  generateBtnText: { color: '#FFF', fontSize: FontSize.lg, fontWeight: '700' },
});
