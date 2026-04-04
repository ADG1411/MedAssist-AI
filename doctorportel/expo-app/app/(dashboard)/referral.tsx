import { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput, Alert, ActivityIndicator, Platform } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import { createReferral } from '../../services/referralService';
import { getPatientById } from '../../services/patientService';

export default function CreateReferralScreen() {
  const router = useRouter();
  
  // Form State
  const [patientId, setPatientId] = useState('1'); 
  const [diagnosis, setDiagnosis] = useState('');
  const [notes, setNotes] = useState('');
  const [tests, setTests] = useState('');
  const [medicines, setMedicines] = useState('');
  const [reason, setReason] = useState('');
  const [type, setType] = useState<'Lab' | 'Hospital' | 'Specialist' | 'Emergency'>('Lab');
  
  const [loading, setLoading] = useState(false);
  const [patientName, setPatientName] = useState('');

  // Pre-load demo patient mapping just for UX
  useEffect(() => {
    if (patientId) {
      getPatientById(patientId).then(p => { if (p) setPatientName(p.name); });
    }
  }, [patientId]);

  const handleSubmit = async () => {
    if (!diagnosis.trim() || !tests.trim()) {
      if (Platform.OS === 'web') {
        window.alert('Diagnosis and Tests Required are mandatory for a referral.');
      } else {
        Alert.alert('Missing Fields', 'Diagnosis and Tests Required are mandatory for a referral.');
      }
      return;
    }
    
    setLoading(true);
    try {
      const referral = await createReferral({
        patient_id: patientId,
        doctor_id: 'doc_me',
        diagnosis, notes, medicines, tests, reason, type
      });
      
      // On Web, complex Alerts fail, so route directly to Patient View
      if (Platform.OS === 'web') {
        window.alert('Referral created. Opening patient booking view...');
        router.push(`/(dashboard)/patient-referral?id=${referral.id}`);
      } else {
        Alert.alert('Referral Created', 'The patient can now view and book a service from their portal.', [
          { text: 'View as Patient', onPress: () => router.push(`/(dashboard)/patient-referral?id=${referral.id}`) },
          { text: 'Done', style: 'cancel', onPress: () => resetForm() }
        ]);
      }
    } catch (e) {
      if (Platform.OS === 'web') window.alert('Could not create referral.');
      else Alert.alert('Error', 'Could not create referral.');
    } finally {
      setLoading(false);
    }
  };

  const resetForm = () => {
    setDiagnosis(''); setNotes(''); setTests(''); setMedicines(''); setReason('');
  };

  const renderTypeSelector = (label: typeof type, icon: any) => {
    const isSelected = type === label;
    return (
      <TouchableOpacity 
        style={[styles.typeBtn, isSelected && styles.typeBtnSelected]} 
        onPress={() => setType(label)}
      >
        <Ionicons name={icon} size={18} color={isSelected ? '#FFF' : Colors.slate500} />
        <Text style={[styles.typeText, isSelected && styles.typeTextSelected]}>{label}</Text>
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.iconBtn} onPress={() => router.back()}>
          <Ionicons name="arrow-back" size={20} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.pageTitle}>Create Referral</Text>
        <View style={{ width: 40 }} />
      </View>

      <ScrollView contentContainerStyle={{ padding: 20, paddingBottom: 100 }}>
        
        {/* Patient Target Block */}
        <View style={styles.targetCard}>
          <View style={styles.targetHeader}>
            <Ionicons name="person" size={16} color={Colors.brandBlue} />
            <Text style={styles.targetLabel}>REFERRAL FOR</Text>
          </View>
          <TextInput 
            style={styles.targetInput} 
            placeholder="Patient ID (e.g., 1, 2, 3)" 
            value={patientId} 
            onChangeText={setPatientId}
          />
          {patientName ? <Text style={styles.targetSubtext}>Found Patient: <Text style={{fontWeight: '700'}}>{patientName}</Text></Text> : null}
        </View>

        {/* Type Selection */}
        <Text style={styles.sectionLabel}>Referral Type</Text>
        <View style={styles.typeRow}>
          {renderTypeSelector('Lab', 'flask')}
          {renderTypeSelector('Hospital', 'business')}
        </View>
        <View style={[styles.typeRow, { marginTop: 10 }]}>
          {renderTypeSelector('Specialist', 'people')}
          {renderTypeSelector('Emergency', 'warning')}
        </View>

        <View style={styles.divider} />

        {/* Form Fields */}
        <Text style={styles.sectionLabel}>Clinical Details</Text>
        
        <Text style={styles.inputLabel}>Diagnosis / Condition <Text style={styles.req}>*</Text></Text>
        <TextInput 
          style={styles.input} 
          placeholder="e.g. Uncontrolled Hypertension" 
          value={diagnosis} onChangeText={setDiagnosis} 
        />

        <Text style={styles.inputLabel}>Tests / Services Required <Text style={styles.req}>*</Text></Text>
        <TextInput 
          style={styles.inputArea} 
          placeholder="e.g. CBC, Echocardiogram, Full Lipid Panel" 
          multiline value={tests} onChangeText={setTests} 
        />

        <Text style={styles.inputLabel}>Active Medicines</Text>
        <TextInput 
          style={styles.inputArea} 
          placeholder="List any relevant active medicines..." 
          multiline value={medicines} onChangeText={setMedicines} 
        />

        <Text style={styles.inputLabel}>Doctor Notes</Text>
        <TextInput 
          style={styles.inputAreaLarge} 
          placeholder="Add clinical context for the providing specialist or lab technician..." 
          multiline value={notes} onChangeText={setNotes} 
        />

        <Text style={styles.inputLabel}>Reason for Referral</Text>
        <TextInput 
          style={styles.input} 
          placeholder="e.g. Needs immediate scanning" 
          value={reason} onChangeText={setReason} 
        />

        <TouchableOpacity style={styles.submitBtn} onPress={handleSubmit} disabled={loading}>
          {loading ? <ActivityIndicator color="#FFF" /> : (
            <>
              <Ionicons name="document-text" size={18} color="#FFF" />
              <Text style={styles.submitBtnText}>Generate Referral</Text>
            </>
          )}
        </TouchableOpacity>

      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.slate50 },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: 20, paddingTop: 60, paddingBottom: 16, backgroundColor: Colors.surface, borderBottomWidth: 1, borderBottomColor: Colors.borderLight },
  pageTitle: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary },
  iconBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.slate100, justifyContent: 'center', alignItems: 'center' },
  
  targetCard: { backgroundColor: Colors.blueBg, padding: 16, borderRadius: BorderRadius.lg, marginBottom: 24, borderWidth: 1, borderColor: Colors.blueLight },
  targetHeader: { flexDirection: 'row', alignItems: 'center', gap: 6, marginBottom: 8 },
  targetLabel: { fontSize: FontSize.xs, fontWeight: '800', color: Colors.brandBlue, letterSpacing: 1 },
  targetInput: { backgroundColor: '#FFF', padding: 12, borderRadius: BorderRadius.md, fontSize: FontSize.md, fontWeight: '600' },
  targetSubtext: { fontSize: FontSize.xs, color: Colors.slate500, marginTop: 8 },
  
  sectionLabel: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary, marginBottom: 12 },
  
  typeRow: { flexDirection: 'row', gap: 10 },
  typeBtn: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, backgroundColor: Colors.surface, paddingVertical: 14, borderRadius: BorderRadius.lg, borderWidth: 1, borderColor: Colors.border },
  typeBtnSelected: { backgroundColor: Colors.brandBlue, borderColor: Colors.brandBlue },
  typeText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.slate600 },
  typeTextSelected: { color: '#FFF' },

  divider: { height: 1, backgroundColor: Colors.borderLight, marginVertical: 24 },
  
  inputLabel: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.textSecondary, marginBottom: 6, marginTop: 16 },
  req: { color: Colors.red },
  input: { backgroundColor: Colors.surface, borderWidth: 1, borderColor: Colors.borderLight, borderRadius: BorderRadius.md, paddingHorizontal: 16, paddingVertical: 14, fontSize: FontSize.md, color: Colors.textPrimary, shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.02, shadowRadius: 2, elevation: 1 },
  inputArea: { backgroundColor: Colors.surface, borderWidth: 1, borderColor: Colors.borderLight, borderRadius: BorderRadius.md, paddingHorizontal: 16, paddingVertical: 14, fontSize: FontSize.md, color: Colors.textPrimary, minHeight: 80, textAlignVertical: 'top' },
  inputAreaLarge: { backgroundColor: Colors.surface, borderWidth: 1, borderColor: Colors.borderLight, borderRadius: BorderRadius.md, paddingHorizontal: 16, paddingVertical: 14, fontSize: FontSize.md, color: Colors.textPrimary, minHeight: 120, textAlignVertical: 'top' },
  
  submitBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, backgroundColor: Colors.brandBlue, paddingVertical: 16, borderRadius: BorderRadius.lg, marginTop: 32, shadowColor: Colors.brandBlue, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.2, shadowRadius: 8, elevation: 6 },
  submitBtnText: { color: '#FFF', fontSize: FontSize.md, fontWeight: '700' },
});
