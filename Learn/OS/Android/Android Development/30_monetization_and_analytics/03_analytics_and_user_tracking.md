## Analytics and User Tracking


Analytics systems collect, process, and analyze user behavior data to inform product decisions and optimize user experience. Firebase Analytics provides comprehensive tracking capabilities integrated with the Google ecosystem.

**Key Points:**

- Event tracking captures user interactions and app usage patterns
- Custom parameters provide context for events and enable detailed analysis
- User properties segment users based on characteristics and behaviors
- Privacy compliance requires careful handling of personally identifiable information

**Firebase Analytics Setup:**

```kotlin
class AnalyticsTracker(private val context: Context) {
    
    private val firebaseAnalytics = FirebaseAnalytics.getInstance(context)
    
    fun trackEvent(eventName: String, parameters: Bundle = Bundle()) {
        firebaseAnalytics.logEvent(eventName, parameters)
    }
    
    fun trackScreenView(screenName: String, screenClass: String) {
        val bundle = Bundle().apply {
            putString(FirebaseAnalytics.Param.SCREEN_NAME, screenName)
            putString(FirebaseAnalytics.Param.SCREEN_CLASS, screenClass)
        }
        firebaseAnalytics.logEvent(FirebaseAnalytics.Event.SCREEN_VIEW, bundle)
    }
    
    fun trackPurchase(
        transactionId: String,
        currency: String,
        value: Double,
        items: List<AnalyticsItem>
    ) {
        val bundle = Bundle().apply {
            putString(FirebaseAnalytics.Param.TRANSACTION_ID, transactionId)
            putString(FirebaseAnalytics.Param.CURRENCY, currency)
            putDouble(FirebaseAnalytics.Param.VALUE, value)
            putParcelableArray(FirebaseAnalytics.Param.ITEMS, items.toTypedArray())
        }
        firebaseAnalytics.logEvent(FirebaseAnalytics.Event.PURCHASE, bundle)
    }
    
    fun setUserProperty(name: String, value: String) {
        firebaseAnalytics.setUserProperty(name, value)
    }
    
    fun setUserId(userId: String) {
        firebaseAnalytics.setUserId(userId)
    }
}
```

**Custom Event Tracking:**

```kotlin
object AnalyticsEvents {
    const val FEATURE_USED = "feature_used"
    const val CONTENT_SHARED = "content_shared"
    const val TUTORIAL_COMPLETED = "tutorial_completed"
    const val SEARCH_PERFORMED = "search_performed"
}

class UserActionTracker(private val analyticsTracker: AnalyticsTracker) {
    
    fun trackFeatureUsage(featureName: String, source: String) {
        val bundle = Bundle().apply {
            putString("feature_name", featureName)
            putString("source", source)
            putLong("timestamp", System.currentTimeMillis())
        }
        analyticsTracker.trackEvent(AnalyticsEvents.FEATURE_USED, bundle)
    }
    
    fun trackContentShare(contentType: String, method: String) {
        val bundle = Bundle().apply {
            putString(FirebaseAnalytics.Param.CONTENT_TYPE, contentType)
            putString(FirebaseAnalytics.Param.METHOD, method)
        }
        analyticsTracker.trackEvent(AnalyticsEvents.CONTENT_SHARED, bundle)
    }
    
    fun trackSearchQuery(query: String, resultsCount: Int) {
        val bundle = Bundle().apply {
            putString(FirebaseAnalytics.Param.SEARCH_TERM, query)
            putInt("results_count", resultsCount)
        }
        analyticsTracker.trackEvent(AnalyticsEvents.SEARCH_PERFORMED, bundle)
    }
}
```

