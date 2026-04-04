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
