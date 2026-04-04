import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { GlassCard } from '../../../shared/components/GlassCard';
import { DashSectionLabel } from '../../../shared/components/DashSectionLabel';
import { useAppTheme } from '../../../core/theme/useTheme';

interface TimelineEvent {
  time: string;
  title: string;
  sub: string;
  icon: string;
  color: string;
  done: boolean;
  hourApprox: number;
}

interface Props { data: Record<string, any> }

function buildEvents(data: Record<string, any>): TimelineEvent[] {
  const meds = (data?.medication_reminders as any[]) ?? [];
  const appts = (data?.upcoming_appointments as any[]) ?? [];

  const events: TimelineEvent[] = [
    {
      time: '08:00 AM', title: meds[0]?.name ?? 'Morning Medication',
      sub: 'Take with a full glass of water', icon: 'medkit', color: '#10B981',
      done: meds[0]?.taken ?? false, hourApprox: 8,
    },
    {
      time: '12:00 PM', title: 'Vitals Check',
      sub: 'Log hydration & symptoms', icon: 'pulse', color: '#06B6D4',
      done: false, hourApprox: 12,
    },
  ];

  if (appts.length > 0) {
    events.push({
      time: appts[0]?.time ?? 'Tomorrow', title: appts[0]?.doctor ?? 'Doctor Appointment',
      sub: appts[0]?.type ?? 'Follow-up visit', icon: 'medical', color: '#6366F1',
      done: false, hourApprox: 15,
    });
  }

  if (meds.length > 1) {
    events.push({
      time: '08:00 PM', title: meds[1]?.name ?? 'Evening Medication',
      sub: 'Evening dose', icon: 'medkit', color: '#F59E0B',
      done: meds[1]?.taken ?? false, hourApprox: 20,
    });
  }

  events.push({
    time: '10:30 PM', title: 'Sleep Target',
    sub: 'Aim for 8 hrs of quality sleep', icon: 'moon', color: '#8B5CF6',
    done: false, hourApprox: 22,
  });

  return events;
}

function NowMarker() {
  return (
    <View style={styles.nowRow}>
      <View style={{ width: 64 }} />
      <View style={styles.nowDot} />
      <View style={styles.nowLine} />
      <View style={styles.nowBadge}>
        <Text style={styles.nowText}>NOW</Text>
      </View>
    </View>
  );
}

export function HealthTimelineStepper({ data }: Props) {
  const { isDark, colors } = useAppTheme();
  const events = buildEvents(data);
  const nowHour = new Date().getHours();

  let nowIdx = events.length;
  for (let i = 0; i < events.length; i++) {
    if (!events[i].done && events[i].hourApprox >= nowHour) {
      nowIdx = i;
      break;
    }
  }

  return (
    <View>
      <DashSectionLabel title="📅 Health Timeline" subtitle="Today & upcoming" />
      <View style={{ height: 10 }} />
      <GlassCard radius={24} blur={20} padding={16}>
        {events.map((ev, i) => {
          const isOverdue = !ev.done && ev.hourApprox < nowHour;
          const isLast = i === events.length - 1;
          return (
            <React.Fragment key={i}>
              {i === nowIdx && <NowMarker />}
              <View style={{ opacity: ev.done ? 0.5 : 1 }}>
                <View style={styles.eventRow}>
                  {/* Time */}
                  <View style={styles.timeCol}>
                    <Text style={[styles.timeText, {
                      color: isOverdue ? 'rgba(239,68,68,0.70)' : colors.textSecondary,
                    }]}>{ev.time}</Text>
                  </View>
                  {/* Dot + line */}
                  <View style={styles.dotCol}>
                    <View style={[
                      styles.dotCircle,
                      {
                        backgroundColor: ev.done ? `${ev.color}22` : (isOverdue ? 'rgba(239,68,68,0.12)' : `${ev.color}18`),
                        borderColor: ev.done ? ev.color : (isOverdue ? 'rgba(239,68,68,0.50)' : `${ev.color}55`),
                      },
                    ]}>
                      <Ionicons
                        name={ev.done ? 'checkmark' : (ev.icon as any)}
                        size={13}
                        color={ev.done ? ev.color : (isOverdue ? '#EF4444' : ev.color)}
                      />
                    </View>
                    {!isLast && (
                      <View style={[styles.vertLine, {
                        backgroundColor: isDark ? 'rgba(255,255,255,0.07)' : 'rgba(0,0,0,0.07)',
                      }]} />
                    )}
                  </View>
                  {/* Content */}
                  <View style={styles.contentCol}>
                    <View style={styles.titleRow}>
                      <Text
                        style={[
                          styles.eventTitle,
                          {
                            color: ev.done ? colors.textSecondary : (isOverdue ? '#EF4444' : colors.textPrimary),
                            textDecorationLine: ev.done ? 'line-through' : 'none',
                          },
                        ]}
                        numberOfLines={1}
                      >
                        {ev.title}
                      </Text>
                      {isOverdue && !ev.done && (
                        <View style={styles.overdueBadge}>
                          <Text style={styles.overdueText}>OVERDUE</Text>
                        </View>
                      )}
                      {ev.done && <Ionicons name="checkmark-circle" size={14} color="#10B981" />}
                    </View>
                    <Text style={[styles.eventSub, { color: colors.textSecondary }]}>{ev.sub}</Text>
                  </View>
                </View>
              </View>
            </React.Fragment>
          );
        })}
        {nowIdx === events.length && <NowMarker />}
      </GlassCard>
    </View>
  );
}

const styles = StyleSheet.create({
  nowRow: { flexDirection: 'row', alignItems: 'center', marginVertical: 4 },
  nowDot: {
    width: 8, height: 8, borderRadius: 4, backgroundColor: '#EF4444',
    shadowColor: '#EF4444', shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.4, shadowRadius: 6, elevation: 4,
  },
  nowLine: { flex: 1, height: 1.5, marginLeft: 4, backgroundColor: '#EF4444', opacity: 0.5 },
  nowBadge: {
    marginLeft: 4, paddingHorizontal: 6, paddingVertical: 2, borderRadius: 6,
    backgroundColor: 'rgba(239,68,68,0.12)',
  },
  nowText: { fontSize: 8, fontWeight: '800', color: '#EF4444', letterSpacing: 0.5 },
  eventRow: { flexDirection: 'row', alignItems: 'flex-start' },
  timeCol: { width: 64, paddingTop: 13 },
  timeText: { fontSize: 10, fontWeight: '600' },
  dotCol: { alignItems: 'center' },
  dotCircle: {
    width: 28, height: 28, borderRadius: 14, borderWidth: 1.5,
    alignItems: 'center', justifyContent: 'center', marginTop: 8,
  },
  vertLine: { width: 1.5, flex: 1, minHeight: 20, marginVertical: 4 },
  contentCol: { flex: 1, marginLeft: 12, paddingTop: 10, paddingBottom: 14 },
  titleRow: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  eventTitle: { fontSize: 13, fontWeight: '600', flex: 1 },
  overdueBadge: { backgroundColor: 'rgba(239,68,68,0.10)', paddingHorizontal: 5, paddingVertical: 2, borderRadius: 5 },
  overdueText: { fontSize: 7, fontWeight: '800', color: '#EF4444', letterSpacing: 0.4 },
  eventSub: { fontSize: 11, marginTop: 2 },
});
