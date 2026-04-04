import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Pressable, Animated, Easing } from 'react-native';
import { Tabs, useRouter, usePathname } from 'expo-router';
import { BlurView } from 'expo-blur';
import * as Haptics from 'expo-haptics';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useAppTheme } from '../../src/core/theme/useTheme';
import { AppColors } from '../../src/core/theme/colors';
// @ts-ignore — @expo/vector-icons is bundled with expo
import { Ionicons } from '@expo/vector-icons';

type IconName = string;

const TAB_ITEMS: { route: string; label: string; icon: IconName; activeIcon: IconName }[] = [
  { route: 'home', label: 'Home', icon: 'home-outline', activeIcon: 'home' },
  { route: 'doctors', label: 'Doctors', icon: 'medical-outline', activeIcon: 'medical' },
  { route: 'nutrition', label: 'Nutrition', icon: 'restaurant-outline', activeIcon: 'restaurant' },
  { route: 'records', label: 'Records', icon: 'folder-outline', activeIcon: 'folder' },
  { route: 'profile', label: 'Profile', icon: 'person-outline', activeIcon: 'person' },
];

export default function TabLayout() {
  const { isDark, colors } = useAppTheme();
  const insets = useSafeAreaInsets();
  const router = useRouter();

  // SOS pulse animation
  const pulse = useRef(new Animated.Value(1)).current;
  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(pulse, { toValue: 1.28, duration: 1400, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
        Animated.timing(pulse, { toValue: 1, duration: 1400, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
      ])
    ).start();
  }, []);

  return (
    <View style={{ flex: 1 }}>
      <Tabs
        screenOptions={{
          headerShown: false,
          tabBarStyle: {
            position: 'absolute',
            bottom: insets.bottom > 0 ? insets.bottom : 14,
            left: 18,
            right: 18,
            height: 66,
            borderRadius: 32,
            borderTopWidth: 0,
            backgroundColor: isDark
              ? 'rgba(5,14,26,0.75)'
              : 'rgba(255,255,255,0.80)',
            borderColor: isDark
              ? 'rgba(255,255,255,0.08)'
              : 'rgba(255,255,255,0.55)',
            borderWidth: 1,
            shadowColor: '#000',
            shadowOffset: { width: 0, height: 8 },
            shadowOpacity: 0.12,
            shadowRadius: 24,
            elevation: 12,
            paddingHorizontal: 6,
          },
          tabBarActiveTintColor: AppColors.primary,
          tabBarInactiveTintColor: isDark
            ? 'rgba(255,255,255,0.45)'
            : '#94A3B8',
          tabBarLabelStyle: {
            fontSize: 10,
            fontWeight: '600',
            letterSpacing: 0.2,
          },
        }}
      >
        {TAB_ITEMS.map((item) => (
          <Tabs.Screen
            key={item.route}
            name={item.route}
            options={{
              title: item.label,
              tabBarIcon: ({ focused, color, size }) => (
                <View
                  style={[
                    styles.tabIconWrap,
                    focused && {
                      backgroundColor: isDark
                        ? `${AppColors.primary}38`
                        : `${AppColors.primary}22`,
                    },
                  ]}
                >
                  <Ionicons
                    name={focused ? item.activeIcon : item.icon}
                    size={22}
                    color={color}
                  />
                </View>
              ),
              tabBarButton: (props) => {
                const { onPress, children, style, accessibilityRole, accessibilityState } = props as any;
                return (
                  <Pressable
                    style={style}
                    accessibilityRole={accessibilityRole}
                    accessibilityState={accessibilityState}
                    onPress={(e) => {
                      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                      onPress?.(e);
                    }}
                  >
                    {children}
                  </Pressable>
                );
              },
            }}
          />
        ))}
      </Tabs>

      {/* SOS FAB */}
      <View style={[styles.fabContainer, { bottom: insets.bottom > 0 ? insets.bottom + 70 : 84 }]}>
        <Animated.View style={[styles.fabPulse, { transform: [{ scale: pulse }] }]} />
        <Pressable
          style={styles.fabButton}
          onPress={() => {
            Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
            router.push('/sos');
          }}
        >
          <Text style={styles.fabText}>SOS</Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  tabIconWrap: {
    paddingHorizontal: 13,
    paddingVertical: 5,
    borderRadius: 13,
  },
  fabContainer: {
    position: 'absolute',
    right: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  fabPulse: {
    position: 'absolute',
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: 'rgba(239,68,68,0.22)',
  },
  fabButton: {
    width: 52,
    height: 52,
    borderRadius: 26,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: AppColors.danger,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.5,
    shadowRadius: 16,
    elevation: 8,
    // gradient fallback
    backgroundColor: '#EF4444',
  },
  fabText: {
    color: '#FFF',
    fontWeight: '900',
    fontSize: 14,
    letterSpacing: 0.5,
  },
});
