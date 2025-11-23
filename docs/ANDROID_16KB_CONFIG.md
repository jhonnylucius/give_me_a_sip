# 📱 Configuração Android 15+ (16KB Page Size)

## ✅ Configurações Aplicadas

### 1. **gradle.properties**
```properties
android.enableNativeLibraryPageAlignment=true
```
- ✅ Alinha bibliotecas nativas para páginas de 16KB
- ✅ Compatível com Android 15+ (API 35)
- ✅ Sem impacto em dispositivos mais antigos

---

### 2. **build.gradle (app)**
```gradle
defaultConfig {
    // ... configs existentes ...
    
    // Suporte a 16KB page size (Android 15+)
    externalNativeBuild {
        cmake {
            arguments "-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON"
        }
    }
}

buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}

// Packaging para 16KB page size
packagingOptions {
    jniLibs {
        useLegacyPackaging = true
    }
}
```
- ✅ ProGuard ativado
- ✅ Otimização de código
- ✅ Remoção de recursos não utilizados
- ✅ **ANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON** ativado
- ✅ **useLegacyPackaging=true** configurado

---

### 3. **proguard-rules.pro**
Regras completas incluindo:
- ✅ Flutter Core
- ✅ Firebase (Auth, Firestore, Storage)
- ✅ Google Sign-In
- ✅ Kotlin
- ✅ Bibliotecas nativas (16KB)
- ✅ Otimizações de produção

---

## 🚀 Como Testar

### 1. **Build Local**
```bash
cd appdrinks
flutter clean
flutter pub get
flutter build appbundle --release
```

### 2. **Verificar Alinhamento 16KB**
```bash
# Windows PowerShell - Localizar zipalign no seu SDK
# Caminho típico: C:\Users\[USER]\AppData\Local\Android\Sdk\build-tools\[VERSION]\zipalign.exe

# Verificar APK (após flutter build apk --release)
zipalign -c -p -v 16 build\app\outputs\flutter-apk\app-release.apk

# Verificar AAB (após flutter build appbundle --release)
zipalign -c -p -v 16 build\app\outputs\bundle\release\app-release.aab

# ✅ Saída esperada: "Verification successful"
```

---

## 📊 Especificações do Build

| Item | Valor |
|------|-------|
| **compileSdk** | 35 |
| **targetSdk** | 35 |
| **minSdk** | 23 |
| **NDK** | 27.0.12077973 |
| **Gradle** | 8.3.0 |
| **Flutter** | 3.27 |

---

## ✅ Checklist Google Play

- [x] `android.enableNativeLibraryPageAlignment=true`
- [x] `targetSdk = 35`
- [x] ProGuard configurado
- [x] NDK atualizado (27.x)
- [x] Regras Firebase completas
- [x] Otimizações ativadas
- [x] **ANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON**
- [x] **useLegacyPackaging=true**

---

## 🎯 Resultado Esperado

### Na Google Play Console:
- ✅ Sem avisos de compatibilidade 16KB
- ✅ APK/AAB aceito normalmente
- ✅ Suporte a todos os dispositivos Android 15+

### No App:
- ✅ Firebase funcionando
- ✅ Google Sign-In funcionando
- ✅ Performance otimizada
- ✅ Tamanho reduzido

---

## 🔧 Troubleshooting

### Erro: "Native library not aligned"
```bash
# Verificar se a flag está ativa:
cat android/gradle.properties | grep pageAlignment
```

### Build falhando
```bash
# Limpar tudo:
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### ProGuard removendo código necessário
- Adicione regras específicas em `proguard-rules.pro`
- Teste com: `flutter build appbundle --release`

---

## 📚 Referências

- [Android 16KB Page Size](https://developer.android.com/guide/practices/page-sizes)
- [Flutter ProGuard](https://docs.flutter.dev/deployment/android#enabling-proguard)
- [NDK Page Alignment](https://developer.android.com/ndk/guides/page-sizes)

---

## 🎉 Próximos Passos

1. ✅ Fazer um build de teste
2. ✅ Testar no Internal Testing (Google Play)
3. ✅ Verificar logs do Firebase
4. ✅ Promover para produção

---

**Data:** 17 de outubro de 2025  
**App:** NetDrinks  
**Status:** ✅ Configurado e pronto para produção


flutter run
ou
flutter build apk --release

# Para verificar compatibilidade 16KB (após build)
# Localize o zipalign no Android SDK:
# C:\Users\[USER]\AppData\Local\Android\Sdk\build-tools\[VERSION]\zipalign.exe
zipalign -c -p -v 16 build\app\outputs\flutter-apk\app-release.apk


&"C:\Users\[USER]\AppData\Local\Android\Sdk\build-tools\30.0.3\zipalign.exe" -c -p -v 16 build\app\outputs\flutter-apk\app-release.apk
```

C:\Users\[USER]\AppData\Local\Android\Sdk\build-tools\30.0.3\zipalign.exe -c -p -v 16 build\app\outputs\bundle\release\app-release.aab
