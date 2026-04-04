import { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import { supabase } from '../../services/supabase';

const STEPS = ['Overview', 'Workplaces', 'Availability', 'Fees', 'Documents', 'Settings'];

export default function ProfileSetupScreen() {
  const router = useRouter();
  const [step, setStep] = useState(0);
  const [form, setForm] = useState({
    full_name: '', specialization: '', degree: '', years_of_experience: '', bio: '', city: '', address: '',
    online_fee: '', offline_fee: '', emergency_fee: '',
  });

  const updateForm = (key: string, value: string) => setForm(prev => ({ ...prev, [key]: value }));

  const handleSave = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { Alert.alert('Error', 'Not logged in'); return; }

      const payload = {
        id: user.id,
        overview: { full_name: form.full_name, specialization: form.specialization, degree: form.degree, years_of_experience: parseInt(form.years_of_experience) || 0, bio: form.bio, city: form.city, address: form.address, profile_photo: null, languages: [] },
        fees: { online_fee: parseInt(form.online_fee) || 0, offline_fee: parseInt(form.offline_fee) || 0, emergency_fee: parseInt(form.emergency_fee) || 0, free_consultation: false, discount_percent: 0 },
        completion_percent: Math.min(100, Math.floor(Object.values(form).filter(v => v).length / Object.keys(form).length * 100)),
      };

      const { error } = await supabase.from('doctor_profiles').upsert(payload, { onConflict: 'id' });
      if (error) throw error;
      Alert.alert('✅ Saved', 'Profile updated successfully', [{ text: 'OK', onPress: () => router.back() }]);
    } catch (e: any) {
      Alert.alert('Error', e.message);
    }
  };

  const renderStep = () => {
    switch (step) {
      case 0: return (
        <View style={styles.stepContent}>
          <Text style={styles.stepTitle}>👤 Personal Overview</Text>
          <Input label="Full Name" value={form.full_name} onChange={v => updateForm('full_name', v)} placeholder="Dr. John Smith" />
          <Input label="Specialization" value={form.specialization} onChange={v => updateForm('specialization', v)} placeholder="Cardiologist" />
          <Input label="Degree" value={form.degree} onChange={v => updateForm('degree', v)} placeholder="MBBS, MD" />
          <Input label="Years of Experience" value={form.years_of_experience} onChange={v => updateForm('years_of_experience', v)} placeholder="10" keyboardType="numeric" />
          <Input label="City" value={form.city} onChange={v => updateForm('city', v)} placeholder="Mumbai" />
          <Input label="Address" value={form.address} onChange={v => updateForm('address', v)} placeholder="123 Medical Center" />
          <Input label="Bio" value={form.bio} onChange={v => updateForm('bio', v)} placeholder="Write a short professional bio..." multiline />
        </View>
      );
      case 1: return (
        <View style={styles.stepContent}>
          <Text style={styles.stepTitle}>🏥 Workplaces</Text>
          <View style={styles.emptyState}>
            <Ionicons name="business" size={40} color={Colors.slate300} />
            <Text style={styles.emptyText}>Add your clinic or hospital workplaces</Text>
            <TouchableOpacity style={styles.addItemBtn}><Text style={styles.addItemText}>+ Add Workplace</Text></TouchableOpacity>
          </View>
        </View>
      );
      case 2: return (
        <View style={styles.stepContent}>
          <Text style={styles.stepTitle}>📅 Availability</Text>
          <Text style={styles.stepDesc}>Configure your working hours for each day. This can also be managed from the Schedule page.</Text>
          <TouchableOpacity style={styles.linkBtn} onPress={() => router.push('/(dashboard)/schedule')}>
            <Ionicons name="calendar" size={18} color={Colors.brandBlue} />
            <Text style={styles.linkBtnText}>Go to Schedule Manager</Text>
          </TouchableOpacity>
        </View>
      );
      case 3: return (
        <View style={styles.stepContent}>
          <Text style={styles.stepTitle}>💰 Consultation Fees</Text>
          <Input label="Online Fee (₹)" value={form.online_fee} onChange={v => updateForm('online_fee', v)} placeholder="500" keyboardType="numeric" />
          <Input label="Offline Fee (₹)" value={form.offline_fee} onChange={v => updateForm('offline_fee', v)} placeholder="800" keyboardType="numeric" />
          <Input label="Emergency Fee (₹)" value={form.emergency_fee} onChange={v => updateForm('emergency_fee', v)} placeholder="2000" keyboardType="numeric" />
        </View>
      );
      case 4: return (
        <View style={styles.stepContent}>
          <Text style={styles.stepTitle}>📄 Documents</Text>
          <View style={styles.emptyState}>
            <Ionicons name="document-attach" size={40} color={Colors.slate300} />
            <Text style={styles.emptyText}>Upload your medical license and certificates</Text>
            <TouchableOpacity style={styles.addItemBtn}><Text style={styles.addItemText}>+ Upload Document</Text></TouchableOpacity>
          </View>
        </View>
      );
      case 5: return (
        <View style={styles.stepContent}>
          <Text style={styles.stepTitle}>⚙️ Settings</Text>
          <Text style={styles.stepDesc}>Notification preferences, profile visibility, and language settings can be managed here.</Text>
        </View>
      );
      default: return null;
    }
  };

  const progress = Math.floor(Object.values(form).filter(v => v).length / Object.keys(form).length * 100);

  return (
    <ScrollView style={styles.container} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={22} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.pageTitle}>Profile Setup</Text>
      </View>

      <View style={{ padding: 16 }}>
        {/* Progress */}
        <View style={styles.progressCard}>
          <Text style={styles.progressLabel}>Profile Completion: {progress}%</Text>
          <View style={styles.progressTrack}>
            <View style={[styles.progressFill, { width: `${progress}%` }]} />
          </View>
        </View>

        {/* Step Indicator */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.stepsScroll} contentContainerStyle={{ gap: 6 }}>
          {STEPS.map((s, i) => (
            <TouchableOpacity key={s} style={[styles.stepChip, step === i && styles.stepChipActive, i < step && styles.stepChipDone]}
              onPress={() => setStep(i)}>
              <Text style={[styles.stepChipText, step === i && styles.stepChipTextActive, i < step && { color: Colors.emerald }]}>
                {i < step ? '✓ ' : ''}{s}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        {renderStep()}

        {/* Navigation */}
        <View style={styles.navRow}>
          {step > 0 && (
            <TouchableOpacity style={styles.prevBtn} onPress={() => setStep(s => s - 1)}>
              <Ionicons name="arrow-back" size={18} color={Colors.slate600} />
              <Text style={styles.prevBtnText}>Previous</Text>
            </TouchableOpacity>
          )}
          <View style={{ flex: 1 }} />
          {step < STEPS.length - 1 ? (
            <TouchableOpacity style={styles.nextBtn} onPress={() => setStep(s => s + 1)}>
              <Text style={styles.nextBtnText}>Next</Text>
              <Ionicons name="arrow-forward" size={18} color="#FFF" />
            </TouchableOpacity>
          ) : (
            <TouchableOpacity style={[styles.nextBtn, { backgroundColor: Colors.emerald }]} onPress={handleSave}>
              <Ionicons name="checkmark" size={18} color="#FFF" />
              <Text style={styles.nextBtnText}>Save Profile</Text>
            </TouchableOpacity>
          )}
        </View>
      </View>
    </ScrollView>
  );
}

function Input({ label, value, onChange, placeholder, multiline, keyboardType }: any) {
  return (
    <View style={{ gap: 6 }}>
      <Text style={{ fontSize: FontSize.md, fontWeight: '600', color: Colors.textPrimary }}>{label}</Text>
      <TextInput style={[iStyles.input, multiline && { minHeight: 80, textAlignVertical: 'top' }]}
        placeholder={placeholder} placeholderTextColor={Colors.slate400} value={value} onChangeText={onChange}
        multiline={multiline} keyboardType={keyboardType} />
    </View>
  );
}
const iStyles = StyleSheet.create({ input: { backgroundColor: Colors.slate50, borderRadius: BorderRadius.md, padding: 14, fontSize: FontSize.md, color: Colors.textPrimary, borderWidth: 1, borderColor: Colors.border } });

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.background },
  header: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingTop: 56, paddingBottom: 12 },
  backBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.surface, justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: Colors.border },
  pageTitle: { fontSize: FontSize.h1, fontWeight: '900', color: Colors.textPrimary },
  progressCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.lg, padding: 16, borderWidth: 1, borderColor: Colors.borderLight, marginBottom: 12 },
  progressLabel: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.textSecondary, marginBottom: 8 },
  progressTrack: { height: 8, backgroundColor: Colors.slate100, borderRadius: 4, overflow: 'hidden' },
  progressFill: { height: '100%', backgroundColor: Colors.brandBlue, borderRadius: 4 },
  stepsScroll: { marginBottom: 16 },
  stepChip: { paddingHorizontal: 14, paddingVertical: 8, borderRadius: BorderRadius.full, backgroundColor: Colors.surface, borderWidth: 1, borderColor: Colors.border },
  stepChipActive: { backgroundColor: Colors.brandBlue, borderColor: Colors.brandBlue },
  stepChipDone: { borderColor: Colors.emeraldLight, backgroundColor: Colors.emeraldBg },
  stepChipText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.slate600 },
  stepChipTextActive: { color: '#FFF' },
  stepContent: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 20, gap: 14, borderWidth: 1, borderColor: Colors.borderLight },
  stepTitle: { fontSize: FontSize.xl, fontWeight: '800', color: Colors.textPrimary },
  stepDesc: { fontSize: FontSize.md, color: Colors.textSecondary, lineHeight: 20 },
  emptyState: { alignItems: 'center', paddingVertical: 24, gap: 10 },
  emptyText: { fontSize: FontSize.md, color: Colors.textSecondary, textAlign: 'center' },
  addItemBtn: { backgroundColor: Colors.blueBg, paddingHorizontal: 20, paddingVertical: 10, borderRadius: BorderRadius.full },
  addItemText: { color: Colors.brandBlue, fontWeight: '700' },
  linkBtn: { flexDirection: 'row', alignItems: 'center', gap: 8, backgroundColor: Colors.blueBg, padding: 16, borderRadius: BorderRadius.md },
  linkBtnText: { color: Colors.brandBlue, fontWeight: '700', fontSize: FontSize.md },
  navRow: { flexDirection: 'row', alignItems: 'center', marginTop: 20 },
  prevBtn: { flexDirection: 'row', alignItems: 'center', gap: 6, paddingVertical: 12, paddingHorizontal: 16 },
  prevBtnText: { fontSize: FontSize.md, fontWeight: '700', color: Colors.slate600 },
  nextBtn: { flexDirection: 'row', alignItems: 'center', gap: 6, backgroundColor: Colors.brandBlue, paddingVertical: 12, paddingHorizontal: 20, borderRadius: BorderRadius.md },
  nextBtnText: { fontSize: FontSize.md, fontWeight: '700', color: '#FFF' },
});
