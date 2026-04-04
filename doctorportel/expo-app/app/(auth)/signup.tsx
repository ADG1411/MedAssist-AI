import { useState } from 'react';
import {
  View, Text, TextInput, TouchableOpacity, StyleSheet, ScrollView,
  KeyboardAvoidingView, Platform, ActivityIndicator
} from 'react-native';
import { useRouter, Link } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Colors, FontSize, BorderRadius } from '../../constants/Colors';
import { authService } from '../../services/authService';

export default function SignupScreen() {
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [success, setSuccess] = useState(false);
  const router = useRouter();

  const handleSignup = async () => {
    if (!fullName || !email || !password) {
      setErrorMsg('Please fill all fields');
      return;
    }
    if (password.length < 6) {
      setErrorMsg('Password must be at least 6 characters');
      return;
    }

    setLoading(true);
    setErrorMsg('');

    const { error } = await authService.signUp(email, password, fullName);
    setLoading(false);

    if (error) {
      setErrorMsg(error.message);
    } else {
      setSuccess(true);
    }
  };

  if (success) {
    return (
      <View style={[styles.container, { justifyContent: 'center', alignItems: 'center', padding: 40 }]}>
        <View style={styles.successCircle}>
          <Ionicons name="checkmark-circle" size={60} color={Colors.emerald} />
        </View>
        <Text style={styles.successTitle}>Account Created!</Text>
        <Text style={styles.successSubtitle}>Check your email to verify your account, then log in.</Text>
        <TouchableOpacity style={styles.loginBtn} onPress={() => router.replace('/(auth)/login')}>
          <Text style={styles.loginBtnText}>Go to Login</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView style={styles.container} behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        {/* Back Button */}
        <TouchableOpacity style={styles.backBtn} onPress={() => router.back()}>
          <Ionicons name="arrow-back" size={24} color={Colors.textPrimary} />
        </TouchableOpacity>

        {/* Logo */}
        <View style={styles.logoSection}>
          <View style={styles.logoCircle}>
            <Ionicons name="medical" size={36} color={Colors.brandBlue} />
          </View>
          <Text style={styles.logoText}>MedAssist</Text>
        </View>

        <View style={styles.titleSection}>
          <Text style={styles.title}>Create Account</Text>
          <Text style={styles.subtitle}>Join the MedAssist Doctor Network</Text>
        </View>

        {errorMsg !== '' && (
          <View style={styles.errorBox}>
            <Ionicons name="alert-circle" size={16} color={Colors.red} />
            <Text style={styles.errorText}>{errorMsg}</Text>
          </View>
        )}

        {/* Full Name */}
        <View style={styles.inputGroup}>
          <Text style={styles.label}>Full Name</Text>
          <View style={styles.inputWrapper}>
            <Ionicons name="person-outline" size={20} color={Colors.slate400} style={styles.inputIcon} />
            <TextInput style={styles.input} placeholder="Dr. John Doe" placeholderTextColor={Colors.slate400}
              value={fullName} onChangeText={setFullName} />
          </View>
        </View>

        {/* Email */}
        <View style={styles.inputGroup}>
          <Text style={styles.label}>Email</Text>
          <View style={styles.inputWrapper}>
            <Ionicons name="mail-outline" size={20} color={Colors.slate400} style={styles.inputIcon} />
            <TextInput style={styles.input} placeholder="doctor@medassist.com" placeholderTextColor={Colors.slate400}
              value={email} onChangeText={setEmail} keyboardType="email-address" autoCapitalize="none" />
          </View>
        </View>

        {/* Password */}
        <View style={styles.inputGroup}>
          <Text style={styles.label}>Password</Text>
          <View style={styles.inputWrapper}>
            <Ionicons name="lock-closed-outline" size={20} color={Colors.slate400} style={styles.inputIcon} />
            <TextInput style={styles.input} placeholder="Min. 6 characters" placeholderTextColor={Colors.slate400}
              value={password} onChangeText={setPassword} secureTextEntry={!showPassword} />
            <TouchableOpacity onPress={() => setShowPassword(!showPassword)} style={styles.eyeBtn}>
              <Ionicons name={showPassword ? 'eye-off-outline' : 'eye-outline'} size={20} color={Colors.slate400} />
            </TouchableOpacity>
          </View>
        </View>

        <TouchableOpacity style={styles.loginBtn} onPress={handleSignup} disabled={loading} activeOpacity={0.8}>
          {loading ? <ActivityIndicator color="#FFF" /> : <Text style={styles.loginBtnText}>Create Account</Text>}
        </TouchableOpacity>

        <View style={styles.footer}>
          <Text style={styles.footerText}>Already have an account? </Text>
          <Link href="/(auth)/login" asChild>
            <TouchableOpacity><Text style={styles.footerLink}>Login</Text></TouchableOpacity>
          </Link>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#EBF4FE' },
  scroll: { flexGrow: 1, paddingHorizontal: 28, paddingTop: 20, paddingBottom: 40 },
  backBtn: { width: 44, height: 44, borderRadius: 22, backgroundColor: Colors.surface, justifyContent: 'center', alignItems: 'center', marginBottom: 20, borderWidth: 1, borderColor: Colors.border },
  logoSection: { alignItems: 'center', marginBottom: 28 },
  logoCircle: { width: 70, height: 70, borderRadius: 35, backgroundColor: Colors.blueLight, justifyContent: 'center', alignItems: 'center', marginBottom: 10 },
  logoText: { fontSize: 32, fontWeight: '800', color: Colors.textPrimary },
  titleSection: { alignItems: 'center', marginBottom: 28 },
  title: { fontSize: FontSize.h1, fontWeight: '800', color: Colors.textPrimary, marginBottom: 8 },
  subtitle: { fontSize: FontSize.base, color: Colors.textSecondary, fontWeight: '500' },
  errorBox: { flexDirection: 'row', alignItems: 'center', gap: 8, backgroundColor: Colors.redBg, borderWidth: 1, borderColor: Colors.redLight, padding: 12, borderRadius: BorderRadius.md, marginBottom: 16 },
  errorText: { color: Colors.red, fontSize: FontSize.sm, flex: 1, fontWeight: '500' },
  inputGroup: { marginBottom: 16 },
  label: { fontSize: FontSize.base, fontWeight: '600', color: Colors.textPrimary, marginBottom: 8, paddingLeft: 4 },
  inputWrapper: { flexDirection: 'row', alignItems: 'center', backgroundColor: Colors.surface, borderRadius: BorderRadius.lg, borderWidth: 1.5, borderColor: Colors.border, paddingHorizontal: 16, height: 56 },
  inputIcon: { marginRight: 12 },
  input: { flex: 1, fontSize: FontSize.lg, color: Colors.textPrimary, fontWeight: '500' },
  eyeBtn: { padding: 8 },
  loginBtn: { backgroundColor: Colors.brandBlue, height: 56, borderRadius: 28, justifyContent: 'center', alignItems: 'center', marginTop: 8, shadowColor: Colors.brandBlue, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.3, shadowRadius: 12, elevation: 8 },
  loginBtnText: { color: Colors.textWhite, fontSize: FontSize.lg, fontWeight: '700' },
  footer: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', paddingTop: 24 },
  footerText: { color: Colors.textSecondary, fontSize: FontSize.base, fontWeight: '500' },
  footerLink: { color: Colors.brandBlue, fontSize: FontSize.base, fontWeight: '700' },
  successCircle: { marginBottom: 20 },
  successTitle: { fontSize: FontSize.xxl, fontWeight: '800', color: Colors.textPrimary, marginBottom: 8 },
  successSubtitle: { fontSize: FontSize.base, color: Colors.textSecondary, textAlign: 'center', fontWeight: '500', marginBottom: 32 },
});
