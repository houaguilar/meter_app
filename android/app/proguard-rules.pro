# Flutter specific rules
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Prevent obfuscation for commonly used classes like MainActivity
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }

#-keep class dev.isar.isar_flutter_libs.BuildConfig { *; }
-dontwarn dev.isar.isar_flutter_libs.BuildConfig


# Rules for Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Retain classes used by some third-party libraries
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# Retain the Parcelable interface for Android's framework
-keepclassmembers class ** implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Retain all enum values and don't obfuscate them
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Retain class names and members for Gson or similar libraries used for JSON serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class * implements java.io.Serializable {
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private static final long serialVersionUID;
}

# Keep custom views
-keep class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# If you use Retrofit or similar libraries
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }

-keep class kotlinx.** { *; }
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

