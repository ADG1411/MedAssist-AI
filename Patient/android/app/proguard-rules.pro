-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keepattributes JavascriptInterface
-keepattributes *Annotation*

-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}

-optimizations !method/inlining/*

-keepclasseswithmembers class * {
  public void onPayment*(...);
}

# Health Connect SDK — prevent R8 from stripping
-keep class androidx.health.connect.** { *; }
-keep class androidx.health.platform.** { *; }
-dontwarn androidx.health.**

# ── Jitsi Meet Flutter SDK ───────────────────────────────────────────────────
# Keep all Jitsi classes (critical for release builds — R8 strips these without this)
-keep class org.jitsi.** { *; }
-keep class org.webrtc.** { *; }
-dontwarn org.jitsi.**
-dontwarn org.webrtc.**

# Keep ReactNative bridge classes used by Jitsi SDK
-keep class com.facebook.react.** { *; }
-dontwarn com.facebook.react.**

# Keep Jitsi BroadcastReceiver + Event classes
-keep class org.jitsi.meet.sdk.** { *; }
-keep class org.jitsi.meet.sdk.BroadcastIntentHelper { *; }
-keep class org.jitsi.meet.sdk.JitsiMeetActivity { *; }
-keep class org.jitsi.meet.sdk.JitsiMeetBaseActivity { *; }
-keep class org.jitsi.meet.sdk.JitsiMeetConferenceOptions { *; }
-keep class org.jitsi.meet.sdk.JitsiMeetUserInfo { *; }
-keep class org.jitsi.meet.sdk.JitsiMeetViewListener { *; }

# Keep EventBus if used by Jitsi
-keepattributes Signature
-keepattributes EnclosingMethod

# Keep OkHttp (used by Jitsi for signalling)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Keep Jitsi's Flipper/Metro debug bridge from being stripped
-dontwarn com.facebook.flipper.**
-dontwarn com.facebook.hermes.**
-dontwarn com.facebook.jni.**
