package com.noahfares.fitness_app

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity, not FlutterActivity: Health Connect permission
// requests (`F-HLT-001`, `F-HLT-002`) use registerForActivityResult, which
// needs an activity castable to ComponentActivity — FlutterActivity isn't.
class MainActivity : FlutterFragmentActivity()
