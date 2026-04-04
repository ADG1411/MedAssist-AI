import React, { useState, useEffect, useRef } from 'react';
import {
  View, Text, StyleSheet, Pressable, Linking, Alert, Animated, Easing,
} from 'react-native';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const EMERGENCY_CONTACTS = [
  { name: 'Emergency Services', number: '112', icon: 'call', color: '#EF4444' },
  { name: 'Ambulance', number: '108', icon: 'medkit', color: '#EF4444' },
  { name: 'Dr. Priya Sharma', number: '+91-9876543210', icon: 'person', color: '#3B82F6' },
];

export default function SosScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();

  const pulse = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(pulse, { toValue: 1, duration: 1000, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
        Animated.timing(pulse, { toValue: 0, duration: 1000, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
      ])
    ).start();
  }, []);

  const pulseScale = pulse.interpolate({ inputRange: [0, 1], outputRange: [1, 1.3] });
  const pulseOpacity = pulse.interpolate({ inputRange: [0, 1], outputRange: [0.6, 0.15] });

  const callNumber = (number: string) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
    Linking.openURL(`tel:${number}`).catch(() => {
      Alert.alert('Error', 'Unable to make a call from this device');
    });
  };

  return (
    <AppBackground>
      <View style={styles.container}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="close" size={24} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Emergency SOS</Text>
        </View>

        {/* SOS Button */}
        <View style={styles.sosWrap}>
          <Animated.View style={[styles.sosRing1, { transform: [{ scale: pulseScale }], opacity: pulseOpacity }]} />
          <Animated.View style={[styles.sosRing2, { opacity: pulseOpacity }]} />
          <Pressable
            onPress={() => callNumber('112')}
            onLongPress={() => {
              Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
              callNumber('112');
            }}
            style={styles.sosButton}
          >
            <Text style={styles.sosText}>SOS</Text>
            <Text style={styles.sosSubText}>Hold to call</Text>
          </Pressable>
        </View>

        <Text style={[styles.helpText, { color: colors.textSecondary }]}>
          Press the SOS button to call emergency services immediately
        </Text>

        {/* Emergency contacts */}
        <Text style={[styles.contactsTitle, { color: colors.textPrimary }]}>Quick Contacts</Text>
        {EMERGENCY_CONTACTS.map((contact, i) => (
          <Pressable key={i} onPress={() => callNumber(contact.number)}>
            <GlassCard radius={16} blur={14} padding={14} style={{ marginBottom: 8 }}>
              <View style={styles.contactRow}>
                <View style={[styles.contactIcon, { backgroundColor: `${contact.color}14` }]}>
                  <Ionicons name={contact.icon as any} size={20} color={contact.color} />
                </View>
                <View style={styles.contactInfo}>
                  <Text style={[styles.contactName, { color: colors.textPrimary }]}>{contact.name}</Text>
                  <Text style={[styles.contactNumber, { color: colors.textSecondary }]}>{contact.number}</Text>
                </View>
                <View style={[styles.callBtn, { backgroundColor: `${contact.color}14` }]}>
                  <Ionicons name="call" size={18} color={contact.color} />
                </View>
              </View>
            </GlassCard>
          </Pressable>
        ))}

        {/* Hospitals link */}
        <Pressable
          onPress={() => router.push('/hospitals')}
          style={[styles.hospitalsBtn, { backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : '#F1F5F9' }]}
        >
          <Ionicons name="location" size={18} color="#2A7FFF" />
          <Text style={styles.hospitalsBtnText}>Find Nearby Hospitals</Text>
        </Pressable>
      </View>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, paddingHorizontal: 16, paddingTop: 60 },
  headerRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginBottom: 24 },
  backBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 22, fontWeight: '800' },
  sosWrap: { alignItems: 'center', justifyContent: 'center', height: 200, marginBottom: 16 },
  sosRing1: {
    position: 'absolute', width: 180, height: 180, borderRadius: 90,
    backgroundColor: 'rgba(239,68,68,0.15)',
  },
  sosRing2: {
    position: 'absolute', width: 140, height: 140, borderRadius: 70,
    backgroundColor: 'rgba(239,68,68,0.25)',
  },
  sosButton: {
    width: 110, height: 110, borderRadius: 55,
    backgroundColor: '#EF4444', alignItems: 'center', justifyContent: 'center',
    shadowColor: '#EF4444', shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.5, shadowRadius: 20, elevation: 12,
  },
  sosText: { fontSize: 28, fontWeight: '900', color: '#FFF', letterSpacing: 1 },
  sosSubText: { fontSize: 9, color: 'rgba(255,255,255,0.70)', fontWeight: '600', marginTop: 2 },
  helpText: { textAlign: 'center', fontSize: 13, marginBottom: 24 },
  contactsTitle: { fontSize: 16, fontWeight: '700', marginBottom: 10 },
  contactRow: { flexDirection: 'row', alignItems: 'center' },
  contactIcon: { width: 42, height: 42, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  contactInfo: { flex: 1, marginLeft: 12 },
  contactName: { fontSize: 14, fontWeight: '600' },
  contactNumber: { fontSize: 12, marginTop: 2 },
  callBtn: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  hospitalsBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    height: 48, borderRadius: 14, marginTop: 16,
  },
  hospitalsBtnText: { fontSize: 14, fontWeight: '600', color: '#2A7FFF' },
});
