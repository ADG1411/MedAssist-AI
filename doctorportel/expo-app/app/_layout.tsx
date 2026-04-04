import { useEffect, useState } from 'react';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { View, ActivityIndicator, StyleSheet } from 'react-native';
import { Colors } from '../constants/Colors';
import { supabase } from '../services/supabase';

export default function RootLayout() {
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    // Listen for auth state changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, _session) => {
      setIsReady(true);
    });
    // Also check initial session
    supabase.auth.getSession().then(() => setIsReady(true));
    return () => subscription.unsubscribe();
  }, []);

  if (!isReady) {
    return (
      <View style={styles.loader}>
        <ActivityIndicator size="large" color={Colors.brandBlue} />
        <StatusBar style="dark" />
      </View>
    );
  }

  return (
    <>
      <StatusBar style="dark" />
      <Stack screenOptions={{ headerShown: false, animation: 'slide_from_right' }}>
        <Stack.Screen name="index" />
        <Stack.Screen name="(auth)" />
        <Stack.Screen name="(dashboard)" />
      </Stack>
    </>
  );
}

const styles = StyleSheet.create({
  loader: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: Colors.background,
  },
});
