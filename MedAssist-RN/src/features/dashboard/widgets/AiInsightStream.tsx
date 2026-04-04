import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { GlassCard } from '../../../shared/components/GlassCard';
import { DashSectionLabel } from '../../../shared/components/DashSectionLabel';
import { useAppTheme } from '../../../core/theme/useTheme';

interface Insight {
  tag: string;
  icon: string;
  color: string;
  prediction: string;
  action: string;
  outcome: string;
  confidence: number;
  eta: string;
  escalate: boolean;
  cta: string;
}

interface Props { data: Record<string, any> }

function buildInsights(data: Record<string, any>): Insight[] {
  const aiResult = data?.latest_ai_result;
  return [
    {
      tag: 'Risk Forecast', icon: 'trending-up', color: '#F59E0B',
      prediction: aiResult?.condition
        ? `${aiResult.condition} risk may elevate within 48h based on symptom patterns`
        : 'Mild dehydration risk detected from low fluid intake',
      action: 'Increase water intake to 8+ glasses and monitor symptoms',
      outcome: 'Expected 15% risk reduction within 24 hours',
      confidence: aiResult?.confidence ?? 78, eta: '24h', escalate: false, cta: 'Track Now',
    },
    {
      tag: 'Sleep Risk', icon: 'moon', color: '#8B5CF6',
      prediction: 'Sleep deficit accumulating — 3rd night under 7h',
      action: 'Set a 10:30 PM wind-down alarm and avoid screens',
      outcome: 'Projected recovery improvement of 12% with better sleep',
      confidence: 85, eta: '3 days', escalate: false, cta: 'Set Alarm',
    },
    {
      tag: 'Recovery ETA', icon: 'fitness', color: '#10B981',
      prediction: 'Current trajectory suggests full recovery by day 14',
      action: 'Continue medication schedule and daily monitoring',
      outcome: 'On track for milestone unlock at 80 recovery points',
      confidence: 88, eta: '5 days', escalate: false, cta: 'View Plan',
    },
    {
      tag: 'Preventive Alert', icon: 'shield-checkmark', color: '#EF4444',
      prediction: 'Blood pressure trending upward over past 3 readings',
      action: 'Reduce sodium intake and schedule a vitals check',
      outcome: 'Early intervention can prevent a clinical escalation',
      confidence: 72, eta: '48h', escalate: true, cta: 'See Doctor',
    },
  ];
}

function StoryStep({ label, icon, color, text, textColor }: {
  label: string; icon: string; color: string; text: string; textColor: string;
}) {
  return (
    <View style={styles.stepRow}>
      <View style={[styles.stepDot, { backgroundColor: `${color}18` }]}>
        <Ionicons name={icon as any} size={11} color={color} />
      </View>
      <View style={styles.stepContent}>
        <Text style={[styles.stepLabel, { color }]}>{label}</Text>
        <Text style={[styles.stepText, { color: textColor }]}>{text}</Text>
      </View>
    </View>
  );
}

export function AiInsightStream({ data }: Props) {
  const { isDark, colors } = useAppTheme();
  const insights = buildInsights(data);

  return (
    <View>
      <DashSectionLabel title="🧠 AI Insight Stream" subtitle="Prediction → Action → Outcome" />
      <View style={{ height: 10 }} />
      {insights.map((ins, i) => (
        <View key={i} style={{ marginBottom: 10 }}>
          <GlassCard radius={20} blur={18} padding={16}>
            {/* Header */}
            <View style={styles.headerRow}>
              <View style={[styles.tagChip, { backgroundColor: `${ins.color}14` }]}>
                <Ionicons name={ins.icon as any} size={12} color={ins.color} />
                <Text style={[styles.tagText, { color: ins.color }]}>{ins.tag}</Text>
              </View>
              <View style={styles.headerRight}>
                <Text style={[styles.confText, { color: colors.textSecondary }]}>
                  {ins.confidence}% conf
                </Text>
                <View style={[styles.etaChip, { backgroundColor: `${ins.color}10` }]}>
                  <Ionicons name="time-outline" size={9} color={ins.color} />
                  <Text style={[styles.etaText, { color: ins.color }]}>{ins.eta}</Text>
                </View>
                {ins.escalate && (
                  <View style={styles.escalateBadge}>
                    <Text style={styles.escalateText}>See Doctor</Text>
                  </View>
                )}
              </View>
            </View>

            <View style={{ height: 10 }} />

            {/* Story steps */}
            <StoryStep label="PREDICTION" icon="bulb-outline" color={ins.color} text={ins.prediction} textColor={colors.textPrimary} />
            <View style={{ height: 8 }} />
            <StoryStep label="ACTION" icon="play-circle-outline" color="#6366F1" text={ins.action} textColor={colors.textPrimary} />
            <View style={{ height: 8 }} />
            <StoryStep label="OUTCOME" icon="trophy-outline" color="#10B981" text={ins.outcome} textColor={colors.textPrimary} />

            {/* CTA */}
            <View style={[styles.ctaBtn, { backgroundColor: `${ins.color}12`, borderColor: `${ins.color}25` }]}>
              <Text style={[styles.ctaText, { color: ins.color }]}>{ins.cta}</Text>
              <Ionicons name="arrow-forward" size={12} color={ins.color} />
            </View>
          </GlassCard>
        </View>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  headerRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  tagChip: { flexDirection: 'row', alignItems: 'center', gap: 4, paddingHorizontal: 8, paddingVertical: 4, borderRadius: 8 },
  tagText: { fontSize: 11, fontWeight: '700' },
  headerRight: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  confText: { fontSize: 9, fontWeight: '600' },
  etaChip: { flexDirection: 'row', alignItems: 'center', gap: 3, paddingHorizontal: 5, paddingVertical: 2, borderRadius: 5 },
  etaText: { fontSize: 8, fontWeight: '700' },
  escalateBadge: { backgroundColor: 'rgba(239,68,68,0.12)', paddingHorizontal: 5, paddingVertical: 2, borderRadius: 5 },
  escalateText: { fontSize: 8, fontWeight: '800', color: '#EF4444' },
  stepRow: { flexDirection: 'row', alignItems: 'flex-start', gap: 8 },
  stepDot: { width: 22, height: 22, borderRadius: 11, alignItems: 'center', justifyContent: 'center', marginTop: 1 },
  stepContent: { flex: 1 },
  stepLabel: { fontSize: 8, fontWeight: '800', letterSpacing: 0.5, marginBottom: 2 },
  stepText: { fontSize: 12, lineHeight: 17 },
  ctaBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6,
    marginTop: 12, paddingVertical: 8, borderRadius: 10, borderWidth: 0.5,
  },
  ctaText: { fontSize: 12, fontWeight: '700' },
});
