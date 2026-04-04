import React, { useEffect, useRef } from 'react';
import { ScrollView, View, StyleSheet, Animated, Easing } from 'react-native';
import { AppBackground } from '../../src/shared/components/AppBackground';
import { useAuthStore } from '../../src/core/store/authStore';
import { useDashboardStore } from '../../src/features/dashboard/store/dashboardStore';
import {
  FloatingGlassHeader,
  PremiumHealthCommandCard,
  AttentionHubRail,
  LiveVitalsGlassRail,
  AiInsightStream,
  ActionMatrixGrid,
  RecoveryMissionStory,
  AiDailyCareEngine,
  HealthTimelineStepper,
} from '../../src/features/dashboard/widgets';
import { ShimmerBox } from '../../src/shared/components/ShimmerBox';

function StaggeredSection({ index, children }: { index: number; children: React.ReactNode }) {
  const opacity = useRef(new Animated.Value(0)).current;
  const translateY = useRef(new Animated.Value(30)).current;

  useEffect(() => {
    Animated.parallel([
      Animated.timing(opacity, { toValue: 1, duration: 500, delay: index * 80, easing: Easing.out(Easing.cubic), useNativeDriver: true }),
      Animated.timing(translateY, { toValue: 0, duration: 500, delay: index * 80, easing: Easing.out(Easing.cubic), useNativeDriver: true }),
    ]).start();
  }, []);

  return <Animated.View style={{ opacity, transform: [{ translateY }] }}>{children}</Animated.View>;
}

export default function HomeScreen() {
  const user = useAuthStore((s) => s.user);
  const { data, loading, fetch } = useDashboardStore();

  useEffect(() => {
    if (user?.id) fetch(user.id);
  }, [user?.id]);

  if (loading && !data) {
    return (
      <AppBackground>
        <ScrollView contentContainerStyle={styles.loadingScroll}>
          {[...Array(5)].map((_, i) => (
            <ShimmerBox key={i} width="100%" height={120} radius={24} style={{ marginBottom: 16 }} />
          ))}
        </ScrollView>
      </AppBackground>
    );
  }

  const d = data ?? ({} as Record<string, any>);

  return (
    <AppBackground>
      <ScrollView
        contentContainerStyle={styles.scroll}
        showsVerticalScrollIndicator={false}
      >
        <StaggeredSection index={0}>
          <FloatingGlassHeader data={d} />
        </StaggeredSection>

        <StaggeredSection index={1}>
          <PremiumHealthCommandCard data={d} />
        </StaggeredSection>

        <StaggeredSection index={2}>
          <AttentionHubRail data={d} />
        </StaggeredSection>

        <StaggeredSection index={3}>
          <LiveVitalsGlassRail data={d} />
        </StaggeredSection>

        <StaggeredSection index={4}>
          <AiInsightStream data={d} />
        </StaggeredSection>

        <StaggeredSection index={5}>
          <ActionMatrixGrid />
        </StaggeredSection>

        <StaggeredSection index={6}>
          <RecoveryMissionStory data={d} />
        </StaggeredSection>

        <StaggeredSection index={7}>
          <AiDailyCareEngine data={d} />
        </StaggeredSection>

        <StaggeredSection index={8}>
          <HealthTimelineStepper data={d} />
        </StaggeredSection>

        <View style={{ height: 120 }} />
      </ScrollView>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  scroll: {
    paddingHorizontal: 16,
    paddingTop: 60,
    gap: 20,
  },
  loadingScroll: {
    paddingHorizontal: 16,
    paddingTop: 60,
  },
});
