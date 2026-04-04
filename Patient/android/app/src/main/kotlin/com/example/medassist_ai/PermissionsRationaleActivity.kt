package com.example.medassist_ai

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

/**
 * Activity required by Health Connect to display the app's privacy policy
 * and permissions rationale when the user views health data permissions
 * in device settings.
 *
 * This is mandatory for Health Connect apps — without it, the permissions
 * system may silently deny access.
 */
class PermissionsRationaleActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Simply finish — the Flutter app handles privacy policy display.
        // For production, you would display a proper privacy policy screen here.
        finish()
    }
}
