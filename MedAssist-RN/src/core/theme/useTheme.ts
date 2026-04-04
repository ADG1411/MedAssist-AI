import { useColorScheme } from 'react-native';
import { AppColors, DarkColors } from './colors';
import { create } from 'zustand';

interface ThemeStore {
  mode: 'system' | 'light' | 'dark';
  setMode: (mode: 'system' | 'light' | 'dark') => void;
}

export const useThemeStore = create<ThemeStore>((set) => ({
  mode: 'system',
  setMode: (mode) => set({ mode }),
}));

export function useAppTheme() {
  const systemScheme = useColorScheme();
  const { mode } = useThemeStore();

  const isDark =
    mode === 'system' ? systemScheme === 'dark' : mode === 'dark';

  return {
    isDark,
    colors: {
      primary: AppColors.primary,
      softBlue: AppColors.softBlue,
      success: AppColors.success,
      warning: AppColors.warning,
      danger: AppColors.danger,
      surface: isDark ? DarkColors.surface : AppColors.surface,
      background: isDark ? DarkColors.background : AppColors.background,
      textPrimary: isDark ? DarkColors.textPrimary : AppColors.textPrimary,
      textSecondary: isDark
        ? DarkColors.textSecondary
        : AppColors.textSecondary,
      border: isDark ? DarkColors.border : AppColors.border,
      card: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(255,255,255,0.72)',
      cardBorder: isDark
        ? 'rgba(255,255,255,0.10)'
        : 'rgba(255,255,255,0.55)',
    },
  };
}
