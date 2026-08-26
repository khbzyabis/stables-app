# My Stables — R8/ProGuard keep rules for release builds.
# Flutter and most plugins ship their own consumer rules; these are conservative
# extras for the reflection-using libraries we depend on.

# Flutter embedding
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Supabase / ktor / kotlinx-serialization (used by supabase_flutter's native side
# via method channels; keep annotations to be safe)
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod

# Sentry
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# PostHog
-keep class com.posthog.** { *; }
-dontwarn com.posthog.**

# Keep model classes that may be (de)serialized reflectively
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
