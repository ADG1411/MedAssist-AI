// Theme colors & design tokens for MedAssist Doctor Portal
export const Colors = {
  // Brand
  brandBlue: '#1A6BFF',
  brandBlueDark: '#1556CC',
  brandBlueLight: '#EBF4FE',

  // Background
  background: '#F9FBFF',
  surface: '#FFFFFF',
  surfaceAlt: '#F8FAFC',

  // Text
  textPrimary: '#0A2540',
  textSecondary: '#64748B',
  textTertiary: '#94A3B8',
  textWhite: '#FFFFFF',

  // Slate
  slate50: '#F8FAFC',
  slate100: '#F1F5F9',
  slate200: '#E2E8F0',
  slate300: '#CBD5E1',
  slate400: '#94A3B8',
  slate500: '#64748B',
  slate600: '#475569',
  slate700: '#334155',
  slate800: '#1E293B',
  slate900: '#0F172A',

  // Status
  emerald: '#10B981',
  emeraldBg: '#ECFDF5',
  emeraldLight: '#D1FAE5',
  amber: '#F59E0B',
  amberBg: '#FFFBEB',
  amberLight: '#FEF3C7',
  red: '#EF4444',
  redBg: '#FEF2F2',
  redLight: '#FEE2E2',
  purple: '#8B5CF6',
  purpleBg: '#F5F3FF',
  purpleLight: '#EDE9FE',
  blue: '#3B82F6',
  blueBg: '#EFF6FF',
  blueLight: '#DBEAFE',
  indigo: '#6366F1',

  // Borders
  border: '#E2E8F0',
  borderLight: '#F1F5F9',

  // Shadows
  shadowColor: '#000',

  // Overlay
  overlay: 'rgba(15, 23, 42, 0.6)',

  // Chart colors
  chartBlue: '#3B82F6',
  chartEmerald: '#10B981',
  chartAmber: '#F59E0B',
  chartPurple: '#8B5CF6',
  chartRed: '#EF4444',
} as const;

export const Spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
} as const;

export const FontSize = {
  xs: 10,
  sm: 12,
  md: 14,
  base: 15,
  lg: 16,
  xl: 18,
  xxl: 20,
  xxxl: 24,
  h1: 28,
  h2: 32,
  hero: 36,
} as const;

export const BorderRadius = {
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  full: 999,
} as const;
