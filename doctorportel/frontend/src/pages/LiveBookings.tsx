import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Video, Clock, CheckCircle2, AlertCircle, RefreshCw, Users, IndianRupee } from 'lucide-react';
import { getBookingsForDoctor, getPatientProfile, bookingToAppointment } from '../services/bookingService';
import type { BookingRow } from '../services/bookingService';
import { supabase } from '../lib/supabase';

function LiveBookings() {
  const navigate = useNavigate();
  const [bookings, setBookings] = useState<(BookingRow & { patientName?: string })[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const fetchBookings = async () => {
    try {
      // Get the current doctor's user ID from Supabase auth
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      // For now, fetch ALL confirmed bookings (in production, filter by doctor_id)
      const { data, error } = await supabase
        .from('bookings')
        .select('*')
        .in('status', ['confirmed', 'pending', 'completed'])
        .order('created_at', { ascending: false })
        .limit(50);

      if (error) {
        console.error('Booking fetch error:', error);
        return;
      }

      // Enrich with patient names
      const enriched = await Promise.all(
        (data ?? []).map(async (booking: BookingRow) => {
          const profile = await getPatientProfile(booking.patient_id);
          return {
            ...booking,
            patientName: profile?.full_name ?? `Patient ${booking.patient_id.substring(0, 8)}`,
          };
        })
      );

      setBookings(enriched);
    } catch (err) {
      console.error('Failed to load bookings:', err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchBookings();
    // Set up realtime subscription for new bookings
    const channel = supabase
      .channel('bookings-realtime')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'bookings' }, () => {
        fetchBookings();
      })
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  const handleRefresh = () => {
    setRefreshing(true);
    fetchBookings();
  };

  const confirmedCount = bookings.filter(b => b.status === 'confirmed').length;
  const pendingCount = bookings.filter(b => b.status === 'pending').length;
  const completedCount = bookings.filter(b => b.status === 'completed').length;
  const totalRevenue = bookings
    .filter(b => b.payment_status === 'paid')
    .reduce((acc, b) => acc + (b.amount ?? 0), 0);

  const statusColor: Record<string, string> = {
    confirmed: 'bg-emerald-50 text-emerald-700 border-emerald-200',
    pending: 'bg-amber-50 text-amber-700 border-amber-200',
    completed: 'bg-blue-50 text-blue-700 border-blue-200',
    cancelled: 'bg-red-50 text-red-700 border-red-200',
  };

  return (
    <div className="w-full animate-in fade-in slide-in-from-bottom-4 duration-500">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
        <div>
          <h1 className="text-2xl font-black text-slate-800">Live Patient Bookings</h1>
          <p className="text-sm text-slate-500 mt-1">Real-time bookings from MedAssist Patient App</p>
        </div>
        <button
          onClick={handleRefresh}
          disabled={refreshing}
          className="flex items-center gap-2 bg-white border border-slate-200 text-slate-700 font-bold text-sm px-4 py-2.5 rounded-2xl hover:bg-slate-50 transition-all shadow-sm disabled:opacity-50"
        >
          <RefreshCw className={`w-4 h-4 ${refreshing ? 'animate-spin' : ''}`} />
          Refresh
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
        {[
          { label: 'Confirmed', value: confirmedCount, icon: CheckCircle2, cls: 'bg-emerald-50 text-emerald-700 border-emerald-200' },
          { label: 'Pending', value: pendingCount, icon: Clock, cls: 'bg-amber-50 text-amber-700 border-amber-200' },
          { label: 'Completed', value: completedCount, icon: Users, cls: 'bg-blue-50 text-blue-700 border-blue-200' },
          { label: 'Revenue', value: `₹${totalRevenue.toLocaleString()}`, icon: IndianRupee, cls: 'bg-violet-50 text-violet-700 border-violet-200' },
        ].map(({ label, value, icon: Icon, cls }) => (
          <div key={label} className={`flex items-center gap-3 px-4 py-3 rounded-2xl border shadow-sm ${cls}`}>
            <Icon className="w-5 h-5" />
            <div>
              <p className="text-xs font-semibold opacity-70">{label}</p>
              <p className="text-lg font-black">{value}</p>
            </div>
          </div>
        ))}
      </div>

      {/* Bookings List */}
      {loading ? (
        <div className="flex items-center justify-center py-20">
          <RefreshCw className="w-8 h-8 text-indigo-400 animate-spin" />
        </div>
      ) : bookings.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-slate-400">
          <AlertCircle className="w-12 h-12 mb-3 text-slate-300" />
          <p className="font-bold text-lg text-slate-600">No bookings yet</p>
          <p className="text-sm">Patients will appear here after booking via the MedAssist app.</p>
        </div>
      ) : (
        <div className="space-y-3">
          {bookings.map((booking) => (
            <div
              key={booking.id}
              className="bg-white border border-slate-200 rounded-2xl p-4 shadow-sm hover:shadow-md transition-all"
            >
              <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
                {/* Patient Info */}
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-indigo-100 flex items-center justify-center text-indigo-700 font-black text-sm">
                    {(booking.patientName ?? 'P')[0].toUpperCase()}
                  </div>
                  <div>
                    <p className="font-bold text-slate-800">{booking.patientName}</p>
                    <p className="text-xs text-slate-500">
                      {booking.slot_time} · ₹{booking.amount} · {booking.doctor_specialty ?? 'General'}
                    </p>
                  </div>
                </div>

                {/* Status + Actions */}
                <div className="flex items-center gap-2">
                  <span className={`text-xs font-bold px-3 py-1 rounded-full border ${statusColor[booking.status] ?? 'bg-slate-50 text-slate-600 border-slate-200'}`}>
                    {booking.status.toUpperCase()}
                  </span>
                  
                  {booking.payment_status === 'paid' && (
                    <span className="text-xs font-bold px-2 py-1 rounded-full bg-emerald-50 text-emerald-600 border border-emerald-200">
                      💰 Paid
                    </span>
                  )}

                  {booking.status === 'confirmed' && booking.jitsi_room_id && (
                    <button
                      onClick={() => navigate(`/consultation/${booking.patient_id}?bookingId=${booking.id}`)}
                      className="flex items-center gap-1.5 bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-bold px-4 py-2 rounded-xl transition-all shadow-sm"
                    >
                      <Video className="w-3.5 h-3.5" />
                      Join Call
                    </button>
                  )}
                </div>
              </div>

              {/* Meeting URL */}
              {booking.meeting_url && booking.status === 'confirmed' && (
                <div className="mt-2 text-xs text-slate-400 flex items-center gap-1">
                  <Video className="w-3 h-3" />
                  Room: {booking.jitsi_room_id}
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default LiveBookings;
