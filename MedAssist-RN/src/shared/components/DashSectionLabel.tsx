import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useAppTheme } from '../../core/theme/useTheme';

interface DashSectionLabelProps {
  title: string;
  subtitle: string;
}

export function DashSectionLabel({ title, subtitle }: DashSectionLabelProps) {
  const { colors } = useAppTheme();

  return (
    <View style={styles.container}>
      <Text style={[styles.title, { color: colors.textPrimary }]}>{title}</Text>
      <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
        {subtitle}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 4,
    marginBottom: 2,
  },
  title: {
    fontSize: 16,
    fontWeight: '700',
    letterSpacing: -0.3,
  },
  subtitle: {
    fontSize: 11,
    fontWeight: '500',
    marginTop: 1,
  },
});
