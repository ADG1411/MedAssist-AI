import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, Pressable, TextInput,
} from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
// @ts-ignore
import { Ionicons } from '@expo/vector-icons';
import { AppBackground } from '../src/shared/components/AppBackground';
import { GlassCard } from '../src/shared/components/GlassCard';
import { useAppTheme } from '../src/core/theme/useTheme';

const CATEGORIES = ['All', 'Prescribed', 'OTC', 'Supplements', 'Medical Devices'];

const MOCK_MEDS = [
  { id: '1', name: 'Omeprazole 20mg', type: 'Prescribed', price: '₹85', qty: '10 caps', inStock: true, prescribed: true },
  { id: '2', name: 'Antacid Gel 170ml', type: 'OTC', price: '₹120', qty: '1 bottle', inStock: true, prescribed: true },
  { id: '3', name: 'Probiotics 30 caps', type: 'Supplements', price: '₹340', qty: '30 caps', inStock: true, prescribed: true },
  { id: '4', name: 'Paracetamol 500mg', type: 'OTC', price: '₹25', qty: '10 tabs', inStock: true, prescribed: false },
  { id: '5', name: 'Vitamin D3 60K IU', type: 'Supplements', price: '₹180', qty: '8 caps', inStock: false, prescribed: false },
  { id: '6', name: 'Digital Thermometer', type: 'Medical Devices', price: '₹250', qty: '1 unit', inStock: true, prescribed: false },
];

export default function PharmacyScreen() {
  const { isDark, colors } = useAppTheme();
  const router = useRouter();
  const [search, setSearch] = useState('');
  const [activeTab, setActiveTab] = useState('All');
  const [cart, setCart] = useState<string[]>([]);

  const filtered = MOCK_MEDS.filter((m) => {
    const matchSearch = m.name.toLowerCase().includes(search.toLowerCase());
    const matchTab = activeTab === 'All' || m.type === activeTab;
    return matchSearch && matchTab;
  });

  const toggleCart = (id: string) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setCart((prev) => prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]);
  };

  return (
    <AppBackground>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.headerRow}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.textPrimary} />
          </Pressable>
          <Text style={[styles.title, { color: colors.textPrimary }]}>Pharmacy</Text>
          <View style={styles.cartBadge}>
            <Ionicons name="cart" size={20} color={colors.textPrimary} />
            {cart.length > 0 && (
              <View style={styles.cartCount}>
                <Text style={styles.cartCountText}>{cart.length}</Text>
              </View>
            )}
          </View>
        </View>

        {/* Search */}
        <View style={[styles.searchBar, {
          backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : '#F1F5F9',
          borderColor: isDark ? 'rgba(255,255,255,0.08)' : '#E2E8F0',
        }]}>
          <Ionicons name="search" size={18} color={colors.textSecondary} />
          <TextInput
            style={[styles.searchInput, { color: colors.textPrimary }]}
            placeholder="Search medicines..."
            placeholderTextColor={colors.textSecondary}
            value={search}
            onChangeText={setSearch}
          />
        </View>

        {/* Category tabs */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.tabScroll} contentContainerStyle={styles.tabRow}>
          {CATEGORIES.map((c) => (
            <Pressable
              key={c}
              onPress={() => setActiveTab(c)}
              style={[styles.tab, {
                backgroundColor: c === activeTab ? '#2A7FFF' : (isDark ? 'rgba(255,255,255,0.06)' : '#F1F5F9'),
              }]}
            >
              <Text style={[styles.tabText, { color: c === activeTab ? '#FFF' : colors.textSecondary }]}>{c}</Text>
            </Pressable>
          ))}
        </ScrollView>

        {/* Medicine list */}
        {filtered.map((med) => {
          const inCart = cart.includes(med.id);
          return (
            <GlassCard key={med.id} radius={18} blur={14} padding={14} style={{ marginBottom: 8 }}>
              <View style={styles.medRow}>
                <View style={[styles.medIcon, { backgroundColor: med.prescribed ? 'rgba(16,185,129,0.10)' : 'rgba(59,130,246,0.10)' }]}>
                  <Ionicons name="medkit" size={18} color={med.prescribed ? '#10B981' : '#3B82F6'} />
                </View>
                <View style={styles.medInfo}>
                  <View style={styles.medNameRow}>
                    <Text style={[styles.medName, { color: colors.textPrimary }]}>{med.name}</Text>
                    {med.prescribed && (
                      <View style={styles.rxBadge}><Text style={styles.rxText}>Rx</Text></View>
                    )}
                  </View>
                  <Text style={[styles.medQty, { color: colors.textSecondary }]}>{med.qty}</Text>
                </View>
                <View style={styles.medRight}>
                  <Text style={[styles.medPrice, { color: colors.textPrimary }]}>{med.price}</Text>
                  {med.inStock ? (
                    <Pressable onPress={() => toggleCart(med.id)} style={[styles.addCartBtn, {
                      backgroundColor: inCart ? '#10B981' : (isDark ? 'rgba(42,127,255,0.15)' : 'rgba(42,127,255,0.08)'),
                    }]}>
                      <Ionicons name={inCart ? 'checkmark' : 'add'} size={16} color={inCart ? '#FFF' : '#2A7FFF'} />
                    </Pressable>
                  ) : (
                    <Text style={styles.oosText}>Out of stock</Text>
                  )}
                </View>
              </View>
            </GlassCard>
          );
        })}

        {/* Checkout */}
        {cart.length > 0 && (
          <Pressable onPress={() => {
            Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
            setCart([]);
          }} style={{ marginTop: 10 }}>
            <LinearGradient colors={['#10B981', '#059669']} style={styles.checkoutBtn}>
              <Ionicons name="cart" size={18} color="#FFF" />
              <Text style={styles.checkoutText}>Checkout ({cart.length} items)</Text>
            </LinearGradient>
          </Pressable>
        )}

        <View style={{ height: 40 }} />
      </ScrollView>
    </AppBackground>
  );
}

const styles = StyleSheet.create({
  scroll: { paddingHorizontal: 16, paddingTop: 60 },
  headerRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginBottom: 16 },
  backBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 22, fontWeight: '800', flex: 1 },
  cartBadge: { position: 'relative' },
  cartCount: {
    position: 'absolute', top: -6, right: -6,
    backgroundColor: '#EF4444', width: 16, height: 16, borderRadius: 8,
    alignItems: 'center', justifyContent: 'center',
  },
  cartCountText: { color: '#FFF', fontSize: 9, fontWeight: '800' },
  searchBar: {
    flexDirection: 'row', alignItems: 'center', height: 46, borderRadius: 14,
    paddingHorizontal: 14, borderWidth: 0.6, marginBottom: 14, gap: 10,
  },
  searchInput: { flex: 1, fontSize: 14 },
  tabScroll: { marginBottom: 14 },
  tabRow: { gap: 8 },
  tab: { paddingHorizontal: 14, paddingVertical: 7, borderRadius: 20 },
  tabText: { fontSize: 12, fontWeight: '600' },
  medRow: { flexDirection: 'row', alignItems: 'center' },
  medIcon: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  medInfo: { flex: 1, marginLeft: 12 },
  medNameRow: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  medName: { fontSize: 14, fontWeight: '600' },
  rxBadge: { backgroundColor: 'rgba(16,185,129,0.12)', paddingHorizontal: 5, paddingVertical: 1, borderRadius: 4 },
  rxText: { fontSize: 8, fontWeight: '800', color: '#10B981' },
  medQty: { fontSize: 11, marginTop: 2 },
  medRight: { alignItems: 'flex-end', gap: 6 },
  medPrice: { fontSize: 15, fontWeight: '800' },
  addCartBtn: { width: 32, height: 32, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  oosText: { fontSize: 9, fontWeight: '600', color: '#EF4444' },
  checkoutBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8,
    height: 52, borderRadius: 14,
    shadowColor: '#10B981', shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25, shadowRadius: 12, elevation: 6,
  },
  checkoutText: { fontSize: 15, fontWeight: '700', color: '#FFF' },
});
