import React from 'react';
import { StyleSheet, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useAppTheme } from '../../core/theme/useTheme';

interface AppBackgroundProps {
  children: React.ReactNode;
}

export function AppBackground({ children }: AppBackgroundProps) {
  const { isDark } = useAppTheme();

  return (
    <View style={styles.container}>
      <LinearGradient
        colors={
          isDark
            ? ['#0F1419', '#131A22', '#0F1419']
            : ['#F0F4FF', '#F8FAFC', '#EFF6FF']
        }
        style={StyleSheet.absoluteFillObject}
      />
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
