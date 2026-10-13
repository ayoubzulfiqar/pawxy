# Flutter Keep Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugins.** { *; }

# Suppress missing class warnings for deferred components and annotations
-dontwarn com.google.android.play.core.**
-dontwarn javax.annotation.**
-dontwarn com.wireguard.**

# WireGuard Keep Rules
-keep class com.wireguard.** { *; }
-keep class com.tunnel.** { *; }
-keep class com.wireguard.android.backend.** { *; }
