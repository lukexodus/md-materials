## Google Play Console Setup


Google Play Console is the primary platform for publishing, managing, and analyzing Android applications on the Google Play Store.

**Key Points:**

- **Developer Account**: One-time $25 registration fee required
- **App Creation**: Set up app details, content rating, and target audience
- **Store Listing**: App metadata, descriptions, screenshots, and promotional materials
- **Release Management**: Internal testing, closed testing, open testing, and production releases
- **App Content**: Privacy policy, data safety, and content declarations
- **Monetization**: In-app purchases, subscriptions, and ads configuration

**Example Setup Process:**

```kotlin
// App-level configuration for Play Console
android {
    defaultConfig {
        // Ensure these match your Play Console app
        applicationId "com.example.myapp" // Must be unique
        versionCode 1 // Increment for each release
        versionName "1.0.0" // User-facing version
        
        // Required for Play Console
        targetSdk 34 // Must target recent API level
        
        // Declare required features
        manifestPlaceholders["appAuthRedirectScheme"] = applicationId
    }
    
    // Play Console requires specific configurations
    bundle {
        language {
            enableSplit = true
        }
    }
}

dependencies {
    // Play Core library for in-app updates and reviews
    implementation "com.google.android.play:core:1.10.3"
    implementation "com.google.android.play:core-ktx:1.8.1"
    
    // Play Install Referrer
    implementation "com.android.installreferrer:installreferrer:2.2"
    
    // Play Billing for in-app purchases
    implementation "com.android.billingclient:billing:6.0.1"
    implementation "com.android.billingclient:billing-ktx:6.0.1"
}
```

```xml
<!-- AndroidManifest.xml configurations for Play Console -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    
    <!-- Required permissions should be minimal -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Declare hardware requirements -->
    <uses-feature
        android:name="android.hardware.camera"
        android:required="false" />
    
    <application
        android:name=".MyApplication"
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:label="@string/app_name"
        android:theme="@style/Theme.MyApp"
        android:localeConfig="@xml/locales_config"
        tools:targetApi="33">
        
        <!-- Deep linking for Play Console -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop">
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="https"
                    android:host="example.com" />
            </intent-filter>
        </activity>
        
        <!-- Required for Play Console app links verification -->
        <meta-data
            android:name="asset_statements"
            android:resource="@string/asset_statements" />
    </application>
</manifest>
```

```json
// Play Console Data Safety declarations example
{
  "data_collection": {
    "collects_data": true,
    "data_types": [
      {
        "category": "personal_info",
        "types": ["email", "name"],
        "purposes": ["account_management", "app_functionality"],
        "optional": false,
        "shared_with_third_parties": false
      },
      {
        "category": "app_activity",
        "types": ["app_interactions", "crash_logs"],
        "purposes": ["analytics", "app_functionality"],
        "optional": true,
        "shared_with_third_parties": true
      }
    ]
  },
  "security_practices": {
    "data_encrypted_in_transit": true,
    "data_encrypted_at_rest": true,
    "user_can_request_deletion": true,
    "user_can_request_data": true,
    "independent_security_review": false
  }
}
```

