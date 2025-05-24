-keep class com.example.flow_weather.** { *; }
-keep class io.flutter.** { *; }

-keep class com.google.android.gms.** { *; }

-keep class okhttp3.** { *; }
-dontwarn okio.**

-keepattributes *Annotation*

# Keep Google Play Core classes for Deferred Components
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**