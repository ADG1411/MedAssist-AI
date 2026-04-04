import { useState } from 'react';
import {
  View, Text, TextInput, TouchableOpacity, StyleSheet, ScrollView,
  KeyboardAvoidingView, Platform, Image, ActivityIndicator, Alert
} from 'react-native';
import { useRouter, Link } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius, Spacing } from '../../constants/Colors';
import { authService } from '../../services/authService';

export default function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const router = useRouter();

  const handleLogin = async () => {
    setLoading(true);
    setErrorMsg('');

    // Dev bypass
    if (email === 'test' || password === 'test') {
      router.replace('/(dashboard)');
      return;
    }

    const { error } = await authService.login(email, password);
    setLoading(false);

    if (error) {
      setErrorMsg(error.message);
    } else {
      router.replace('/(dashboard)');
    }
  };

  const handleGoogleLogin = async () => {
    const { error } = await authService.signInWithGoogle();
    if (error) Alert.alert('Error', error.message);
  };

  return (
    <KeyboardAvoidingView style={styles.container} behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        {/* Logo */}
        <View style={styles.logoSection}>
          <View style={styles.logoCircle}>
            <Ionicons name="medical" size={40} color={Colors.brandBlue} />
          </View>
          <Text style={styles.logoText}>MedAssist</Text>
        </View>

        {/* Title */}
        <View style={styles.titleSection}>
          <Text style={styles.title}>Welcome Back!</Text>
          <Text style={styles.subtitle}>Ready to manage your practice? Log in now!</Text>
        </View>

        {/* Error */}
        {errorMsg !== '' && (
          <View style={styles.errorBox}>
            <Ionicons name="alert-circle" size={16} color={Colors.red} />
            <Text style={styles.errorText}>{errorMsg}</Text>
          </View>
        )}

        {/* Email Input */}
        <View style={styles.inputGroup}>
          <Text style={styles.label}>Email</Text>
          <View style={styles.inputWrapper}>
            <Ionicons name="mail-outline" size={20} color={Colors.slate400} style={styles.inputIcon} />
            <TextInput
              style={styles.input}
              placeholder="Enter your email"
              placeholderTextColor={Colors.slate400}
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
            />
          </View>
        </View>

        {/* Password Input */}
        <View style={styles.inputGroup}>
          <Text style={styles.label}>Password</Text>
          <View style={styles.inputWrapper}>
            <Ionicons name="lock-closed-outline" size={20} color={Colors.slate400} style={styles.inputIcon} />
            <TextInput
              style={styles.input}
              placeholder="Enter your password"
              placeholderTextColor={Colors.slate400}
              value={password}
              onChangeText={setPassword}
              secureTextEntry={!showPassword}
            />
            <TouchableOpacity onPress={() => setShowPassword(!showPassword)} style={styles.eyeBtn}>
              <Ionicons name={showPassword ? 'eye-off-outline' : 'eye-outline'} size={20} color={Colors.slate400} />
            </TouchableOpacity>
          </View>
        </View>

        {/* Forgot Password */}
        <TouchableOpacity style={styles.forgotRow}>
          <Text style={styles.forgotText}>Forgot password?</Text>
        </TouchableOpacity>

        {/* Login Button */}
        <TouchableOpacity style={styles.loginBtn} onPress={handleLogin} disabled={loading} activeOpacity={0.8}>
          {loading ? (
            <ActivityIndicator color={Colors.textWhite} />
          ) : (
            <Text style={styles.loginBtnText}>Login</Text>
          )}
        </TouchableOpacity>

        {/* Divider */}
        <View style={styles.divider}>
          <View style={styles.dividerLine} />
          <Text style={styles.dividerText}>Or</Text>
          <View style={styles.dividerLine} />
        </View>

        {/* Social Logins */}
        <View style={styles.socialRow}>
          <TouchableOpacity style={styles.socialBtn} onPress={handleGoogleLogin}>
            <Ionicons name="logo-google" size={22} color="#DB4437" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.socialBtn} onPress={() => authService.signInWithApple()}>
            <Ionicons name="logo-apple" size={22} color="#000" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.socialBtn}>
            <Ionicons name="logo-facebook" size={22} color="#1877F2" />
          </TouchableOpacity>
        </View>

        {/* Footer */}
        <View style={styles.footer}>
          <Text style={styles.footerText}>Don't have an account? </Text>
          <Link href="/(auth)/signup" asChild>
            <TouchableOpacity>
              <Text style={styles.footerLink}>Sign Up</Text>
            </TouchableOpacity>
          </Link>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#EBF4FE' },
  scroll: { flexGrow: 1, paddingHorizontal: 28, paddingTop: 60, paddingBottom: 40 },
  logoSection: { alignItems: 'center', marginBottom: 40 },
  logoCircle: {
    width: 80, height: 80, borderRadius: 40, backgroundColor: Colors.blueLight,
    justifyContent: 'center', alignItems: 'center', marginBottom: 12,
    shadowColor: Colors.brandBlue, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.15, shadowRadius: 12, elevation: 6,
  },
  logoText: { fontSize: 36, fontWeight: '800', color: Colors.textPrimary, letterSpacing: -1 },
  titleSection: { alignItems: 'center', marginBottom: 32 },
  title: { fontSize: FontSize.h1, fontWeight: '800', color: Colors.textPrimary, marginBottom: 8 },
  subtitle: { fontSize: FontSize.base, color: Colors.textSecondary, fontWeight: '500' },
  errorBox: {
    flexDirection: 'row', alignItems: 'center', gap: 8,
    backgroundColor: Colors.redBg, borderWidth: 1, borderColor: Colors.redLight,
    padding: 12, borderRadius: BorderRadius.md, marginBottom: 16,
  },
  errorText: { color: Colors.red, fontSize: FontSize.sm, flex: 1, fontWeight: '500' },
  inputGroup: { marginBottom: 16 },
  label: { fontSize: FontSize.base, fontWeight: '600', color: Colors.textPrimary, marginBottom: 8, paddingLeft: 4 },
  inputWrapper: {
    flexDirection: 'row', alignItems: 'center', backgroundColor: Colors.surface,
    borderRadius: BorderRadius.lg, borderWidth: 1.5, borderColor: Colors.border,
    paddingHorizontal: 16, height: 56,
  },
  inputIcon: { marginRight: 12 },
  input: { flex: 1, fontSize: FontSize.lg, color: Colors.textPrimary, fontWeight: '500' },
  eyeBtn: { padding: 8 },
  forgotRow: { alignSelf: 'flex-end', marginBottom: 24 },
  forgotText: { color: '#EA580C', fontSize: FontSize.md, fontWeight: '600' },
  loginBtn: {
    backgroundColor: Colors.brandBlue, height: 56, borderRadius: 28,
    justifyContent: 'center', alignItems: 'center',
    shadowColor: Colors.brandBlue, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.3, shadowRadius: 12, elevation: 8,
  },
  loginBtnText: { color: Colors.textWhite, fontSize: FontSize.lg, fontWeight: '700' },
  divider: { flexDirection: 'row', alignItems: 'center', marginVertical: 28 },
  dividerLine: { flex: 1, height: 1, backgroundColor: Colors.slate300 },
  dividerText: { paddingHorizontal: 16, color: Colors.textSecondary, fontSize: FontSize.base, fontWeight: '600' },
  socialRow: { flexDirection: 'row', justifyContent: 'center', gap: 20, marginBottom: 32 },
  socialBtn: {
    width: 52, height: 52, borderRadius: 26, backgroundColor: Colors.surface,
    borderWidth: 1, borderColor: Colors.border, justifyContent: 'center', alignItems: 'center',
    shadowColor: Colors.shadowColor, shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.05, shadowRadius: 4, elevation: 2,
  },
  footer: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', paddingTop: 16 },
  footerText: { color: Colors.textSecondary, fontSize: FontSize.base, fontWeight: '500' },
  footerLink: { color: Colors.brandBlue, fontSize: FontSize.base, fontWeight: '700' },
});
