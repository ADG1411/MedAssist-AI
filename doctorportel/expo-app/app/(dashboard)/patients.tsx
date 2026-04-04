import { useState, useEffect } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput, Image, RefreshControl, FlatList
} from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import { supabase } from '../../services/supabase';

interface PatientItem {
  id: string; name: string; age: number; gender: string; status: string;
  lastDiagnosis: string; lastVisit: string; phone: string; blood_group: string;
  avatar: string; isFavorite: boolean; riskScore: number; tags: string[];
}

const MOCK_PATIENTS: PatientItem[] = [
  { id: '1', name: 'Rahul Sharma', age: 34, gender: 'Male', status: 'Active', lastDiagnosis: 'Hypertension Stage 1', lastVisit: '2025-01-15', phone: '+91 98765 43210', blood_group: 'B+', avatar: 'https://ui-avatars.com/api/?name=Rahul+Sharma&background=f87171&color=fff', isFavorite: true, riskScore: 65, tags: ['Cardiac', 'BP'] },
  { id: '2', name: 'Priya Verma', age: 28, gender: 'Female', status: 'Active', lastDiagnosis: 'Iron Deficiency Anaemia', lastVisit: '2025-01-12', phone: '+91 87654 32109', blood_group: 'A+', avatar: 'https://ui-avatars.com/api/?name=Priya+Verma&background=60a5fa&color=fff', isFavorite: false, riskScore: 30, tags: ['Anaemia'] },
  { id: '3', name: 'Arjun Mehta', age: 52, gender: 'Male', status: 'Critical', lastDiagnosis: 'Coronary Artery Disease', lastVisit: '2025-02-01', phone: '+91 77543 21098', blood_group: 'O+', avatar: 'https://ui-avatars.com/api/?name=Arjun+Mehta&background=34d399&color=fff', isFavorite: true, riskScore: 85, tags: ['Cardiac', 'Diabetic', 'High Risk'] },
  { id: '4', name: 'Ananya Gupta', age: 45, gender: 'Female', status: 'Recovered', lastDiagnosis: 'Viral Infection', lastVisit: '2025-01-08', phone: '+91 99887 12345', blood_group: 'AB+', avatar: 'https://ui-avatars.com/api/?name=Ananya+Gupta&background=f59e0b&color=fff', isFavorite: false, riskScore: 15, tags: ['Follow-up'] },
  { id: '5', name: 'Vikram Singh', age: 60, gender: 'Male', status: 'Active', lastDiagnosis: 'Type 2 Diabetes', lastVisit: '2025-01-20', phone: '+91 88776 54321', blood_group: 'B-', avatar: 'https://ui-avatars.com/api/?name=Vikram+Singh&background=8b5cf6&color=fff', isFavorite: false, riskScore: 70, tags: ['Diabetic', 'Elderly'] },
];

export default function PatientsScreen() {
  const router = useRouter();
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<'All' | 'Active' | 'Critical' | 'Recovered'>('All');
  const [patients, setPatients] = useState(MOCK_PATIENTS);
  const [refreshing, setRefreshing] = useState(false);
  const [selectedPatient, setSelectedPatient] = useState<PatientItem | null>(null);

  const filtered = patients.filter(p => {
    const matchSearch = p.name.toLowerCase().includes(search.toLowerCase()) || p.id.includes(search);
    const matchFilter = filter === 'All' || p.status === filter;
    return matchSearch && matchFilter;
  });

  const onRefresh = () => { setRefreshing(true); setTimeout(() => setRefreshing(false), 800); };

  const statusStyle = (s: string) => {
    switch (s) {
      case 'Active': return { bg: Colors.emeraldBg, text: Colors.emerald };
      case 'Critical': return { bg: Colors.redBg, text: Colors.red };
      case 'Recovered': return { bg: Colors.blueBg, text: Colors.brandBlue };
      default: return { bg: Colors.slate100, text: Colors.slate600 };
    }
  };

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.pageTitle}>Patients</Text>
        <TouchableOpacity style={styles.addBtn}>
          <Ionicons name="person-add" size={18} color={Colors.textWhite} />
        </TouchableOpacity>
      </View>

      {/* Search */}
      <View style={styles.searchBox}>
        <Ionicons name="search" size={18} color={Colors.slate400} />
        <TextInput style={styles.searchInput} placeholder="Search by name, ID..." placeholderTextColor={Colors.slate400}
          value={search} onChangeText={setSearch} />
        {search.length > 0 && (
          <TouchableOpacity onPress={() => setSearch('')}>
            <Ionicons name="close-circle" size={18} color={Colors.slate400} />
          </TouchableOpacity>
        )}
      </View>

      {/* Filters */}
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.filterScroll} contentContainerStyle={{ gap: 8, paddingHorizontal: 16 }}>
        {(['All', 'Active', 'Critical', 'Recovered'] as const).map(f => (
          <TouchableOpacity key={f} style={[styles.filterChip, filter === f && styles.filterChipActive]} onPress={() => setFilter(f)}>
            <Text style={[styles.filterText, filter === f && styles.filterTextActive]}>{f}</Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* Patient List */}
      <FlatList
        data={filtered}
        keyExtractor={p => p.id}
        contentContainerStyle={{ padding: 16, paddingBottom: 100 }}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={Colors.brandBlue} />}
        ListEmptyComponent={<Text style={styles.emptyText}>No patients found</Text>}
        renderItem={({ item: p }) => {
          const ss = statusStyle(p.status);
          return (
            <TouchableOpacity style={styles.patientCard} onPress={() => setSelectedPatient(p)} activeOpacity={0.7}>
              <Image source={{ uri: p.avatar }} style={styles.avatar} />
              <View style={{ flex: 1 }}>
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                  <Text style={styles.patientName}>{p.name}</Text>
                  {p.isFavorite && <Ionicons name="star" size={12} color={Colors.amber} />}
                </View>
                <Text style={styles.patientMeta}>{p.age}y • {p.gender} • {p.blood_group}</Text>
                <Text style={styles.patientDiag} numberOfLines={1}>{p.lastDiagnosis}</Text>
                <View style={styles.tagRow}>
                  {p.tags.slice(0, 3).map(t => (
                    <View key={t} style={styles.tag}><Text style={styles.tagText}>{t}</Text></View>
                  ))}
                </View>
              </View>
              <View style={{ alignItems: 'flex-end', gap: 6 }}>
                <View style={[styles.statusBadge, { backgroundColor: ss.bg }]}>
                  <Text style={[styles.statusText, { color: ss.text }]}>{p.status}</Text>
                </View>
                <Text style={styles.riskText}>Risk: {p.riskScore}%</Text>
              </View>
            </TouchableOpacity>
          );
        }}
      />

      {/* Patient Drawer (Bottom Sheet) */}
      {selectedPatient && (
        <TouchableOpacity style={styles.drawerOverlay} activeOpacity={1} onPress={() => setSelectedPatient(null)}>
          <View style={styles.drawer} onStartShouldSetResponder={() => true}>
            <View style={styles.drawerHandle} />
            <View style={styles.drawerHeader}>
              <Image source={{ uri: selectedPatient.avatar }} style={styles.drawerAvatar} />
              <View style={{ flex: 1 }}>
                <Text style={styles.drawerName}>{selectedPatient.name}</Text>
                <Text style={styles.drawerMeta}>{selectedPatient.age}y • {selectedPatient.gender} • {selectedPatient.blood_group}</Text>
              </View>
              <TouchableOpacity onPress={() => setSelectedPatient(null)}>
                <Ionicons name="close-circle" size={28} color={Colors.slate400} />
              </TouchableOpacity>
            </View>

            <View style={styles.drawerInfoGrid}>
              <View style={styles.drawerInfoItem}>
                <Ionicons name="call" size={16} color={Colors.brandBlue} />
                <Text style={styles.drawerInfoText}>{selectedPatient.phone}</Text>
              </View>
              <View style={styles.drawerInfoItem}>
                <Ionicons name="water" size={16} color={Colors.red} />
                <Text style={styles.drawerInfoText}>Blood: {selectedPatient.blood_group}</Text>
              </View>
              <View style={styles.drawerInfoItem}>
                <Ionicons name="pulse" size={16} color={Colors.amber} />
                <Text style={styles.drawerInfoText}>Risk Score: {selectedPatient.riskScore}%</Text>
              </View>
              <View style={styles.drawerInfoItem}>
                <Ionicons name="medical" size={16} color={Colors.purple} />
                <Text style={styles.drawerInfoText}>{selectedPatient.lastDiagnosis}</Text>
              </View>
            </View>

            <View style={styles.drawerActions}>
              <TouchableOpacity style={[styles.drawerBtn, { backgroundColor: Colors.brandBlue }]}
                onPress={() => { setSelectedPatient(null); router.push({ pathname: '/(dashboard)/patient-record', params: { id: selectedPatient.id, name: selectedPatient.name } }); }}>
                <Ionicons name="document-text" size={18} color="#FFF" />
                <Text style={styles.drawerBtnTextWhite}>View Record</Text>
              </TouchableOpacity>
              <TouchableOpacity style={[styles.drawerBtn, { backgroundColor: Colors.emeraldBg, borderWidth: 1, borderColor: Colors.emeraldLight }]}>
                <Ionicons name="videocam" size={18} color={Colors.emerald} />
                <Text style={[styles.drawerBtnText, { color: Colors.emerald }]}>Consult</Text>
              </TouchableOpacity>
              <TouchableOpacity style={[styles.drawerBtn, { backgroundColor: Colors.purpleBg, borderWidth: 1, borderColor: Colors.purpleLight }]}
                onPress={() => { setSelectedPatient(null); router.push('/(dashboard)/referral'); }}>
                <Ionicons name="share-social" size={18} color={Colors.purple} />
                <Text style={[styles.drawerBtnText, { color: Colors.purple }]}>Refer</Text>
              </TouchableOpacity>
            </View>
          </View>
        </TouchableOpacity>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.background },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 16, paddingTop: 56, paddingBottom: 12 },
  pageTitle: { fontSize: FontSize.h1, fontWeight: '900', color: Colors.textPrimary },
  addBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.brandBlue, justifyContent: 'center', alignItems: 'center' },
  searchBox: { flexDirection: 'row', alignItems: 'center', backgroundColor: Colors.surface, marginHorizontal: 16, borderRadius: BorderRadius.lg, paddingHorizontal: 14, height: 48, borderWidth: 1, borderColor: Colors.border, gap: 10, marginBottom: 12 },
  searchInput: { flex: 1, fontSize: FontSize.md, color: Colors.textPrimary },
  filterScroll: { marginBottom: 8, maxHeight: 44 },
  filterChip: { paddingHorizontal: 16, paddingVertical: 8, borderRadius: BorderRadius.full, backgroundColor: Colors.surface, borderWidth: 1, borderColor: Colors.border },
  filterChipActive: { backgroundColor: Colors.brandBlue, borderColor: Colors.brandBlue },
  filterText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.slate600 },
  filterTextActive: { color: '#FFF' },
  patientCard: { flexDirection: 'row', gap: 12, backgroundColor: Colors.surface, borderRadius: BorderRadius.xl, padding: 14, marginBottom: 10, borderWidth: 1, borderColor: Colors.borderLight, shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.03, shadowRadius: 4, elevation: 1 },
  avatar: { width: 50, height: 50, borderRadius: 16, borderWidth: 2, borderColor: '#FFF' },
  patientName: { fontSize: FontSize.base, fontWeight: '700', color: Colors.textPrimary },
  patientMeta: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 },
  patientDiag: { fontSize: FontSize.sm, color: Colors.slate600, fontWeight: '500', marginTop: 3 },
  tagRow: { flexDirection: 'row', gap: 4, marginTop: 6 },
  tag: { backgroundColor: Colors.slate100, paddingHorizontal: 8, paddingVertical: 2, borderRadius: 6 },
  tagText: { fontSize: 10, fontWeight: '700', color: Colors.slate600 },
  statusBadge: { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 6 },
  statusText: { fontSize: FontSize.xs, fontWeight: '700' },
  riskText: { fontSize: FontSize.xs, color: Colors.textTertiary, fontWeight: '600' },
  emptyText: { textAlign: 'center', color: Colors.textSecondary, fontSize: FontSize.md, paddingVertical: 40 },
  // Drawer
  drawerOverlay: { ...StyleSheet.absoluteFillObject, backgroundColor: Colors.overlay, justifyContent: 'flex-end', zIndex: 100 },
  drawer: { backgroundColor: Colors.surface, borderTopLeftRadius: 28, borderTopRightRadius: 28, paddingHorizontal: 20, paddingBottom: 40, paddingTop: 12, maxHeight: '70%' },
  drawerHandle: { width: 40, height: 4, borderRadius: 2, backgroundColor: Colors.slate300, alignSelf: 'center', marginBottom: 16 },
  drawerHeader: { flexDirection: 'row', alignItems: 'center', gap: 14, marginBottom: 20 },
  drawerAvatar: { width: 56, height: 56, borderRadius: 18, borderWidth: 2, borderColor: Colors.blueLight },
  drawerName: { fontSize: FontSize.xl, fontWeight: '800', color: Colors.textPrimary },
  drawerMeta: { fontSize: FontSize.md, color: Colors.textSecondary, marginTop: 2, fontWeight: '500' },
  drawerInfoGrid: { gap: 10, marginBottom: 20 },
  drawerInfoItem: { flexDirection: 'row', alignItems: 'center', gap: 10, backgroundColor: Colors.slate50, padding: 12, borderRadius: BorderRadius.md },
  drawerInfoText: { fontSize: FontSize.md, color: Colors.textPrimary, fontWeight: '500', flex: 1 },
  drawerActions: { flexDirection: 'row', gap: 10 },
  drawerBtn: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, paddingVertical: 14, borderRadius: BorderRadius.md },
  drawerBtnText: { fontSize: FontSize.sm, fontWeight: '700' },
  drawerBtnTextWhite: { fontSize: FontSize.sm, fontWeight: '700', color: '#FFF' },
});
