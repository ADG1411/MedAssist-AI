import { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput, Alert, Vibration } from 'react-native';
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
      // 1. Fetch Patient Data
      const patient = await getPatientById(result.patientId);
      if (patient) {
        setPatientData(patient);
        // 2. Auto-save to 'My Patients' if logged in
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
    if (scanned) return;
    setScanned(true);
    Vibration.vibrate(100);
    try {
      const result = parseToken(data);
      processScanResult(result);
    } catch (e: any) {
      Alert.alert('Scan Error', e.message);
      setTimeout(() => setScanned(false), 2000);
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

  const generateDemoToken = (id: string) => {
    const ts = Date.now() + 30 * 60 * 1000;
    return `MEDCARD::${id}::${ts}`;
  };

  const resetScan = () => {
    setScanResult(null);
    setPatientData(null);
    setScanned(false);
    setManualToken('');
  };

  // Preview Card View
  if (scanResult && patientData) {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={resetScan} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={Colors.textPrimary} />
          </TouchableOpacity>
          <Text style={styles.pageTitle}>Patient Found</Text>
        </View>
        <ScrollView contentContainerStyle={{ padding: 16 }}>
          <View style={[styles.previewCard, scanResult.isEmergency && styles.previewCardEmergency]}>
            <View style={styles.previewHeader}>
              <View style={styles.resultIconBox}>
                <Ionicons name={scanResult.isEmergency ? 'warning' : 'person'} size={32}
                  color={scanResult.isEmergency ? Colors.red : Colors.brandBlue} />
              </View>
              <View style={{ flex: 1, marginLeft: 12 }}>
                <Text style={styles.resultTitle}>{patientData.name}</Text>
                <Text style={styles.resultType}>{patientData.age}y • {patientData.gender} • ID: {patientData.id}</Text>
              </View>
            </View>

            <View style={styles.previewDetails}>
              <View style={styles.detailRow}>
                <Text style={styles.detailLabel}>Blood Group:</Text>
                <Text style={styles.detailValue}>{patientData.blood_group}</Text>
              </View>
              <View style={styles.detailRow}>
                <Text style={styles.detailLabel}>Last Visit:</Text>
                <Text style={styles.detailValue}>{patientData.lastVisit}</Text>
              </View>
              {patientData.allergies.length > 0 && (
                <View style={styles.detailRow}>
                  <Text style={styles.detailLabel}>Allergies:</Text>
                  <Text style={[styles.detailValue, { color: Colors.red }]}>{patientData.allergies.join(', ')}</Text>
                </View>
              )}
            </View>

            {scanResult.isEmergency && (
              <View style={styles.emergencyBanner}>
                <Text style={styles.emergencyText}>🚨 EMERGENCY SCAN DETECTED</Text>
              </View>
            )}

            <View style={styles.resultActions}>
              <TouchableOpacity 
                style={styles.resultBtn}
                onPress={() => router.push(`/(dashboard)/patient-record?id=${patientData.id}&name=${encodeURIComponent(patientData.name)}`)}
              >
                <Ionicons name="document-text" size={18} color="#FFF" />
                <Text style={styles.resultBtnText}>Open Dashboard</Text>
              </TouchableOpacity>
              <TouchableOpacity style={[styles.resultBtn, { backgroundColor: Colors.emerald }]} onPress={() => router.push('/(dashboard)/prescription')}>
                <Ionicons name="medkit" size={18} color="#FFF" />
                <Text style={styles.resultBtnText}>Quick Prescribe</Text>
              </TouchableOpacity>
            </View>
          </View>

          <TouchableOpacity style={styles.scanAgainBtn} onPress={resetScan}>
            <Ionicons name="refresh" size={18} color={Colors.brandBlue} />
            <Text style={styles.scanAgainText}>Scan Another</Text>
          </TouchableOpacity>
        </ScrollView>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.pageTitle}>Patient Access</Text>
      </View>

      {/* Mode Tabs */}
      <View style={styles.modeTabs}>
        {(['camera', 'manual', 'demo'] as ScanMode[]).map(m => (
          <TouchableOpacity key={m} style={[styles.modeTab, mode === m && styles.modeTabActive]} onPress={() => setMode(m)}>
            <Ionicons name={m === 'camera' ? 'camera' : m === 'manual' ? 'create' : 'flask'} size={16}
              color={mode === m ? '#FFF' : Colors.slate600} />
            <Text style={[styles.modeTabText, mode === m && styles.modeTabTextActive]}>
              {m === 'camera' ? 'Camera' : m === 'manual' ? 'Manual' : 'Demo'}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      <ScrollView contentContainerStyle={{ padding: 16, paddingBottom: 120 }}>
        {mode === 'camera' && (
          <View>
            {!permission?.granted ? (
              <View style={styles.permissionCard}>
                <Ionicons name="camera-outline" size={48} color={Colors.slate400} />
                <Text style={styles.permissionTitle}>Camera Access Needed</Text>
                <Text style={styles.permissionDesc}>Allow camera to scan MedCard QR codes for instant patient access.</Text>
                <TouchableOpacity style={styles.permissionBtn} onPress={requestPermission}>
                  <Text style={styles.permissionBtnText}>Grant Access</Text>
                </TouchableOpacity>
              </View>
            ) : (
              <View style={styles.cameraBox}>
                <CameraView
                  style={styles.camera}
                  facing="back"
                  barcodeScannerSettings={{ barcodeTypes: ['qr'] }}
                  onBarcodeScanned={scanned ? undefined : (r) => handleScan(r.data)}
                />
                <View style={styles.cameraOverlay}>
                  <View style={styles.scanFrame} />
                </View>
                <Text style={styles.cameraHint}>Point camera at MedCard or Health ID QR</Text>
              </View>
            )}
            <View style={styles.infoCard}>
              <Ionicons name="information-circle" size={20} color={Colors.brandBlue} />
              <Text style={styles.infoText}>Scanning automatically adds the patient to your directory.</Text>
            </View>
          </View>
        )}

        {mode === 'manual' && (
          <View style={styles.manualCard}>
            <Ionicons name="create-outline" size={40} color={Colors.brandBlue} />
            <Text style={styles.manualTitle}>Enter QR Token</Text>
            <Text style={styles.manualDesc}>Paste or type the QR code content manually</Text>
            <TextInput style={styles.manualInput} placeholder="e.g. MEDCARD::1::1714234567890"
              placeholderTextColor={Colors.slate400} value={manualToken} onChangeText={setManualToken}
              multiline />
            <TouchableOpacity style={styles.manualBtn} onPress={handleManualSubmit}>
              <Text style={styles.manualBtnText}>{loading ? 'Verifying...' : 'Verify Token'}</Text>
            </TouchableOpacity>
          </View>
        )}

        {mode === 'demo' && (
          <View>
            <Text style={styles.demoTitle}>🧪 Testing & Demo</Text>
            <Text style={styles.demoDesc}>Select a patient to generate a MedCard QR code and test the flow.</Text>
            {DEMO_PATIENTS.map(p => (
              <TouchableOpacity key={p.id} style={[styles.demoCard, selectedDemo?.id === p.id && styles.demoCardSelected]}
                onPress={() => setSelectedDemo(p)}>
                <View style={{ flex: 1 }}>
                  <Text style={styles.demoName}>{p.name}</Text>
                  <Text style={styles.demoMeta}>{p.age}y • Blood: {p.blood} • Phone: {p.phone}</Text>
                </View>
                <Ionicons name={selectedDemo?.id === p.id ? 'checkmark-circle' : 'ellipse-outline'} size={24}
                  color={selectedDemo?.id === p.id ? Colors.brandBlue : Colors.slate400} />
              </TouchableOpacity>
            ))}
            {selectedDemo && (
              <View style={styles.qrCard}>
                <Text style={styles.qrLabel}>Generated QR for {selectedDemo.name}</Text>
                <View style={styles.qrBox}>
                  <QRCode value={generateDemoToken(selectedDemo.id)} size={180} backgroundColor="#FFF" color={Colors.textPrimary} />
                </View>
                <TouchableOpacity style={styles.scanDemoBtn} onPress={() => handleScan(generateDemoToken(selectedDemo.id))}>
                  <Ionicons name="scan" size={18} color="#FFF" />
                  <Text style={styles.scanDemoBtnText}>Simulate Scan</Text>
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
  container: { flex: 1, backgroundColor: Colors.background },
  header: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingTop: 56, paddingBottom: 12 },
  backBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.surface, justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: Colors.border },
  pageTitle: { fontSize: FontSize.h1, fontWeight: '900', color: Colors.textPrimary },
  modeTabs: { flexDirection: 'row', marginHorizontal: 16, backgroundColor: Colors.surface, borderRadius: BorderRadius.lg, padding: 4, borderWidth: 1, borderColor: Colors.border, marginBottom: 8 },
  modeTab: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, paddingVertical: 10, borderRadius: BorderRadius.md },
  modeTabActive: { backgroundColor: Colors.brandBlue },
  modeTabText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.slate600 },
  modeTabTextActive: { color: '#FFF' },
  // Camera
  cameraBox: { borderRadius: BorderRadius.xxl, overflow: 'hidden', marginBottom: 16 },
  camera: { width: '100%', height: 350 },
  cameraOverlay: { ...StyleSheet.absoluteFillObject, justifyContent: 'center', alignItems: 'center' },
  scanFrame: { width: 220, height: 220, borderWidth: 3, borderColor: Colors.brandBlue, borderRadius: 24, backgroundColor: 'transparent' },
  cameraHint: { textAlign: 'center', color: Colors.textSecondary, fontSize: FontSize.sm, fontWeight: '600', paddingVertical: 12 },
  infoCard: { flexDirection: 'row', alignItems: 'center', gap: 10, backgroundColor: Colors.blueBg, padding: 16, borderRadius: BorderRadius.lg, borderWidth: 1, borderColor: Colors.blueLight },
  infoText: { flex: 1, color: Colors.brandBlue, fontSize: FontSize.sm, fontWeight: '600' },
  // Permission
  permissionCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 40, alignItems: 'center', gap: 12, borderWidth: 1, borderColor: Colors.border },
  permissionTitle: { fontSize: FontSize.xl, fontWeight: '800', color: Colors.textPrimary },
  permissionDesc: { fontSize: FontSize.md, color: Colors.textSecondary, textAlign: 'center' },
  permissionBtn: { backgroundColor: Colors.brandBlue, paddingHorizontal: 28, paddingVertical: 14, borderRadius: BorderRadius.full, marginTop: 8 },
  permissionBtnText: { color: '#FFF', fontWeight: '700', fontSize: FontSize.md },
  // Manual
  manualCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 24, alignItems: 'center', gap: 10, borderWidth: 1, borderColor: Colors.border },
  manualTitle: { fontSize: FontSize.xl, fontWeight: '800', color: Colors.textPrimary },
  manualDesc: { fontSize: FontSize.md, color: Colors.textSecondary, textAlign: 'center' },
  manualInput: { width: '100%', backgroundColor: Colors.slate50, borderRadius: BorderRadius.md, padding: 14, fontSize: FontSize.md, color: Colors.textPrimary, borderWidth: 1, borderColor: Colors.border, minHeight: 80, textAlignVertical: 'top', marginTop: 8 },
  manualBtn: { backgroundColor: Colors.brandBlue, width: '100%', paddingVertical: 14, borderRadius: BorderRadius.md, alignItems: 'center', marginTop: 8 },
  manualBtnText: { color: '#FFF', fontWeight: '700', fontSize: FontSize.md },
  // Demo
  demoTitle: { fontSize: FontSize.xl, fontWeight: '800', color: Colors.textPrimary, marginBottom: 4 },
  demoDesc: { fontSize: FontSize.md, color: Colors.textSecondary, marginBottom: 16 },
  demoCard: { flexDirection: 'row', alignItems: 'center', backgroundColor: Colors.surface, borderRadius: BorderRadius.lg, padding: 16, marginBottom: 10, borderWidth: 1.5, borderColor: Colors.border },
  demoCardSelected: { borderColor: Colors.brandBlue, backgroundColor: Colors.blueBg },
  demoName: { fontSize: FontSize.base, fontWeight: '700', color: Colors.textPrimary },
  demoMeta: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 },
  qrCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 24, alignItems: 'center', borderWidth: 1, borderColor: Colors.border, marginTop: 16 },
  qrLabel: { fontSize: FontSize.md, fontWeight: '700', color: Colors.textPrimary, marginBottom: 16 },
  qrBox: { padding: 16, backgroundColor: '#FFF', borderRadius: 16, borderWidth: 1, borderColor: Colors.border, marginBottom: 16 },
  scanDemoBtn: { flexDirection: 'row', alignItems: 'center', gap: 8, backgroundColor: Colors.brandBlue, paddingHorizontal: 24, paddingVertical: 14, borderRadius: BorderRadius.md },
  scanDemoBtnText: { color: '#FFF', fontWeight: '700', fontSize: FontSize.md },
  // Preview
  previewCard: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 24, borderWidth: 1, borderColor: Colors.emeraldLight, shadowColor: Colors.emerald, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.1, shadowRadius: 12, elevation: 8 },
  previewCardEmergency: { borderColor: Colors.redLight, backgroundColor: '#fef2f2' },
  previewHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 20 },
  resultIconBox: { width: 56, height: 56, borderRadius: 28, backgroundColor: Colors.blueBg, justifyContent: 'center', alignItems: 'center' },
  resultTitle: { fontSize: FontSize.xxl, fontWeight: '900', color: Colors.textPrimary },
  resultType: { fontSize: FontSize.md, fontWeight: '600', color: Colors.textSecondary, marginTop: 2 },
  previewDetails: { backgroundColor: Colors.slate50, borderRadius: BorderRadius.lg, padding: 16, gap: 12, marginBottom: 24, borderWidth: 1, borderColor: Colors.borderLight },
  detailRow: { flexDirection: 'row', justifyContent: 'space-between' },
  detailLabel: { fontSize: FontSize.sm, fontWeight: '600', color: Colors.textSecondary },
  detailValue: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.textPrimary },
  emergencyBanner: { backgroundColor: Colors.red, padding: 12, borderRadius: BorderRadius.md, alignItems: 'center', marginBottom: 20 },
  emergencyText: { color: '#FFF', fontWeight: '800', fontSize: FontSize.sm, letterSpacing: 0.5 },
  resultActions: { width: '100%', gap: 10 },
  resultBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, backgroundColor: Colors.brandBlue, paddingVertical: 14, borderRadius: BorderRadius.md },
  resultBtnText: { color: '#FFF', fontWeight: '700', fontSize: FontSize.md },
  scanAgainBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, marginTop: 20, paddingVertical: 14 },
  scanAgainText: { color: Colors.brandBlue, fontWeight: '700', fontSize: FontSize.md },
});
