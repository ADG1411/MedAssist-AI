import { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator, Image, Alert } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import { getReferral, getProviders, createBooking, confirmPayment, generateTicket, generateAIReferralSummary, Referral, Provider, ReferralAISummary } from '../../services/referralService';

export default function PatientReferralScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  
  const [loading, setLoading] = useState(true);
  const [referral, setReferral] = useState<Referral | null>(null);
  const [aiSummary, setAiSummary] = useState<ReferralAISummary | null>(null);
  const [aiLoading, setAiLoading] = useState(true);
  
  const [providers, setProviders] = useState<Provider[]>([]);
  const [step, setStep] = useState(1); // 1 = View, 2 = Select Provider, 3 = Confirm Payment
  
  const [selectedProvider, setSelectedProvider] = useState<Provider | null>(null);
  const [selectedDate, setSelectedDate] = useState('Tomorrow');
  const [selectedTime, setSelectedTime] = useState('09:00 AM');
  const [bookingLoading, setBookingLoading] = useState(false);

  useEffect(() => {
    if (id) loadInitialData(id);
  }, [id]);

  const loadInitialData = async (refId: string) => {
    setLoading(true);
    const ref = await getReferral(refId);
    if (!ref) {
      Alert.alert('Error', 'Referral not found');
      router.back();
      return;
    }
    setReferral(ref);
    setLoading(false);

    // parallel loads
    getProviders(ref.type).then(setProviders);
    generateAIReferralSummary(ref.diagnosis, ref.tests, ref.notes).then(setAiSummary).finally(() => setAiLoading(false));
  };

  const handleBookSlot = async () => {
    if (!selectedProvider) return;
    setBookingLoading(true);
    // Simulate booking & payment flow
    setTimeout(async () => {
      const booking = await createBooking(referral!.id, selectedProvider.id, selectedDate, selectedTime, selectedProvider.price);
      await confirmPayment(booking.id);
      const ticket = await generateTicket(booking.id);
      setBookingLoading(false);
      router.replace(`/(dashboard)/ticket?id=${ticket.id}&qr=${encodeURIComponent(ticket.qr_token)}`);
    }, 1500);
  };

  if (loading || !referral) {
    return <View style={[styles.container, { justifyContent: 'center' }]}><ActivityIndicator size="large" color={Colors.brandBlue} /></View>;
  }

  // -------------------------
  // RENDER STEP 1: REFERRAL VIEW
  // -------------------------
  if (step === 1) {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity style={styles.iconBtn} onPress={() => router.back()}>
            <Ionicons name="close" size={20} color={Colors.textPrimary} />
          </TouchableOpacity>
          <Text style={styles.pageTitle}>Your Referral</Text>
          <View style={{ width: 40 }} />
        </View>
        <ScrollView contentContainerStyle={{ padding: 20, paddingBottom: 100 }}>
          
          {/* AI Explanation Card */}
          <View style={styles.aiCard}>
            <View style={styles.aiHeader}>
              <Ionicons name="sparkles" size={16} color="#C4B5FD" />
              <Text style={styles.aiTitle}>AI Summary</Text>
            </View>
            {aiLoading ? (
               <ActivityIndicator size="small" color="#C4B5FD" style={{ marginVertical: 10 }} />
            ) : aiSummary ? (
              <>
                <Text style={styles.aiText}>{aiSummary.explanation}</Text>
                <View style={styles.stepsBox}>
                  <Text style={styles.stepsLabel}>Next Steps:</Text>
                  {aiSummary.next_steps.map((step, i) => (
                    <Text key={i} style={styles.stepItem}>• {step}</Text>
                  ))}
                </View>
              </>
            ) : null}
          </View>

          {/* Doctor Info */}
          <Text style={styles.sectionLabel}>Clinical Details</Text>
          <View style={styles.refBox}>
            <View style={styles.refRow}><Text style={styles.refKey}>Type</Text><Text style={styles.refVal}>{referral.type}</Text></View>
            <View style={styles.refRow}><Text style={styles.refKey}>Diagnosis</Text><Text style={styles.refVal}>{referral.diagnosis}</Text></View>
            <View style={styles.refRow}><Text style={styles.refKey}>Tests</Text><Text style={styles.refVal}>{referral.tests}</Text></View>
            {referral.reason && <View style={styles.refRow}><Text style={styles.refKey}>Reason</Text><Text style={styles.refVal}>{referral.reason}</Text></View>}
            {referral.notes && (
              <View style={[styles.refRow, { flexDirection: 'column', gap: 6, alignItems: 'flex-start' }]}>
                <Text style={styles.refKey}>Doctor Notes</Text>
                <View style={styles.notesBox}><Text style={styles.notesText}>{referral.notes}</Text></View>
              </View>
            )}
          </View>

          <TouchableOpacity style={styles.primaryBtn} onPress={() => setStep(2)}>
            <Text style={styles.primaryBtnText}>Find Providers</Text>
            <Ionicons name="arrow-forward" size={18} color="#FFF" />
          </TouchableOpacity>
        </ScrollView>
      </View>
    );
  }

  // -------------------------
  // RENDER STEP 2/3: PICK & PAY
  // -------------------------
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.iconBtn} onPress={() => step === 3 ? setStep(2) : setStep(1)}>
          <Ionicons name="arrow-back" size={20} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.pageTitle}>{step === 2 ? 'Select Provider' : 'Confirm Book & Pay'}</Text>
        <View style={{ width: 40 }} />
      </View>

      <ScrollView contentContainerStyle={{ padding: 20, paddingBottom: 100 }}>
        {step === 2 && (
          <View>
            <Text style={styles.sectionLabel}>Available {referral.type}s</Text>
            {providers.map(p => (
              <TouchableOpacity key={p.id} style={[styles.providerCard, selectedProvider?.id === p.id && styles.providerCardSelected]} onPress={() => setSelectedProvider(p)}>
                <Image source={{ uri: p.image }} style={styles.providerImg} />
                <View style={{ flex: 1 }}>
                  <Text style={styles.pName}>{p.name}</Text>
                  <Text style={styles.pDetails}>{p.distance} • ⭐ {p.rating}</Text>
                </View>
                <View style={styles.priceBox}><Text style={styles.priceText}>₹{p.price}</Text></View>
              </TouchableOpacity>
            ))}

            {selectedProvider && (
              <View style={styles.slotsCard}>
                <Text style={styles.sectionLabel}>Select Time</Text>
                <View style={styles.slotRow}>
                   {['Today', 'Tomorrow'].map(d => (
                     <TouchableOpacity key={d} style={[styles.dateChip, selectedDate === d && styles.dateChipSelected]} onPress={() => setSelectedDate(d)}>
                       <Text style={[styles.dateText, selectedDate === d && styles.dateTextSelected]}>{d}</Text>
                     </TouchableOpacity>
                   ))}
                </View>
                <View style={styles.slotGrid}>
                   {['08:00 AM', '09:00 AM', '11:30 AM', '02:00 PM', '04:30 PM'].map(t => (
                     <TouchableOpacity key={t} style={[styles.timeChip, selectedTime === t && styles.timeChipSelected]} onPress={() => setSelectedTime(t)}>
                        <Text style={[styles.timeText, selectedTime === t && styles.timeTextSelected]}>{t}</Text>
                     </TouchableOpacity>
                   ))}
                </View>
              </View>
            )}

            <TouchableOpacity style={[styles.primaryBtn, { marginTop: 24, opacity: selectedProvider ? 1 : 0.5 }]} disabled={!selectedProvider} onPress={() => setStep(3)}>
              <Text style={styles.primaryBtnText}>Review Booking</Text>
            </TouchableOpacity>
          </View>
        )}

        {step === 3 && selectedProvider && (
          <View>
            <View style={styles.receiptCard}>
               <Text style={styles.receiptTitle}>Booking Summary</Text>
               <View style={styles.divider} />
               <View style={styles.refRow}><Text style={styles.refKey}>Service</Text><Text style={styles.refVal}>{referral.tests}</Text></View>
               <View style={styles.refRow}><Text style={styles.refKey}>Provider</Text><Text style={styles.refVal}>{selectedProvider.name}</Text></View>
               <View style={styles.refRow}><Text style={styles.refKey}>Schedule</Text><Text style={[styles.refVal, { color: Colors.brandBlue }]}>{selectedDate} • {selectedTime}</Text></View>
               <View style={styles.divider} />
               <View style={styles.refRow}><Text style={styles.totalKey}>Total Payable</Text><Text style={styles.totalVal}>₹{selectedProvider.price}</Text></View>
               
               <TouchableOpacity style={[styles.paymentBtn, bookingLoading && { opacity: 0.8 }]} onPress={handleBookSlot} disabled={bookingLoading}>
                 {bookingLoading ? <ActivityIndicator color="#FFF" /> : <Text style={styles.paymentBtnText}>Pay Securely & Book</Text>}
               </TouchableOpacity>
            </View>
            <View style={styles.secureBox}>
              <Ionicons name="lock-closed" size={14} color={Colors.emerald} />
              <Text style={styles.secureText}>256-bit Secure Transaction</Text>
            </View>
          </View>
        )}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.slate50 },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: 20, paddingTop: 60, paddingBottom: 16, backgroundColor: Colors.surface, borderBottomWidth: 1, borderBottomColor: Colors.borderLight },
  pageTitle: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary },
  iconBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.slate100, justifyContent: 'center', alignItems: 'center' },
  
  // AI Card
  aiCard: { backgroundColor: '#1E1B4B', padding: 20, borderRadius: BorderRadius.xxl, marginBottom: 24 },
  aiHeader: { flexDirection: 'row', alignItems: 'center', gap: 6, marginBottom: 12 },
  aiTitle: { fontSize: FontSize.sm, fontWeight: '800', color: '#C4B5FD', letterSpacing: 1, textTransform: 'uppercase' },
  aiText: { fontSize: FontSize.md, color: '#E2E8F0', lineHeight: 22, marginBottom: 16 },
  stepsBox: { backgroundColor: 'rgba(255,255,255,0.05)', padding: 12, borderRadius: BorderRadius.lg },
  stepsLabel: { fontSize: FontSize.xs, color: '#A78BFA', fontWeight: '800', marginBottom: 6 },
  stepItem: { fontSize: FontSize.sm, color: '#E2E8F0', marginBottom: 4 },

  sectionLabel: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary, marginBottom: 12 },
  
  // Referral Details
  refBox: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xl, padding: 16, borderWidth: 1, borderColor: Colors.borderLight, gap: 12, marginBottom: 24 },
  refRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  refKey: { fontSize: FontSize.sm, color: Colors.textSecondary, fontWeight: '600' },
  refVal: { fontSize: FontSize.sm, color: Colors.textPrimary, fontWeight: '800', flexShrink: 1, textAlign: 'right' },
  notesBox: { backgroundColor: Colors.slate50, padding: 12, borderRadius: BorderRadius.md, width: '100%', borderWidth: 1, borderColor: Colors.slate200 },
  notesText: { fontSize: FontSize.sm, color: Colors.textPrimary, fontStyle: 'italic' },
  
  primaryBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, backgroundColor: Colors.brandBlue, paddingVertical: 16, borderRadius: BorderRadius.lg, shadowColor: Colors.brandBlue, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.2, shadowRadius: 8, elevation: 6 },
  primaryBtnText: { color: '#FFF', fontSize: FontSize.md, fontWeight: '700' },

  // Provider
  providerCard: { flexDirection: 'row', alignItems: 'center', backgroundColor: Colors.surface, padding: 12, borderRadius: BorderRadius.xl, marginBottom: 12, borderWidth: 2, borderColor: Colors.borderLight },
  providerCardSelected: { borderColor: Colors.brandBlue, backgroundColor: Colors.blueBg },
  providerImg: { width: 60, height: 60, borderRadius: BorderRadius.md, marginRight: 14 },
  pName: { fontSize: FontSize.base, fontWeight: '800', color: Colors.textPrimary, marginBottom: 4 },
  pDetails: { fontSize: FontSize.sm, color: Colors.textSecondary, fontWeight: '600' },
  priceBox: { backgroundColor: Colors.emeraldBg, paddingHorizontal: 12, paddingVertical: 8, borderRadius: BorderRadius.md },
  priceText: { color: Colors.emerald, fontWeight: '900', fontSize: FontSize.base },

  // Slots
  slotsCard: { marginTop: 12, backgroundColor: Colors.surface, padding: 16, borderRadius: BorderRadius.xl, borderWidth: 1, borderColor: Colors.borderLight },
  slotRow: { flexDirection: 'row', gap: 12, marginBottom: 16 },
  dateChip: { flex: 1, paddingVertical: 12, alignItems: 'center', borderRadius: BorderRadius.md, backgroundColor: Colors.slate100 },
  dateChipSelected: { backgroundColor: Colors.brandBlue },
  dateText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.slate600 },
  dateTextSelected: { color: '#FFF' },
  slotGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  timeChip: { paddingHorizontal: 16, paddingVertical: 10, borderRadius: BorderRadius.md, borderWidth: 1, borderColor: Colors.border },
  timeChipSelected: { borderColor: Colors.brandBlue, backgroundColor: Colors.blueBg },
  timeText: { fontSize: FontSize.sm, fontWeight: '600', color: Colors.textSecondary },
  timeTextSelected: { color: Colors.brandBlue, fontWeight: '800' },

  // Receipt
  receiptCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 24, borderWidth: 1, borderColor: Colors.borderLight, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.05, shadowRadius: 10, elevation: 4 },
  receiptTitle: { fontSize: FontSize.xl, fontWeight: '900', color: Colors.textPrimary, textAlign: 'center' },
  divider: { height: 1, borderStyle: 'dashed', borderWidth: 1, borderColor: Colors.border, marginVertical: 20 },
  totalKey: { fontSize: FontSize.base, color: Colors.textPrimary, fontWeight: '800' },
  totalVal: { fontSize: FontSize.xl, color: Colors.emerald, fontWeight: '900' },
  paymentBtn: { backgroundColor: Colors.textPrimary, paddingVertical: 16, borderRadius: BorderRadius.lg, alignItems: 'center', marginTop: 32 },
  paymentBtnText: { color: '#FFF', fontSize: FontSize.md, fontWeight: '800' },
  secureBox: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 6, marginTop: 16 },
  secureText: { fontSize: FontSize.xs, color: Colors.emerald, fontWeight: '700' },
});
