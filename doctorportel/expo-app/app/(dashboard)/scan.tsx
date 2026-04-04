import { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput, Alert, Vibration, Platform } from 'react-native';
import { CameraView, useCameraPermissions } from 'expo-camera';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import QRCode from 'react-native-qrcode-svg';
import { getPatientById, autoSavePatient, PatientData } from '../../services/patientService';
import { supabase } from '../../services/supabase';

type ScanMode = 'camera' | 'manual' | 'demo';

interface ScanResult {
  type: string;
  patientId: string;
  isEmergency: boolean;
}

function parseToken(token: string): ScanResult {
  const clean = token.trim();
  if (clean.startsWith('medassist://emergency/')) {
    const healthId = clean.replace('medassist://emergency/', '').replace('MD-', '').toLowerCase();
    return { type: 'emergency', patientId: healthId, isEmergency: true };
  }
  if (clean.startsWith('MD-') && !clean.includes('::')) {
    return { type: 'health_id', patientId: clean.replace('MD-', '').toLowerCase(), isEmergency: false };
  }
  if (clean.startsWith('MEDCARD::')) {
    const parts = clean.split('::');
    if (parts.length < 2) throw new Error('Invalid QR token');
    let expired = false;
    if (parts[2]) {
      const ts = parseInt(parts[2], 10);
      if (!isNaN(ts) && Date.now() > ts) expired = true;
    }
    if (expired) throw new Error('QR token expired');
    return { type: 'medcard', patientId: parts[1], isEmergency: false };
  }
  if (clean.startsWith('REFQR::')) {
    return { type: 'referral', patientId: clean.split('::')[1], isEmergency: false };
  }
  throw new Error('Unrecognized QR format');
}

const DEMO_PATIENTS = [
  { id: '1', name: 'Rahul Sharma', age: 34, blood: 'B+', phone: '+91 98765 43210' },
  { id: '2', name: 'Priya Verma', age: 28, blood: 'A+', phone: '+91 87654 32109' },
  { id: '3', name: 'Arjun Mehta', age: 52, blood: 'O+', phone: '+91 77543 21098' },
];

export default function ScanScreen() {
  const router = useRouter();
  const [permission, requestPermission] = useCameraPermissions();
  const [mode, setMode] = useState<ScanMode>('camera');
  const [manualToken, setManualToken] = useState('');
  
  const [scanned, setScanned] = useState(false);
  const [scanResult, setScanResult] = useState<ScanResult | null>(null);
  const [patientData, setPatientData] = useState<PatientData | null>(null);
  const [loading, setLoading] = useState(false);
  const [selectedDemo, setSelectedDemo] = useState<typeof DEMO_PATIENTS[0] | null>(null);

  useEffect(() => {
    if (!permission?.granted && mode === 'camera') {
      requestPermission();
    }
  }, [mode, permission, requestPermission]);

  const processScanResult = async (result: ScanResult) => {
    setLoading(true);
    setScanResult(result);
    try {
      const patient = await getPatientById(result.patientId);
      if (patient) {
        setPatientData(patient);
        const { data: authData } = await supabase.auth.getUser();
        if (authData?.user) {
          await autoSavePatient(result.patientId, authData.user.id);
        }
      } else {
        throw new Error('Patient not found in system');
      }
    } catch (e: any) {
      Alert.alert('System Error', e.message);
      setScanned(false);
      setScanResult(null);
    } finally {
      setLoading(false);
    }
  };

  const handleScan = (data: string) => {
    if (scanned || !data) return;
    setScanned(true);
    if (Platform.OS !== 'web') Vibration.vibrate(100);
    try {
      const result = parseToken(data);
      if (result.type === 'referral') {
        router.push(`/(dashboard)/provider-ticket?qr=REFQR::${result.patientId}`);
        setTimeout(() => setScanned(false), 2000);
        return;
      }
      processScanResult(result);
    } catch (e: any) {
      Alert.alert('Scan Error', e.message);
      setTimeout(() => setScanned(false), 2500);
    }
  };

  const handleManualSubmit = () => {
    if (!manualToken.trim()) return;
    try {
      const result = parseToken(manualToken.trim());
      processScanResult(result);
    } catch (e: any) {
      Alert.alert('Error', e.message);
    }
  };

  const resetScan = () => {
    setScanResult(null);
    setPatientData(null);
    setScanned(false);
    setManualToken('');
  };

  const generateDemoToken = (id: string) => {
    const ts = Date.now() + 30 * 60 * 1000;
    return `MEDCARD::${id}::${ts}`;
  };

  // ------------------
  // PREVIEW VIEW
  // ------------------
  if (scanResult && patientData) {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={resetScan} style={styles.iconBtn}>
            <Ionicons name="close" size={24} color={Colors.textPrimary} />
          </TouchableOpacity>
          <Text style={styles.pageTitle}>Patient Card</Text>
          <View style={{ width: 40 }} />
        </View>
        <ScrollView contentContainerStyle={{ padding: 20 }}>
          <View style={[styles.modernCard, scanResult.isEmergency && styles.emergencyCard]}>
            <View style={styles.modernCardHeader}>
              <View style={[styles.modernAvatar, scanResult.isEmergency && { backgroundColor: Colors.redBg }]}>
                <Ionicons name={scanResult.isEmergency ? 'medical' : 'person'} size={32}
                  color={scanResult.isEmergency ? Colors.red : Colors.brandBlue} />
              </View>
              <View style={{ flex: 1, marginLeft: 16 }}>
                <Text style={styles.patientName}>{patientData.name}</Text>
                <Text style={styles.patientMeta}>{patientData.age} yrs • {patientData.gender}</Text>
                <View style={styles.badgeRow}>
                  <View style={styles.badge}><Text style={styles.badgeText}>ID: {patientData.id}</Text></View>
                  <View style={styles.badgeBlood}><Text style={styles.badgeBloodText}>{patientData.blood_group}</Text></View>
                </View>
              </View>
            </View>

            <View style={styles.divider} />

            <View style={styles.detailsGrid}>
              <View style={styles.detailBox}>
                <Text style={styles.detailLabel}>Last Visit</Text>
                <Text style={styles.detailValue}>{patientData.lastVisit}</Text>
              </View>
              <View style={styles.detailBox}>
                <Text style={styles.detailLabel}>Visits</Text>
                <Text style={styles.detailValue}>{patientData.visitCount}</Text>
              </View>
            </View>

            {patientData.allergies.length > 0 && (
              <View style={styles.alertBox}>
                <Ionicons name="warning" size={18} color={Colors.red} />
                <Text style={styles.alertText}>Allergies: {patientData.allergies.join(', ')}</Text>
              </View>
            )}

            {scanResult.isEmergency && (
              <View style={[styles.alertBox, { backgroundColor: Colors.red, marginTop: 12 }]}>
                <Ionicons name="alert-circle" size={18} color="#FFF" />
                <Text style={[styles.alertText, { color: '#FFF' }]}>EMERGENCY SCAN TRIGGERED</Text>
              </View>
            )}

            <View style={styles.actionGrid}>
              <TouchableOpacity 
                style={[styles.primaryBtn, { flex: 1.5 }]}
                onPress={() => router.push(`/(dashboard)/patient-record?id=${patientData.id}&name=${encodeURIComponent(patientData.name)}`)}
              >
                <Ionicons name="analytics" size={18} color="#FFF" />
                <Text style={styles.btnTextWhite}>Full Dashboard</Text>
              </TouchableOpacity>
              <TouchableOpacity style={[styles.secondaryBtn, { flex: 1 }]} onPress={() => router.push('/(dashboard)/prescription')}>
                <Ionicons name="medkit" size={18} color={Colors.brandBlue} />
                <Text style={styles.btnTextBlue}>Prescribe</Text>
              </TouchableOpacity>
            </View>
          </View>
        </ScrollView>
      </View>
    );
  }

  // ------------------
  // SCANNER MAIN VIEW
  // ------------------
  return (
    <View style={styles.container}>
      {/* Sleek Header */}
      <View style={styles.header}>
        <Text style={styles.pageTitle}>Patient Access</Text>
      </View>

      {/* Modern Pill Segmented Control */}
      <View style={styles.segmentContainer}>
        {(['camera', 'manual', 'demo'] as ScanMode[]).map(m => {
          const isActive = mode === m;
          return (
            <TouchableOpacity key={m} style={[styles.segmentBtn, isActive && styles.segmentBtnActive]} onPress={() => setMode(m)}>
              <Ionicons name={m === 'camera' ? 'scan' : m === 'manual' ? 'keypad' : 'flask'} size={14}
                color={isActive ? Colors.brandBlue : Colors.slate500} />
              <Text style={[styles.segmentText, isActive && styles.segmentTextActive]}>
                {m.charAt(0).toUpperCase() + m.slice(1)}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>

      {/* Content Area */}
      <ScrollView contentContainerStyle={{ padding: 20, paddingBottom: 100 }} showsVerticalScrollIndicator={false}>
        
        {/* CAMERA MODE */}
        {mode === 'camera' && (
          <View style={styles.fadeContainer}>
            {!permission?.granted ? (
              <View style={styles.emptyStateContainer}>
                <View style={styles.iconCircleLg}>
                  <Ionicons name="camera" size={40} color={Colors.brandBlue} />
                </View>
                <Text style={styles.emptyTitle}>Camera Required</Text>
                <Text style={styles.emptyDesc}>Allow MedAssist to access your camera to instantly scan patient QR records.</Text>
                <TouchableOpacity style={styles.primaryBtn} onPress={requestPermission}>
                  <Text style={styles.btnTextWhite}>Enable Camera</Text>
                </TouchableOpacity>
              </View>
            ) : (
              <View style={styles.cameraWrapper}>
                <View style={styles.cameraFrame}>
                  {/* flex: 1 and minHeight assure the camera renders over Web */}
                  <CameraView
                    style={{ flex: 1, minHeight: 400 }}
                    facing="back"
                    barcodeScannerSettings={{ barcodeTypes: ['qr'] }}
                    onBarcodeScanned={scanned ? undefined : (r) => handleScan(r.data)}
                  />
                  {/* Minimalist Overlay */}
                  <View style={styles.scanOverlay}>
                    <View style={styles.targetSquare}>
                      <View style={[styles.corner, styles.cornerTL]} />
                      <View style={[styles.corner, styles.cornerTR]} />
                      <View style={[styles.corner, styles.cornerBL]} />
                      <View style={[styles.corner, styles.cornerBR]} />
                      {/* Animated scanning line could go here */}
                    </View>
                  </View>
                </View>
                <View style={styles.helperTip}>
                  <Ionicons name="information-circle" size={18} color={Colors.brandBlue} />
                  <Text style={styles.helperText}>Point at MedCard or Health ID</Text>
                </View>
              </View>
            )}
          </View>
        )}

        {/* MANUAL MODE */}
        {mode === 'manual' && (
          <View style={styles.fadeContainer}>
            <View style={styles.modernCard}>
              <View style={styles.iconCircleMd}>
                <Ionicons name="keypad" size={24} color={Colors.brandBlue} />
              </View>
              <Text style={styles.sectionTitle}>Manual Entry</Text>
              <Text style={styles.sectionDesc}>Enter the digital token manually if the QR code is illegible or missing.</Text>
              
              <View style={styles.inputWrapper}>
                <TextInput 
                  style={styles.textInput} 
                  placeholder="e.g. MEDCARD::12345::171..."
                  placeholderTextColor={Colors.slate400} 
                  value={manualToken} 
                  onChangeText={setManualToken}
                  autoCapitalize="none"
                  autoCorrect={false}
                />
              </View>
              
              <TouchableOpacity style={[styles.primaryBtn, { width: '100%', marginTop: 10 }]} onPress={handleManualSubmit}>
                {loading ? <Text style={styles.btnTextWhite}>Verifying...</Text> : <Text style={styles.btnTextWhite}>Verify Token</Text>}
              </TouchableOpacity>
            </View>
          </View>
        )}

        {/* DEMO MODE */}
        {mode === 'demo' && (
          <View style={styles.fadeContainer}>
            <Text style={styles.sectionTitle}>Lab / Demo Mode</Text>
            <Text style={styles.sectionDesc}>Select a test patient to generate a synthetic MedCard token. Use this to simulate a successful scan.</Text>
            
            <View style={{ marginTop: 16 }}>
              {DEMO_PATIENTS.map(p => {
                const isSelected = selectedDemo?.id === p.id;
                return (
                  <TouchableOpacity 
                    key={p.id} 
                    style={[styles.demoPatientCard, isSelected && styles.demoPatientCardActive]}
                    onPress={() => setSelectedDemo(p)}
                    activeOpacity={0.7}
                  >
                    <View style={styles.demoAvatar}>
                      <Text style={styles.demoAvatarText}>{p.name.charAt(0)}</Text>
                    </View>
                    <View style={{ flex: 1 }}>
                      <Text style={[styles.demoName, isSelected && { color: Colors.brandBlue }]}>{p.name}</Text>
                      <Text style={styles.demoDetails}>{p.age}y • Blood: {p.blood}</Text>
                    </View>
                    <Ionicons name={isSelected ? 'radio-button-on' : 'radio-button-off'} size={24} color={isSelected ? Colors.brandBlue : Colors.slate300} />
                  </TouchableOpacity>
                );
              })}
            </View>

            {selectedDemo && (
              <View style={styles.demoResultContainer}>
                <Text style={styles.qrTitle}>Virtual QR Token</Text>
                <View style={styles.qrRenderBox}>
                  <QRCode value={generateDemoToken(selectedDemo.id)} size={160} backgroundColor="#FFF" color={Colors.textPrimary} />
                </View>
                <TouchableOpacity style={styles.primaryBtn} onPress={() => handleScan(generateDemoToken(selectedDemo.id))}>
                  <Ionicons name="scan" size={18} color="#FFF" />
                  <Text style={styles.btnTextWhite}>Inject Scan Result</Text>
                </TouchableOpacity>
              </View>
            )}
          </View>
        )}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.slate50 },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', paddingHorizontal: 20, paddingTop: 60, paddingBottom: 16, backgroundColor: Colors.surface, borderBottomWidth: 1, borderBottomColor: Colors.borderLight },
  pageTitle: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary, letterSpacing: -0.5 },
  iconBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.slate100, justifyContent: 'center', alignItems: 'center' },
  
  // Segment Control
  segmentContainer: { flexDirection: 'row', backgroundColor: Colors.surface, padding: 6, margin: 20, borderRadius: BorderRadius.full, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.05, shadowRadius: 8, elevation: 2 },
  segmentBtn: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, paddingVertical: 12, borderRadius: BorderRadius.full },
  segmentBtnActive: { backgroundColor: Colors.blueBg },
  segmentText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.slate500 },
  segmentTextActive: { color: Colors.brandBlue },

  fadeContainer: { animationDuration: '300ms', animationName: 'fadeIn' as any },

  // Empty/Permission States
  emptyStateContainer: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 32, alignItems: 'center', borderWidth: 1, borderColor: Colors.borderLight, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.03, shadowRadius: 10, elevation: 2 },
  iconCircleLg: { width: 80, height: 80, borderRadius: 40, backgroundColor: Colors.blueBg, justifyContent: 'center', alignItems: 'center', marginBottom: 20 },
  emptyTitle: { fontSize: FontSize.xl, fontWeight: '800', color: Colors.textPrimary, marginBottom: 8 },
  emptyDesc: { fontSize: FontSize.md, color: Colors.textSecondary, textAlign: 'center', lineHeight: 22, marginBottom: 24 },
  
  // Modern Camera
  cameraWrapper: { borderRadius: BorderRadius.xxl, overflow: 'hidden', backgroundColor: '#000', shadowColor: Colors.brandBlue, shadowOffset: { width: 0, height: 8 }, shadowOpacity: 0.15, shadowRadius: 20, elevation: 10 },
  cameraFrame: { width: '100%', height: 450, position: 'relative' },
  scanOverlay: { ...StyleSheet.absoluteFillObject, justifyContent: 'center', alignItems: 'center', backgroundColor: 'rgba(0,0,0,0.3)' },
  targetSquare: { width: 240, height: 240, position: 'relative' },
  corner: { position: 'absolute', width: 40, height: 40, borderColor: '#FFF', borderWidth: 4 },
  cornerTL: { top: 0, left: 0, borderRightWidth: 0, borderBottomWidth: 0, borderTopLeftRadius: 16 },
  cornerTR: { top: 0, right: 0, borderLeftWidth: 0, borderBottomWidth: 0, borderTopRightRadius: 16 },
  cornerBL: { bottom: 0, left: 0, borderRightWidth: 0, borderTopWidth: 0, borderBottomLeftRadius: 16 },
  cornerBR: { bottom: 0, right: 0, borderLeftWidth: 0, borderTopWidth: 0, borderBottomRightRadius: 16 },
  helperTip: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, paddingVertical: 16, backgroundColor: Colors.surface },
  helperText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.textSecondary },

  // Modern Card Shared
  modernCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 24, borderWidth: 1, borderColor: Colors.borderLight, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 12, elevation: 4 },
  iconCircleMd: { width: 56, height: 56, borderRadius: 28, backgroundColor: Colors.blueBg, justifyContent: 'center', alignItems: 'center', marginBottom: 16 },
  sectionTitle: { fontSize: FontSize.xl, fontWeight: '800', color: Colors.textPrimary, marginBottom: 8 },
  sectionDesc: { fontSize: FontSize.sm, color: Colors.textSecondary, lineHeight: 20, opacity: 0.8 },

  // Form Inputs
  inputWrapper: { width: '100%', marginTop: 24, marginBottom: 16 },
  textInput: { backgroundColor: Colors.slate50, borderWidth: 1, borderColor: Colors.border, borderRadius: BorderRadius.lg, paddingHorizontal: 16, paddingVertical: 16, fontSize: FontSize.md, color: Colors.textPrimary, fontWeight: '600' },

  // Demo
  demoPatientCard: { flexDirection: 'row', alignItems: 'center', backgroundColor: Colors.surface, padding: 16, borderRadius: BorderRadius.xl, marginBottom: 12, borderWidth: 1, borderColor: Colors.borderLight, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.02, shadowRadius: 4, elevation: 1 },
  demoPatientCardActive: { borderColor: Colors.brandBlue, backgroundColor: Colors.blueBg },
  demoAvatar: { width: 44, height: 44, borderRadius: 22, backgroundColor: Colors.slate100, justifyContent: 'center', alignItems: 'center', marginRight: 14 },
  demoAvatarText: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.slate500 },
  demoName: { fontSize: FontSize.base, fontWeight: '800', color: Colors.textPrimary, marginBottom: 2 },
  demoDetails: { fontSize: FontSize.xs, color: Colors.textSecondary, fontWeight: '600' },
  demoResultContainer: { marginTop: 24, padding: 24, backgroundColor: Colors.surface, borderRadius: BorderRadius.xl, alignItems: 'center', borderWidth: 1, borderColor: Colors.borderLight },
  qrTitle: { fontSize: FontSize.sm, fontWeight: '800', color: Colors.textSecondary, letterSpacing: 1, textTransform: 'uppercase', marginBottom: 16 },
  qrRenderBox: { padding: 20, backgroundColor: '#FFF', borderRadius: 20, borderWidth: 1, borderColor: Colors.borderLight, marginBottom: 24, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.05, shadowRadius: 8, elevation: 4 },

  // Buttons
  primaryBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, backgroundColor: Colors.brandBlue, paddingVertical: 16, paddingHorizontal: 24, borderRadius: BorderRadius.lg },
  btnTextWhite: { color: '#FFF', fontSize: FontSize.md, fontWeight: '700' },
  secondaryBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, backgroundColor: Colors.blueBg, paddingVertical: 16, paddingHorizontal: 24, borderRadius: BorderRadius.lg },
  btnTextBlue: { color: Colors.brandBlue, fontSize: FontSize.md, fontWeight: '700' },

  // Patient Card Detail
  emergencyCard: { borderColor: Colors.redLight, backgroundColor: '#FFF5F5' },
  modernCardHeader: { flexDirection: 'row', alignItems: 'center' },
  modernAvatar: { width: 64, height: 64, borderRadius: 20, backgroundColor: Colors.blueBg, justifyContent: 'center', alignItems: 'center' },
  patientName: { fontSize: FontSize.xxl, fontWeight: '900', color: Colors.textPrimary, marginBottom: 2 },
  patientMeta: { fontSize: FontSize.sm, color: Colors.textSecondary, fontWeight: '600', marginBottom: 8 },
  badgeRow: { flexDirection: 'row', gap: 8 },
  badge: { backgroundColor: Colors.slate100, paddingHorizontal: 8, paddingVertical: 4, borderRadius: 6 },
  badgeText: { fontSize: 11, fontWeight: '800', color: Colors.slate600 },
  badgeBlood: { backgroundColor: Colors.redBg, paddingHorizontal: 8, paddingVertical: 4, borderRadius: 6 },
  badgeBloodText: { fontSize: 11, fontWeight: '800', color: Colors.red },
  divider: { height: 1, backgroundColor: Colors.borderLight, marginVertical: 20 },
  detailsGrid: { flexDirection: 'row', gap: 16, marginBottom: 20 },
  detailBox: { flex: 1, backgroundColor: Colors.slate50, padding: 12, borderRadius: BorderRadius.lg, borderWidth: 1, borderColor: Colors.borderLight },
  detailLabel: { fontSize: FontSize.xs, color: Colors.textSecondary, fontWeight: '700', marginBottom: 4, textTransform: 'uppercase' },
  detailValue: { fontSize: FontSize.lg, color: Colors.textPrimary, fontWeight: '800' },
  alertBox: { flexDirection: 'row', alignItems: 'center', gap: 8, backgroundColor: Colors.redBg, padding: 12, borderRadius: BorderRadius.lg, marginBottom: 20 },
  alertText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.red },
  actionGrid: { flexDirection: 'row', gap: 12 },
});
