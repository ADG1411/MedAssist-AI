import { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Dimensions } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import { LineChart, BarChart } from 'react-native-chart-kit';

const screenWidth = Dimensions.get('window').width - 64;
const PERIODS = ['Today', 'This Week', 'This Month'] as const;

const STATS: Record<string, any[]> = {
  'Today': [
    { label: 'Total Patients', value: '12', trend: '+2', positive: true },
    { label: 'Appointments', value: '8', trend: '+3', positive: true },
    { label: 'Completed', value: '6', trend: '+1', positive: true },
    { label: 'Earnings', value: '₹4,500', trend: '+5%', positive: true },
  ],
  'This Week': [
    { label: 'Total Patients', value: '84', trend: '+18%', positive: true },
    { label: 'Appointments', value: '42', trend: '+5', positive: true },
    { label: 'Completed', value: '38', trend: '+12%', positive: true },
    { label: 'Earnings', value: '₹28,400', trend: '+8%', positive: true },
  ],
  'This Month': [
    { label: 'Total Patients', value: '248', trend: '+12%', positive: true },
    { label: 'Appointments', value: '156', trend: '-2', positive: false },
    { label: 'Completed', value: '142', trend: '+8%', positive: true },
    { label: 'Earnings', value: '₹1,24,500', trend: '+15%', positive: true },
  ],
};

const chartConfig = {
  backgroundColor: '#FFF',
  backgroundGradientFrom: '#FFF',
  backgroundGradientTo: '#FFF',
  decimalPlaces: 0,
  color: (opacity = 1) => `rgba(26, 107, 255, ${opacity})`,
  labelColor: () => Colors.slate500,
  propsForDots: { r: '4', strokeWidth: '2', stroke: Colors.brandBlue },
};

export default function AnalyticsScreen() {
  const router = useRouter();
  const [period, setPeriod] = useState<typeof PERIODS[number]>('This Week');
  const stats = STATS[period];

  return (
    <ScrollView style={styles.container} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={22} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.pageTitle}>Analytics</Text>
      </View>

      {/* Period Selector */}
      <View style={styles.periodRow}>
        {PERIODS.map(p => (
          <TouchableOpacity key={p} style={[styles.periodChip, period === p && styles.periodChipActive]} onPress={() => setPeriod(p)}>
            <Text style={[styles.periodText, period === p && styles.periodTextActive]}>{p}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Stats Grid */}
      <View style={styles.statsGrid}>
        {stats.map((s: any) => (
          <View key={s.label} style={styles.statCard}>
            <Text style={styles.statValue}>{s.value}</Text>
            <Text style={styles.statLabel}>{s.label}</Text>
            <Text style={[styles.statTrend, { color: s.positive ? Colors.emerald : Colors.red }]}>
              {s.positive ? '↑' : '↓'} {s.trend}
            </Text>
          </View>
        ))}
      </View>

      {/* Patient Growth Chart */}
      <View style={styles.chartCard}>
        <Text style={styles.chartTitle}>📈 Patient Volume</Text>
        <LineChart
          data={{
            labels: period === 'Today' ? ['9AM', '11AM', '1PM', '3PM', '5PM'] : period === 'This Week' ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'] : ['W1', 'W2', 'W3', 'W4'],
            datasets: [
              { data: period === 'Today' ? [2, 4, 1, 3, 2] : period === 'This Week' ? [12, 15, 18, 14, 16, 9] : [42, 55, 48, 63], color: () => Colors.brandBlue },
              { data: period === 'Today' ? [1, 2, 3, 1, 2] : period === 'This Week' ? [10, 12, 14, 15, 13, 8] : [38, 45, 50, 52], color: () => Colors.slate300 },
            ],
            legend: ['Current', 'Previous'],
          }}
          width={screenWidth}
          height={220}
          chartConfig={chartConfig}
          bezier
          style={styles.chart}
        />
      </View>

      {/* Revenue Chart */}
      <View style={styles.chartCard}>
        <Text style={styles.chartTitle}>💰 Revenue Breakdown</Text>
        <BarChart
          data={{
            labels: period === 'Today' ? ['Morning', 'Afternoon', 'Evening'] : period === 'This Week' ? ['Mon', 'Wed', 'Fri', 'Sun'] : ['W1', 'W2', 'W3', 'W4'],
            datasets: [{ data: period === 'Today' ? [3200, 2000, 4500] : period === 'This Week' ? [10000, 12000, 13000, 6000] : [45000, 48000, 53000, 59000] }],
          }}
          width={screenWidth}
          height={220}
          chartConfig={{ ...chartConfig, color: (o = 1) => `rgba(16, 185, 129, ${o})` }}
          style={styles.chart}
          yAxisLabel="₹"
          yAxisSuffix=""
        />
      </View>

      {/* AI Insights */}
      <View style={styles.insightCard}>
        <View style={styles.insightHeader}>
          <Ionicons name="sparkles" size={18} color={Colors.purple} />
          <Text style={styles.insightTitle}>AI Insights</Text>
        </View>
        {[
          { type: 'trend', title: 'Patient Volume Increasing', desc: 'Your patient volume has grown 12% this month. Morning slots have highest demand.', action: 'Extend morning hours' },
          { type: 'schedule', title: 'Optimize Gaps', desc: '18-min average gap between appointments. Reducing to 10 min adds 2 more daily slots.', action: 'Review schedule' },
          { type: 'alert', title: 'Follow-up Compliance Low', desc: '34% of patients missed follow-up appointments this month.', action: 'Enable reminders' },
        ].map((insight, i) => (
          <View key={i} style={styles.insightItem}>
            <Ionicons name={insight.type === 'trend' ? 'trending-up' : insight.type === 'schedule' ? 'calendar' : 'alert-circle'} size={18}
              color={insight.type === 'trend' ? Colors.emerald : insight.type === 'schedule' ? Colors.brandBlue : Colors.amber} />
            <View style={{ flex: 1 }}>
              <Text style={styles.insightItemTitle}>{insight.title}</Text>
              <Text style={styles.insightItemDesc}>{insight.desc}</Text>
              {insight.action && (
                <TouchableOpacity style={styles.insightAction}>
                  <Text style={styles.insightActionText}>{insight.action}</Text>
                </TouchableOpacity>
              )}
            </View>
          </View>
        ))}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.background },
  header: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingTop: 56, paddingBottom: 12 },
  backBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: Colors.surface, justifyContent: 'center', alignItems: 'center', borderWidth: 1, borderColor: Colors.border },
  pageTitle: { fontSize: FontSize.h1, fontWeight: '900', color: Colors.textPrimary },
  periodRow: { flexDirection: 'row', marginHorizontal: 16, backgroundColor: Colors.surface, borderRadius: BorderRadius.lg, padding: 4, borderWidth: 1, borderColor: Colors.border, marginBottom: 16 },
  periodChip: { flex: 1, alignItems: 'center', paddingVertical: 10, borderRadius: BorderRadius.md },
  periodChipActive: { backgroundColor: Colors.brandBlue },
  periodText: { fontSize: FontSize.sm, fontWeight: '700', color: Colors.slate600 },
  periodTextActive: { color: '#FFF' },
  statsGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10, paddingHorizontal: 16, marginBottom: 16 },
  statCard: { width: '47%' as any, backgroundColor: Colors.surface, borderRadius: BorderRadius.lg, padding: 14, borderWidth: 1, borderColor: Colors.borderLight },
  statValue: { fontSize: FontSize.xxl, fontWeight: '900', color: Colors.textPrimary },
  statLabel: { fontSize: FontSize.xs, fontWeight: '700', color: Colors.textSecondary, textTransform: 'uppercase', marginTop: 2 },
  statTrend: { fontSize: FontSize.sm, fontWeight: '700', marginTop: 4 },
  chartCard: { backgroundColor: Colors.surface, marginHorizontal: 16, borderRadius: BorderRadius.xxl, padding: 16, marginBottom: 16, borderWidth: 1, borderColor: Colors.borderLight },
  chartTitle: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary, marginBottom: 12 },
  chart: { borderRadius: 12, marginLeft: -8 },
  insightCard: { backgroundColor: Colors.surface, marginHorizontal: 16, borderRadius: BorderRadius.xxl, padding: 16, borderWidth: 1, borderColor: Colors.purpleLight },
  insightHeader: { flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 16 },
  insightTitle: { fontSize: FontSize.lg, fontWeight: '800', color: Colors.textPrimary },
  insightItem: { flexDirection: 'row', gap: 12, marginBottom: 16, alignItems: 'flex-start' },
  insightItemTitle: { fontSize: FontSize.md, fontWeight: '700', color: Colors.textPrimary },
  insightItemDesc: { fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2, lineHeight: 18 },
  insightAction: { marginTop: 6, backgroundColor: Colors.blueBg, paddingHorizontal: 12, paddingVertical: 6, borderRadius: 8, alignSelf: 'flex-start' },
  insightActionText: { fontSize: FontSize.xs, fontWeight: '700', color: Colors.brandBlue },
});
