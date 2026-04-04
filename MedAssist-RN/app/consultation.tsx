import React, { useState, useEffect } from 'react';
import {
  View, Text, StyleSheet, Pressable, Dimensions,
} from 'react-native';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { useAppTheme } from '../src/core/theme/useTheme';

const { width: W } = Dimensions.get('window');

export default function ConsultationScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const [elapsed, setElapsed] = useState(0);
  const [muted, setMuted] = useState(false);
  const [videoOff, setVideoOff] = useState(false);

  useEffect(() => {
    const timer = setInterval(() => setElapsed((e) => e + 1), 1000);
    return () => clearInterval(timer);
  }, []);

  const formatTime = (s: number) => {
    const m = Math.floor(s / 60);
    const sec = s % 60;
    return `${m.toString().padStart(2, '0')}:${sec.toString().padStart(2, '0')}`;
  };

  return (
    <AppBackground>
      <View style={styles.container}>
        {/* Video area */}
        <View style={[styles.videoArea, {
          backgroundColor: isDark ? '#1a1a2e' : '#E2E8F0',
        }]}>
          <View style={styles.remoteVideo}>
            <View style={[styles.avatarBig, { backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#D1D5DB' }]}>
              <Ionicons name="person" size={56} color={isDark ? 'rgba(255,255,255,0.20)' : '#9CA3AF'} />
            </View>
            <Text style={[styles.docLabel, { color: isDark ? 'rgba(255,255,255,0.60)' : '#6B7280' }]}>
              Dr. Priya Sharma
            </Text>
          </View>

          {/* Self view */}
          <View style={[styles.selfView, {
            backgroundColor: videoOff ? (isDark ? '#2a2a3e' : '#CBD5E1') : (isDark ? '#16213e' : '#94A3B8'),
            borderColor: isDark ? 'rgba(255,255,255,0.15)' : 'rgba(0,0,0,0.10)',
          }]}>
            {videoOff ? (
              <Ionicons name="videocam-off" size={20} color={isDark ? 'rgba(255,255,255,0.30)' : '#6B7280'} />
            ) : (
              <Ionicons name="person" size={20} color={isDark ? 'rgba(255,255,255,0.30)' : '#6B7280'} />
            )}
          </View>

          {/* Timer */}
          <View style={styles.timerBadge}>
            <View style={styles.liveDot} />
            <Text style={styles.timerText}>{formatTime(elapsed)}</Text>
          </View>
        </View>

        {/* Controls */}
        <View style={styles.controls}>
          <Pressable
            onPress={() => { Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light); setMuted(!muted); }}
            style={[styles.controlBtn, muted && styles.controlBtnActive]}
          >
            <Ionicons name={muted ? 'mic-off' : 'mic'} size={22} color={muted ? '#FFF' : colors.textPrimary} />
          </Pressable>

          <Pressable
            onPress={() => { Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light); setVideoOff(!videoOff); }}
            style={[styles.controlBtn, videoOff && styles.controlBtnActive]}
          >
            <Ionicons name={videoOff ? 'videocam-off' : 'videocam'} size={22} color={videoOff ? '#FFF' : colors.textPrimary} />
          </Pressable>

          <Pressable style={styles.controlBtn}>
            <Ionicons name="chatbubble-ellipses" size={22} color={colors.textPrimary} />
          </Pressable>

          <Pressable
            onPress={() => {
              Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
              router.push('/post-consult');
            }}
            style={styles.endCallBtn}
          >
            <Ionicons name="call" size={22} color="#FFF" style={{ transform: [{ rotate: '135deg' }] }} />
          </Pressable>
        </View>

        {/* Info bar */}
        <View style={[styles.infoBar, { backgroundColor: isDark ? 'rgba(255,255,255,0.04)' : 'rgba(0,0,0,0.02)' }]}>
          <Ionicons name="shield-checkmark" size={14} color="#10B981" />
          <Text style={[styles.infoText, { color: colors.textSecondary }]}>
            End-to-end encrypted · HIPAA compliant
          </Text>
        </View>
      </View>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, paddingTop: 50 },
  videoArea: {
    flex: 1, marginHorizontal: 16, borderRadius: 24, overflow: 'hidden',
    alignItems: 'center', justifyContent: 'center',
  },
  remoteVideo: { alignItems: 'center', gap: 12 },
  avatarBig: { width: 100, height: 100, borderRadius: 50, alignItems: 'center', justifyContent: 'center' },
  docLabel: { fontSize: 16, fontWeight: '600' },
  selfView: {
    position: 'absolute', bottom: 16, right: 16,
    width: 80, height: 110, borderRadius: 14, borderWidth: 2,
    alignItems: 'center', justifyContent: 'center',
  },
  timerBadge: {
    position: 'absolute', top: 16, left: 16,
    flexDirection: 'row', alignItems: 'center', gap: 6,
    backgroundColor: 'rgba(0,0,0,0.50)', paddingHorizontal: 10, paddingVertical: 5, borderRadius: 10,
  },
  liveDot: { width: 6, height: 6, borderRadius: 3, backgroundColor: '#EF4444' },
  timerText: { fontSize: 12, fontWeight: '700', color: '#FFF' },
  controls: {
    flexDirection: 'row', justifyContent: 'center', alignItems: 'center',
    gap: 16, paddingVertical: 20,
  },
  controlBtn: {
    width: 52, height: 52, borderRadius: 26,
    backgroundColor: 'rgba(0,0,0,0.06)', alignItems: 'center', justifyContent: 'center',
  },
  controlBtnActive: { backgroundColor: '#6366F1' },
  endCallBtn: {
    width: 52, height: 52, borderRadius: 26, backgroundColor: '#EF4444',
    alignItems: 'center', justifyContent: 'center',
    shadowColor: '#EF4444', shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.35, shadowRadius: 12, elevation: 6,
  },
  infoBar: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6,
    paddingVertical: 10, marginBottom: 20,
  },
  infoText: { fontSize: 11, fontWeight: '500' },
});
