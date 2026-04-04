import React from 'react';
import { View, Text, StyleSheet, Pressable } from 'react-native';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import Svg, { Circle } from 'react-native-svg';
import { GlassCard } from '../../../shared/components/GlassCard';
import { DashSectionLabel } from '../../../shared/components/DashSectionLabel';
import { useAppTheme } from '../../../core/theme/useTheme';

interface Task {
  label: string;
  category: string;
  urgency: 'High' | 'Medium' | 'Low';
  xp: number;
  impact: string;
  done: boolean;
}

interface Props { data: Record<string, any> }

function buildTasks(data: Record<string, any>): Task[] {
  const meds = (data?.medication_reminders as any[]) ?? [];
  const tasks: Task[] = [
    { label: meds[0]?.name ?? 'Morning Medication', category: 'Medication', urgency: 'High', xp: 20, impact: '+8 Recovery', done: meds[0]?.taken ?? false },
    { label: 'Log Hydration', category: 'Monitoring', urgency: 'Medium', xp: 10, impact: '+5 Health Score', done: false },
    { label: 'Vitals Check', category: 'Monitoring', urgency: 'Medium', xp: 15, impact: '+6 Recovery', done: false },
    { label: 'Walk 20 minutes', category: 'Activity', urgency: 'Low', xp: 15, impact: '+4 Health Score', done: false },
    { label: meds[1]?.name ?? 'Evening Medication', category: 'Medication', urgency: 'High', xp: 20, impact: '+8 Recovery', done: meds[1]?.taken ?? false },
    { label: 'Daily Mood Log', category: 'Wellbeing', urgency: 'Low', xp: 10, impact: '+3 AI Accuracy', done: false },
  ];
  // Sort: incomplete high→medium→low, then done
  const order = { High: 0, Medium: 1, Low: 2 };
  tasks.sort((a, b) => {
    if (a.done !== b.done) return a.done ? 1 : -1;
    return (order[a.urgency] ?? 2) - (order[b.urgency] ?? 2);
  });
  return tasks;
}

const URGENCY_COLORS = { High: '#EF4444', Medium: '#F59E0B', Low: '#3B82F6' };

export function AiDailyCareEngine({ data }: Props) {
  const { isDark, colors } = useAppTheme();
  const tasks = buildTasks(data);
  const doneCount = tasks.filter((t) => t.done).length;
  const progress = tasks.length > 0 ? doneCount / tasks.length : 0;
  const totalXp = tasks.filter((t) => t.done).reduce((s, t) => s + t.xp, 0);

  const circumference = 2 * Math.PI * 20;
  const strokeDashoffset = circumference * (1 - progress);

  return (
    <View>
      <DashSectionLabel title="🤖 AI Daily Care Engine" subtitle="Your personalized care tasks" />
      <View style={{ height: 10 }} />
      <GlassCard radius={24} blur={20} padding={18}>
        {/* Header */}
        <View style={styles.headerRow}>
          {/* Progress ring */}
          <View style={styles.ringWrap}>
            <Svg width={50} height={50} viewBox="0 0 50 50">
              <Circle cx={25} cy={25} r={20} stroke={isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)'} strokeWidth={5.5} fill="none" />
              <Circle cx={25} cy={25} r={20} stroke="#10B981" strokeWidth={5.5} fill="none"
                strokeLinecap="round" strokeDasharray={`${circumference}`} strokeDashoffset={strokeDashoffset}
                rotation={-90} origin="25,25"
              />
            </Svg>
            <View style={styles.ringCenter}>
              <Text style={[styles.ringText, { color: colors.textPrimary }]}>{doneCount}/{tasks.length}</Text>
            </View>
          </View>

          <View style={styles.headerMid}>
            <Text style={[styles.headerTitle, { color: colors.textPrimary }]}>Today's Care Plan</Text>
            <View style={styles.badgesRow}>
              {/* XP badge */}
              <View style={styles.xpBadge}>
                <Text style={styles.xpText}>⚡ {totalXp} XP</Text>
              </View>
              {/* Streak badge */}
              <View style={styles.streakBadge}>
                <Text style={styles.streakText}>🔥 3</Text>
              </View>
            </View>
          </View>

          {/* AI updated label */}
          <View style={styles.aiLabelRow}>
            <View style={styles.aiDot} />
            <Text style={[styles.aiLabelText, { color: colors.textSecondary }]}>AI updated just now</Text>
          </View>
        </View>

        <View style={{ height: 14 }} />

        {/* Task list */}
        {tasks.map((task, i) => (
          <View
            key={i}
            style={[
              styles.taskRow,
              {
                backgroundColor: task.done
                  ? (isDark ? 'rgba(16,185,129,0.06)' : 'rgba(16,185,129,0.04)')
                  : (isDark ? 'rgba(255,255,255,0.03)' : 'rgba(0,0,0,0.02)'),
                borderColor: task.done ? 'rgba(16,185,129,0.15)' : (isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.04)'),
                opacity: task.done ? 0.6 : 1,
              },
            ]}
          >
            {/* Checkbox */}
            <View style={[
              styles.checkbox,
              {
                backgroundColor: task.done ? 'rgba(16,185,129,0.14)' : (isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.04)'),
                borderColor: task.done ? '#10B981' : (isDark ? 'rgba(255,255,255,0.14)' : 'rgba(0,0,0,0.12)'),
              },
            ]}>
              {task.done && <Ionicons name="checkmark" size={14} color="#10B981" />}
            </View>

            {/* Content */}
            <View style={styles.taskContent}>
              <Text
                style={[
                  styles.taskLabel,
                  {
                    color: colors.textPrimary,
                    textDecorationLine: task.done ? 'line-through' : 'none',
                  },
                ]}
                numberOfLines={1}
              >
                {task.label}
              </Text>
              <View style={styles.taskMeta}>
                <Text style={[styles.taskCategory, { color: colors.textSecondary }]}>{task.category}</Text>
                <View style={[styles.urgLabel, { backgroundColor: `${URGENCY_COLORS[task.urgency]}10` }]}>
                  <Text style={[styles.urgText, { color: URGENCY_COLORS[task.urgency] }]}>{task.urgency}</Text>
                </View>
              </View>
            </View>

            {/* Right: XP + Impact */}
            <View style={styles.taskRight}>
              <Text style={styles.taskXp}>+{task.xp} XP</Text>
              <Text style={[styles.taskImpact, { color: '#10B981' }]}>{task.impact}</Text>
            </View>
          </View>
        ))}
      </GlassCard>
    </View>
  );
}

const styles = StyleSheet.create({
  headerRow: { flexDirection: 'row', alignItems: 'center' },
  ringWrap: { width: 50, height: 50, alignItems: 'center', justifyContent: 'center' },
  ringCenter: { position: 'absolute', alignItems: 'center', justifyContent: 'center' },
  ringText: { fontSize: 11, fontWeight: '800' },
  headerMid: { flex: 1, marginLeft: 12 },
  headerTitle: { fontSize: 14, fontWeight: '700' },
  badgesRow: { flexDirection: 'row', gap: 6, marginTop: 4 },
  xpBadge: { backgroundColor: 'rgba(99,102,241,0.12)', paddingHorizontal: 6, paddingVertical: 2, borderRadius: 6 },
  xpText: { fontSize: 9, fontWeight: '800', color: '#6366F1' },
  streakBadge: {
    paddingHorizontal: 5, paddingVertical: 2, borderRadius: 6,
    backgroundColor: '#F59E0B',
  },
  streakText: { fontSize: 9, fontWeight: '800', color: '#FFF' },
  aiLabelRow: { flexDirection: 'row', alignItems: 'center', gap: 4 },
  aiDot: { width: 5, height: 5, borderRadius: 2.5, backgroundColor: '#10B981' },
  aiLabelText: { fontSize: 9, fontWeight: '500' },
  taskRow: {
    flexDirection: 'row', alignItems: 'center',
    padding: 10, borderRadius: 12, borderWidth: 0.5, marginBottom: 6,
  },
  checkbox: {
    width: 26, height: 26, borderRadius: 13,
    borderWidth: 1.5, alignItems: 'center', justifyContent: 'center',
  },
  taskContent: { flex: 1, marginLeft: 10 },
  taskLabel: { fontSize: 13, fontWeight: '600' },
  taskMeta: { flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: 2 },
  taskCategory: { fontSize: 10, fontWeight: '500' },
  urgLabel: { paddingHorizontal: 4, paddingVertical: 1, borderRadius: 4 },
  urgText: { fontSize: 8, fontWeight: '700' },
  taskRight: { alignItems: 'flex-end' },
  taskXp: { fontSize: 10, fontWeight: '800', color: '#6366F1' },
  taskImpact: { fontSize: 9, fontWeight: '600', marginTop: 2 },
});
