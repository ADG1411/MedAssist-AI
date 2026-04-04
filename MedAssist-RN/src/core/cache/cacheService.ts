import AsyncStorage from '@react-native-async-storage/async-storage';

export const CacheBoxNames = {
  profile: 'profile',
  chatHistory: 'chat_history',
  aiResults: 'ai_results',
  nutrition: 'nutrition',
  emergency: 'emergency',
  recordsMetadata: 'records_metadata',
  syncQueue: 'sync_queue',
  featureFlags: 'feature_flags',
} as const;

type BoxName = (typeof CacheBoxNames)[keyof typeof CacheBoxNames];

export const CacheService = {
  async get<T = unknown>(box: BoxName, key: string): Promise<T | null> {
    try {
      const raw = await AsyncStorage.getItem(`${box}:${key}`);
      return raw ? (JSON.parse(raw) as T) : null;
    } catch {
      return null;
    }
  },

  async set(box: BoxName, key: string, value: unknown): Promise<void> {
    try {
      await AsyncStorage.setItem(`${box}:${key}`, JSON.stringify(value));
    } catch {
      // silent
    }
  },

  async remove(box: BoxName, key: string): Promise<void> {
    try {
      await AsyncStorage.removeItem(`${box}:${key}`);
    } catch {
      // silent
    }
  },

  async clearBox(box: BoxName): Promise<void> {
    try {
      const keys = await AsyncStorage.getAllKeys();
      const boxKeys = keys.filter((k) => k.startsWith(`${box}:`));
      if (boxKeys.length > 0) await AsyncStorage.multiRemove(boxKeys);
    } catch {
      // silent
    }
  },

  async clearAll(): Promise<void> {
    try {
      await AsyncStorage.clear();
    } catch {
      // silent
    }
  },
};
