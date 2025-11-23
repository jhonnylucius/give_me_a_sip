# ===================================
# 🎯 NetDrinks - ProGuard Rules
# ===================================
# Compatível com Android 15+ (16KB)
# Flutter 3.27 + Firebase + Google Sign-In
# ===================================

# ===================================
# 📦 FLUTTER CORE
# ===================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# ===================================
# 🎮 GOOGLE PLAY CORE
# ===================================
# CRÍTICO para deferred components e split install
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# ===================================
# 🔥 FIREBASE
# ===================================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firestore
-keep class com.google.firebase.firestore.** { *; }
-keepclassmembers class com.google.firebase.firestore.** { *; }

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-keepclassmembers class com.google.firebase.auth.** { *; }

# Firebase Storage
-keep class com.google.firebase.storage.** { *; }
-keepclassmembers class com.google.firebase.storage.** { *; }

# ===================================
# 🔐 GOOGLE SIGN-IN
# ===================================
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keepclassmembers class com.google.android.gms.auth.** { *; }

# ===================================
# �️ SQFLITE - Banco de dados local
# ===================================
-keep class com.tekartik.sqflite.** { *; }

# ===================================
# 💾 SHARED PREFERENCES
# ===================================
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$Editor { *; }

# ===================================
# 📁 PATH PROVIDER
# ===================================
-keep class io.flutter.plugins.pathprovider.** { *; }

# ===================================
# 📤 SHARE PLUS
# ===================================
-keep class dev.fluttercommunity.plus.share.** { *; }

# ===================================
# 🌐 URL LAUNCHER
# ===================================
-keep class io.flutter.plugins.urllauncher.** { *; }

# ===================================
# 🔔 FLUTTER LOCAL NOTIFICATIONS
# ===================================
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# ===================================
# 📱 ANDROID CORE
# ===================================
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# ===================================
# 🎨 UI COMPONENTS
# ===================================
# Mantém construtores de views customizadas
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# ===================================
# 🗃️ GSON - Serialização
# ===================================
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# ===================================
# 🔄 REFLECTION - Manter anotações
# ===================================
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# ===================================
# 🎯 NATIVE METHODS - Não ofuscar JNI
# ===================================
-keepclasseswithmembernames class * {
    native <methods>;
}

# ===================================
# 📊 ENUMS - Manter integridade
# ===================================
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ===================================
# 📦 PARCELABLE - Android IPC
# ===================================
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# ===================================
# 💾 SERIALIZABLE - Java serialization
# ===================================
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ===================================
# 🔧 KOTLIN
# ===================================
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# ===================================
# 🌐 NETWORKING
# ===================================
# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ===================================
# ⚡ R8 OPTIMIZATIONS - Compatibilidade 16KB
# ===================================
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# ===================================
# ⚠️ WARNINGS - Suprimir avisos conhecidos
# ===================================
-dontwarn com.google.android.gms.**
-dontwarn com.google.common.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
