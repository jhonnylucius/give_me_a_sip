package com.luciano.appdrinks

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import androidx.core.view.WindowCompat

class MainActivity: FlutterActivity(){
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Habilita edge-to-edge
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}