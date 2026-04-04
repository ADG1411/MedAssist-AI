import React, { useEffect } from 'react';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { StyleSheet } from 'react-native';
import {
  useFonts,
  Inter_400Regular,
  Inter_500Medium,
  Inter_600SemiBold,
  Inter_700Bold,
  Inter_800ExtraBold,
} from '@expo-google-fonts/inter';
import * as SplashScreen from 'expo-system-ui';
import { useAuthStore } from '../src/core/store/authStore';
import { useAppTheme } from '../src/core/theme/useTheme';

export default function RootLayout() {
  const { isDark } = useAppTheme();
  const initialize = useAuthStore((s) => s.initialize);

  const [fontsLoaded] = useFonts({
    Inter_400Regular,
    Inter_500Medium,
    Inter_600SemiBold,
    Inter_700Bold,
    Inter_800ExtraBold,
  });

  useEffect(() => {
    initialize();
  }, [initialize]);

  if (!fontsLoaded) return null;

  return (
    <GestureHandlerRootView style={styles.root}>
      <StatusBar style={isDark ? 'light' : 'dark'} />
      <Stack
        screenOptions={{
          headerShown: false,
          animation: 'slide_from_right',
          contentStyle: {
            backgroundColor: isDark ? '#0F1419' : '#F8FAFC',
          },
        }}
      >
        <Stack.Screen name="index" />
        <Stack.Screen name="onboarding" options={{ animation: 'fade' }} />
        <Stack.Screen name="login" options={{ animation: 'slide_from_right' }} />
        <Stack.Screen name="signup" options={{ animation: 'slide_from_right' }} />
        <Stack.Screen name="(tabs)" options={{ animation: 'fade' }} />
        <Stack.Screen name="symptom-check" options={{ animation: 'slide_from_bottom' }} />
        <Stack.Screen name="symptom-chat" />
        <Stack.Screen name="ai-result" />
        <Stack.Screen name="deep-check" />
        <Stack.Screen name="doctor-detail" />
        <Stack.Screen name="consultation" options={{ animation: 'slide_from_bottom' }} />
        <Stack.Screen name="post-consult" options={{ animation: 'fade' }} />
        <Stack.Screen name="nutrition-search" options={{ animation: 'slide_from_bottom' }} />
        <Stack.Screen name="nutrition-ai" />
        <Stack.Screen name="nutrition-history" />
        <Stack.Screen name="nutrition-barcode" />
        <Stack.Screen name="nutrition-image-scan" options={{ animation: 'slide_from_bottom' }} />
        <Stack.Screen name="food-detail" options={{ animation: 'slide_from_bottom' }} />
        <Stack.Screen name="activity-search" options={{ animation: 'slide_from_bottom' }} />
        <Stack.Screen name="monitoring" />
        <Stack.Screen name="recovery-report" />
        <Stack.Screen name="daily-followup" options={{ animation: 'slide_from_bottom' }} />
        <Stack.Screen name="medassist-card" options={{ animation: 'slide_from_bottom' }} />
        <Stack.Screen name="pharmacy" />
        <Stack.Screen name="sos" options={{ animation: 'slide_from_bottom' }} />
        <Stack.Screen name="hospitals" />
        <Stack.Screen name="health-connect" />
        <Stack.Screen name="health-detail" />
      </Stack>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
});
