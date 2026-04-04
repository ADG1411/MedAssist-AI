import React, { useState } from 'react';
import {
  View, Text, TextInput, Pressable, StyleSheet, ScrollView,
  KeyboardAvoidingView, Platform, ActivityIndicator, Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import { BlurView } from 'expo-blur';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { useAppTheme } from '../src/core/theme/useTheme';
import { AppColors } from '../src/core/theme/colors';
import { useAuthStore } from '../src/core/store/authStore';

export default function LoginScreen() {
  const router = useRouter();
  const { isDark, colors } = useAppTheme();
  const signIn = useAuthStore((s) => s.signIn);

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [obscure, setObscure] = useState(true);
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    if (!email.trim() || !password) {
      Alert.alert('Error', 'Please fill out all fields');
      return;
    }
    setLoading(true);
    try {
      await signIn(email.trim(), password);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      router.replace('/(tabs)/home');
    } catch (e: any) {
      Alert.alert('Login Failed', e?.message ?? 'Invalid credentials');
    } finally {
      setLoading(false);
    }
  };

  return (
    <AppBackground>
      <KeyboardAvoidingView
        style={{ flex: 1 }}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView
          contentContainerStyle={styles.scroll}
          keyboardShouldPersistTaps="handled"
        >
          {/* Logo */}
          <View style={styles.logoWrap}>
            <View style={styles.logoCircle}>
              <Text style={styles.logoPlus}>+</Text>
            </View>
          </View>

          <Text style={[styles.title, { color: colors.textPrimary }]}>
            Welcome to MedAssist AI
          </Text>
          <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
            Securely sign in to your medical vault
          </Text>

          {/* Glass Card */}
          <BlurView
            intensity={14}
            tint={isDark ? 'dark' : 'light'}
            style={[styles.glassCard, {
              borderColor: isDark ? 'rgba(255,255,255,0.10)' : 'rgba(255,255,255,0.90)',
            }]}
          >
            {/* Email */}
            <View style={[styles.inputWrap, {
              backgroundColor: isDark ? 'rgba(255,255,255,0.05)' : '#F1F5F9',
              borderColor: isDark ? 'rgba(255,255,255,0.08)' : '#E2E8F0',
            }]}>
              <Ionicons name="mail-outline" size={18} color={isDark ? 'rgba(255,255,255,0.30)' : '#94A3B8'} />
              <TextInput
                style={[styles.input, { color: colors.textPrimary }]}
                placeholder="Email Address"
                placeholderTextColor={isDark ? 'rgba(255,255,255,0.25)' : '#94A3B8'}
                keyboardType="email-address"
                autoCapitalize="none"
                value={email}
                onChangeText={setEmail}
              />
            </View>

            {/* Password */}
            <View style={[styles.inputWrap, {
              backgroundColor: isDark ? 'rgba(255,255,255,0.05)' : '#F1F5F9',
              borderColor: isDark ? 'rgba(255,255,255,0.08)' : '#E2E8F0',
              marginTop: 14,
            }]}>
              <Ionicons name="lock-closed-outline" size={18} color={isDark ? 'rgba(255,255,255,0.30)' : '#94A3B8'} />
              <TextInput
                style={[styles.input, { color: colors.textPrimary }]}
                placeholder="Password"
                placeholderTextColor={isDark ? 'rgba(255,255,255,0.25)' : '#94A3B8'}
                secureTextEntry={obscure}
                value={password}
                onChangeText={setPassword}
              />
              <Pressable onPress={() => setObscure(!obscure)}>
                <Ionicons
                  name={obscure ? 'eye-off-outline' : 'eye-outline'}
                  size={18}
                  color={isDark ? 'rgba(255,255,255,0.30)' : '#94A3B8'}
                />
              </Pressable>
            </View>

            {/* Forgot password */}
            <Pressable style={styles.forgotWrap}>
              <Text style={styles.forgotText}>Forgot password?</Text>
            </Pressable>

            {/* Login Button */}
            <Pressable
              onPress={() => {
                Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
                handleLogin();
              }}
              disabled={loading}
            >
              <LinearGradient
                colors={['#3B82F6', '#2563EB']}
                style={styles.loginBtn}
              >
                {loading ? (
                  <ActivityIndicator size="small" color="#FFF" />
                ) : (
                  <View style={styles.loginBtnInner}>
                    <Ionicons name="shield-checkmark" size={16} color="#FFF" />
                    <Text style={styles.loginBtnText}>Secure Login</Text>
                  </View>
                )}
              </LinearGradient>
            </Pressable>
          </BlurView>

          {/* Enroll link */}
          <View style={styles.enrollRow}>
            <Text style={[styles.enrollLabel, { color: colors.textSecondary }]}>
              New patient?
            </Text>
            <Pressable onPress={() => router.push('/signup')}>
              <Text style={styles.enrollLink}> Enroll Here</Text>
            </Pressable>
          </View>

          {/* Security badge */}
          <View style={[styles.secBadge, {
            backgroundColor: isDark ? 'rgba(255,255,255,0.04)' : 'rgba(16,185,129,0.06)',
            borderColor: 'rgba(16,185,129,0.15)',
          }]}>
            <Ionicons name="shield-checkmark" size={12} color="rgba(16,185,129,0.70)" />
            <Text style={[styles.secText, {
              color: isDark ? 'rgba(255,255,255,0.30)' : 'rgba(16,185,129,0.70)',
            }]}>
              HIPAA compliant • End-to-end encrypted
            </Text>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  scroll: { flexGrow: 1, justifyContent: 'center', padding: 24 },
  logoWrap: { alignItems: 'center', marginBottom: 20 },
  logoCircle: {
    width: 80, height: 80, borderRadius: 40,
    backgroundColor: AppColors.softBlue,
    borderWidth: 2, borderColor: AppColors.primary,
    alignItems: 'center', justifyContent: 'center',
    shadowColor: '#3B82F6', shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.15, shadowRadius: 24, elevation: 8,
  },
  logoPlus: { fontSize: 40, fontWeight: '300', color: AppColors.primary, marginTop: -2 },
  title: { fontSize: 24, fontWeight: '800', textAlign: 'center', letterSpacing: -0.5 },
  subtitle: { fontSize: 13, textAlign: 'center', marginTop: 6, marginBottom: 32 },
  glassCard: {
    borderRadius: 20, padding: 24, borderWidth: 0.8, overflow: 'hidden',
    shadowColor: '#000', shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.06, shadowRadius: 24, elevation: 4,
  },
  inputWrap: {
    flexDirection: 'row', alignItems: 'center',
    borderRadius: 12, borderWidth: 0.6, paddingHorizontal: 14, height: 48,
  },
  input: { flex: 1, fontSize: 14, marginLeft: 10 },
  forgotWrap: { alignSelf: 'flex-end', marginTop: 8, marginBottom: 16 },
  forgotText: { fontSize: 12, fontWeight: '600', color: 'rgba(59,130,246,0.80)' },
  loginBtn: {
    height: 52, borderRadius: 14, alignItems: 'center', justifyContent: 'center',
    shadowColor: '#3B82F6', shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.30, shadowRadius: 12, elevation: 6,
  },
  loginBtnInner: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  loginBtnText: { fontSize: 15, fontWeight: '700', color: '#FFF' },
  enrollRow: { flexDirection: 'row', justifyContent: 'center', marginTop: 24 },
  enrollLabel: { fontSize: 13 },
  enrollLink: { fontSize: 13, fontWeight: '700', color: '#3B82F6' },
  secBadge: {
    flexDirection: 'row', alignItems: 'center', alignSelf: 'center',
    paddingHorizontal: 10, paddingVertical: 5, borderRadius: 8,
    borderWidth: 0.5, marginTop: 16, gap: 5,
  },
  secText: { fontSize: 10, fontWeight: '600' },
});
