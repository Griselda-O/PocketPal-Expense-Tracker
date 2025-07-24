package com.example.pocketpal

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity(), UserApi {
    private var userDetails: PigeonUserDetails? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        UserApi.setUp(flutterEngine.dartExecutor.binaryMessenger, this)
    }

    override fun getUserDetails(): PigeonUserDetails {
        // Return dummy or real user details
        return userDetails ?: PigeonUserDetails("Your Name", "your@email.com", "1234567890")
    }

    override fun registerUser(details: PigeonUserDetails) {
        userDetails = details
    }
}
