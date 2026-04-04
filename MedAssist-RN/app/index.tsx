import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated, Easing } from 'react-native';
import { useRouter } from 'expo-router';
import Svg, { Path } from 'react-native-svg';
import { AppColors } from '../src/core/theme/colors';
import { useAuthStore } from '../src/core/store/authStore';

export default function SplashScreen() {
  const router = useRouter();
  const session = useAuthStore((s) => s.session);
  const loading = useAuthStore((s) => s.loading);

  const scale = useRef(new Animated.Value(0.8)).current;
  const opacity = useRef(new Animated.Value(0)).current;
  const textOp = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.parallel([
      Animated.spring(scale, { toValue: 1, friction: 6, useNativeDriver: true }),
      Animated.timing(opacity, { toValue: 1, duration: 600, useNativeDriver: true }),
    ]).start();
    Animated.timing(textOp, { toValue: 1, duration: 600, delay: 1000, useNativeDriver: true }).start();
  }, []);

  useEffect(() => {
    if (loading) return;
    const timer = setTimeout(() => {
      if (session) {
        router.replace('/(tabs)/home');
      } else {
        router.replace('/onboarding');
      }
    }, 2500);
    return () => clearTimeout(timer);
  }, [loading, session]);

  return (
    <View style={styles.container}>
      <Animated.View style={{ transform: [{ scale }], opacity }}>
        <View style={styles.logoCircle}>
          <Text style={styles.logoText}>+</Text>
        </View>
      </Animated.View>

      <Text style={styles.title}>MedAssist AI</Text>

      <View style={styles.ecgContainer}>
        <Svg width={200} height={60} viewBox="0 0 200 60">
          <Path
            d="M0 30 L40 30 L60 12 L80 48 L100 30 L120 30 L140 24 L160 30 L200 30"
            stroke={AppColors.primary}
            strokeWidth={3}
            strokeLinecap="round"
            strokeLinejoin="round"
            fill="none"
            opacity={0.6}
          />
        </Svg>
      </View>

      <Animated.Text style={[styles.subtitle, { opacity: textOp }]}>
        Loading your health data...
      </Animated.Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: AppColors.softBlue,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 3,
    borderColor: AppColors.primary,
  },
  logoText: {
    fontSize: 56,
    fontWeight: '300',
    color: AppColors.primary,
    marginTop: -4,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: AppColors.primary,
    marginTop: 24,
  },
  ecgContainer: {
    marginTop: 48,
  },
  subtitle: {
    marginTop: 32,
    fontSize: 14,
    color: AppColors.textSecondary,
  },
});
