import React from 'react';
import { View, StyleSheet, ViewStyle } from 'react-native';
import { BlurView } from 'expo-blur';
import { useAppTheme } from '../../core/theme/useTheme';

interface GlassCardProps {
  children: React.ReactNode;
  radius?: number;
  blur?: number;
  padding?: number;
  style?: ViewStyle;
}

export function GlassCard({
  children,
  radius = 24,
  blur = 18,
  padding = 16,
  style,
}: GlassCardProps) {
  const { isDark, colors } = useAppTheme();

  return (
    <View
      style={[
        styles.wrapper,
        {
          borderRadius: radius,
          borderColor: colors.cardBorder,
        },
        style,
      ]}
    >
      <BlurView
        intensity={blur}
        tint={isDark ? 'dark' : 'light'}
        style={[
          styles.blur,
          {
            borderRadius: radius,
            padding,
          },
        ]}
      >
        {children}
      </BlurView>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    overflow: 'hidden',
    borderWidth: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 4,
  },
  blur: {
    overflow: 'hidden',
  },
});
