import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Pressable, Animated, Easing } from 'react-native';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { GlassCard } from '../../../shared/components/GlassCard';
import { useAppTheme } from '../../../core/theme/useTheme';

interface Props { data: Record<string, any> }

export function FloatingGlassHeader({ data }: Props) {
  const { isDark, colors } = useAppTheme();
  const pulse = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(pulse, { toValue: 1, duration: 1400, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
        Animated.timing(pulse, { toValue: 0, duration: 1400, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
      ])
    ).start();
  }, []);

  const dotOpacity = pulse.interpolate({ inputRange: [0, 1], outputRange: [0.4, 1] });
  const dotScale = pulse.interpolate({ inputRange: [0, 1], outputRange: [0.8, 1.2] });

  const hour = new Date().getHours();
  const greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
  const name = (data?.profile as any)?.full_name?.split(' ')[0] ?? 'Patient';
  const today = new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric' });

  return (
    <GlassCard radius={20} blur={18} padding={16}>
      <View style={styles.row}>
        {/* Avatar */}
        <View style={[styles.avatar, { backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#EAF3FF' }]}>
          <Text style={styles.avatarText}>{name[0]?.toUpperCase() ?? 'P'}</Text>
        </View>

        <View style={styles.textCol}>
          <View style={styles.greetRow}>
            <Text style={[styles.greeting, { color: colors.textPrimary }]}>
              {greeting}, {name}
            </Text>
            <Animated.View style={[styles.pulseDot, { opacity: dotOpacity, transform: [{ scale: dotScale }] }]} />
          </View>
          <Text style={[styles.date, { color: colors.textSecondary }]}>{today}</Text>
        </View>

        <Pressable style={[styles.bellWrap, { backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.04)' }]}>
          <Ionicons name="notifications-outline" size={20} color={colors.textSecondary} />
          <View style={styles.badge} />
        </Pressable>
      </View>
    </GlassCard>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center' },
  avatar: {
    width: 44, height: 44, borderRadius: 22,
    alignItems: 'center', justifyContent: 'center',
  },
  avatarText: { fontSize: 18, fontWeight: '700', color: '#2A7FFF' },
  textCol: { flex: 1, marginLeft: 12 },
  greetRow: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  greeting: { fontSize: 16, fontWeight: '700' },
  pulseDot: { width: 7, height: 7, borderRadius: 3.5, backgroundColor: '#10B981' },
  date: { fontSize: 12, marginTop: 2 },
  bellWrap: {
    width: 38, height: 38, borderRadius: 12,
    alignItems: 'center', justifyContent: 'center',
  },
  badge: {
    position: 'absolute', top: 8, right: 8,
    width: 6, height: 6, borderRadius: 3,
    backgroundColor: '#EF4444',
  },
});
