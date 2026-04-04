import { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Switch } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';

const DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const SHORT = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

interface DayConfig { enabled: boolean; start: string; end: string; breakStart: string; breakEnd: string; }

export default function ScheduleScreen() {
  const router = useRouter();
  const [slotDuration, setSlotDuration] = useState(30);
  const [schedule, setSchedule] = useState<Record<string, DayConfig>>(
    Object.fromEntries(DAYS.map(d => [d, { enabled: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].includes(d), start: '09:00', end: '17:00', breakStart: '13:00', breakEnd: '14:00' }]))
  );

  const toggleDay = (day: string) => {
    setSchedule(prev => ({ ...prev, [day]: { ...prev[day], enabled: !prev[day].enabled } }));
  };

  const enabledDays = DAYS.filter(d => schedule[d].enabled);
  const totalSlots = enabledDays.length * Math.floor((8 * 60 - 60) / slotDuration);

  return (
    <ScrollView style={styles.container} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={22} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.pageTitle}>Schedule</Text>
      </View>

      <View style={{ padding: 16, gap: 16 }}>
        {/* Overview */}
        <View style={styles.overviewCard}>
          <View style={styles.overviewItem}>
            <Text style={styles.overviewValue}>{enabledDays.length}</Text>
            <Text style={styles.overviewLabel}>Active Days</Text>
          </View>
          <View style={styles.overviewDivider} />
          <View style={styles.overviewItem}>
            <Text style={styles.overviewValue}>{slotDuration}min</Text>
            <Text style={styles.overviewLabel}>Slot Duration</Text>
          </View>
          <View style={styles.overviewDivider} />
          <View style={styles.overviewItem}>
            <Text style={styles.overviewValue}>{totalSlots}</Text>
            <Text style={styles.overviewLabel}>Total Slots/Week</Text>
          </View>
        </View>

        {/* Slot Duration Selector */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Slot Duration</Text>
          <View style={styles.durationRow}>
            {[15, 20, 30, 45, 60].map(d => (
              <TouchableOpacity key={d} style={[styles.durationChip, slotDuration === d && styles.durationChipActive]}
                onPress={() => setSlotDuration(d)}>
                <Text style={[styles.durationText, slotDuration === d && styles.durationTextActive]}>{d}m</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Weekly Schedule */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Weekly Schedule</Text>
          {DAYS.map((day, i) => (
            <View key={day} style={styles.dayRow}>
              <View style={{ flex: 1 }}>
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                  <View style={[styles.dayDot, { backgroundColor: schedule[day].enabled ? Colors.emerald : Colors.slate300 }]} />
                  <Text style={styles.dayName}>{day}</Text>
                </View>
                {schedule[day].enabled && (
                  <Text style={styles.dayTime}>{schedule[day].start} – {schedule[day].end} (Break: {schedule[day].breakStart}–{schedule[day].breakEnd})</Text>
                )}
              </View>
              <Switch value={schedule[day].enabled} onValueChange={() => toggleDay(day)}
                trackColor={{ false: Colors.slate200, true: Colors.emeraldLight }} thumbColor={schedule[day].enabled ? Colors.emerald : '#fff'} />
            </View>
          ))}
        </View>

        {/* Today's Slots Preview */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>📅 Today's Slots Preview</Text>
          <View style={styles.slotsGrid}>
            {['09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30'].map((slot, i) => (
              <View key={slot} style={[styles.slotChip,
                i === 2 ? styles.slotBooked : i === 5 ? styles.slotBreak : styles.slotAvailable]}>
                <Text style={[styles.slotText,
                  i === 2 ? { color: Colors.red } : i === 5 ? { color: Colors.amber } : { color: Colors.emerald }]}>{slot}</Text>
                <Text style={styles.slotStatus}>{i === 2 ? '🔴 Booked' : i === 5 ? '☕ Break' : '🟢 Open'}</Text>
              </View>
            ))}
          </View>
        </View>

        {/* Save */}
        <TouchableOpacity style={styles.saveBtn}>
          <Text style={styles.saveBtnText}>Save Schedule</Text>
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
  overviewCard: { flexDirection: 'row', backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 20, borderWidth: 1, borderColor: Colors.borderLight },
  overviewItem: { flex: 1, alignItems: 'center' },
  overviewValue: { fontSize: FontSize.xxl, fontWeight: '900', color: Colors.brandBlue },
  overviewLabel: { fontSize: FontSize.xs, fontWeight: '700', color: Colors.textSecondary, marginTop: 4, textTransform: 'uppercase' },
  overviewDivider: { width: 1, backgroundColor: Colors.border, marginHorizontal: 8 },
  card: { backgroundColor: Colors.surface, borderRadius: BorderRadius.xxl, padding: 16, borderWidth: 1, borderColor: Colors.borderLight, gap: 12 },
  cardTitle: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary },
  durationRow: { flexDirection: 'row', gap: 8 },
  durationChip: { flex: 1, alignItems: 'center', paddingVertical: 10, borderRadius: BorderRadius.md, backgroundColor: Colors.slate50, borderWidth: 1, borderColor: Colors.border },
  durationChipActive: { backgroundColor: Colors.brandBlue, borderColor: Colors.brandBlue },
  durationText: { fontSize: FontSize.md, fontWeight: '700', color: Colors.slate600 },
  durationTextActive: { color: '#FFF' },
  dayRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: Colors.borderLight },
  dayDot: { width: 8, height: 8, borderRadius: 4 },
  dayName: { fontSize: FontSize.base, fontWeight: '700', color: Colors.textPrimary },
  dayTime: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2, marginLeft: 16 },
  slotsGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  slotChip: { width: '30%' as any, padding: 10, borderRadius: BorderRadius.md, alignItems: 'center' },
  slotAvailable: { backgroundColor: Colors.emeraldBg, borderWidth: 1, borderColor: Colors.emeraldLight },
  slotBooked: { backgroundColor: Colors.redBg, borderWidth: 1, borderColor: Colors.redLight },
  slotBreak: { backgroundColor: Colors.amberBg, borderWidth: 1, borderColor: Colors.amberLight },
  slotText: { fontSize: FontSize.sm, fontWeight: '700' },
  slotStatus: { fontSize: 9, fontWeight: '600', marginTop: 2 },
  saveBtn: { backgroundColor: Colors.brandBlue, paddingVertical: 16, borderRadius: BorderRadius.lg, alignItems: 'center' },
  saveBtnText: { color: '#FFF', fontSize: FontSize.lg, fontWeight: '700' },
});
