## User Engagement Metrics


User engagement metrics measure how users interact with the application, providing insights into user satisfaction, feature adoption, and retention patterns.

**Key Points:**

- Session metrics track app usage frequency and duration
- Retention metrics measure user return behavior over time
- Feature adoption metrics identify successful and underperforming features
- Custom engagement scores can combine multiple metrics for holistic measurement

**Session Tracking:**

```kotlin
class SessionTracker(private val analyticsTracker: AnalyticsTracker) {
    
    private var sessionStartTime: Long = 0
    private var isSessionActive = false
    
    fun startSession() {
        if (!isSessionActive) {
            sessionStartTime = System.currentTimeMillis()
            isSessionActive = true
            
            val bundle = Bundle().apply {
                putLong("session_start_time", sessionStartTime)
            }
            analyticsTracker.trackEvent("session_start", bundle)
        }
    }
    
    fun endSession() {
        if (isSessionActive) {
            val sessionDuration = System.currentTimeMillis() - sessionStartTime
            val bundle = Bundle().apply {
                putLong("session_duration", sessionDuration)
                putLong("session_end_time", System.currentTimeMillis())
            }
            analyticsTracker.trackEvent("session_end", bundle)
            
            isSessionActive = false
        }
    }
    
    fun trackScreenTime(screenName: String, timeSpent: Long) {
        val bundle = Bundle().apply {
            putString("screen_name", screenName)
            putLong("time_spent", timeSpent)
        }
        analyticsTracker.trackEvent("screen_time", bundle)
    }
}
```

**Engagement Metrics Calculator:**

```kotlin
class EngagementMetrics(private val analyticsTracker: AnalyticsTracker) {
    
    fun calculateDAU(): Int {
        // [Unverified] Implementation would query analytics backend
        // for daily active users count
        return 0
    }
    
    fun calculateRetentionRate(cohortStartDate: Long, dayN: Int): Double {
        // [Unverified] Implementation would calculate percentage of users
        // from cohort who returned on day N
        return 0.0
    }
    
    fun trackUserEngagementScore(
        userId: String,
        sessionCount: Int,
        averageSessionDuration: Long,
        featuresUsed: Int,
        daysActive: Int
    ) {
        // Calculate engagement score based on multiple factors
        val engagementScore = calculateEngagementScore(
            sessionCount,
            averageSessionDuration,
            featuresUsed,
            daysActive
        )
        
        val bundle = Bundle().apply {
            putString("user_id", userId)
            putInt("session_count", sessionCount)
            putLong("avg_session_duration", averageSessionDuration)
            putInt("features_used", featuresUsed)
            putInt("days_active", daysActive)
            putDouble("engagement_score", engagementScore)
        }
        
        analyticsTracker.trackEvent("user_engagement_calculated", bundle)
        analyticsTracker.setUserProperty("engagement_score", engagementScore.toString())
    }
    
    private fun calculateEngagementScore(
        sessionCount: Int,
        averageSessionDuration: Long,
        featuresUsed: Int,
        daysActive: Int
    ): Double {
        // [Inference] Weighted scoring algorithm combining multiple engagement factors
        val sessionWeight = 0.3
        val durationWeight = 0.25
        val featureWeight = 0.25
        val frequencyWeight = 0.2
        
        val normalizedSessions = minOf(sessionCount / 10.0, 1.0)
        val normalizedDuration = minOf(averageSessionDuration / 300000.0, 1.0) // 5 minutes max
        val normalizedFeatures = minOf(featuresUsed / 5.0, 1.0)
        val normalizedFrequency = minOf(daysActive / 7.0, 1.0)
        
        return (normalizedSessions * sessionWeight +
                normalizedDuration * durationWeight +
                normalizedFeatures * featureWeight +
                normalizedFrequency * frequencyWeight) * 100
    }
}
```

**Funnel Analysis:**

```kotlin
class FunnelTracker(private val analyticsTracker: AnalyticsTracker) {
    
    fun trackFunnelStep(
        funnelName: String,
        stepName: String,
        stepIndex: Int,
        userId: String? = null
    ) {
        val bundle = Bundle().apply {
            putString("funnel_name", funnelName)
            putString("step_name", stepName)
            putInt("step_index", stepIndex)
            userId?.let { putString("user_id", it) }
            putLong("timestamp", System.currentTimeMillis())
        }
        analyticsTracker.trackEvent("funnel_step", bundle)
    }
    
    fun trackFunnelCompletion(funnelName: String, userId: String? = null) {
        val bundle = Bundle().apply {
            putString("funnel_name", funnelName)
            putString("status", "completed")
            userId?.let { putString("user_id", it) }
        }
        analyticsTracker.trackEvent("funnel_completion", bundle)
    }
    
    fun trackFunnelDropoff(
        funnelName: String,
        exitStep: String,
        userId: String? = null
    ) {
        val bundle = Bundle().apply {
            putString("funnel_name", funnelName)
            putString("exit_step", exitStep)
            putString("status", "dropped_off")
            userId?.let { putString("user_id", it) }
        }
        analyticsTracker.trackEvent("funnel_dropoff", bundle)
    }
}
```

**Examples:** A comprehensive monetization and analytics implementation might track user progression through an onboarding funnel, measure feature adoption rates after A/B testing different UI approaches, correlate engagement metrics with purchase behavior, and use rewarded video ads to increase user retention while maintaining positive user experience.

**Output:** [Inference] Successful monetization and analytics strategies require balancing revenue generation with user experience, ensuring privacy compliance, and making data-driven decisions based on reliable metrics and statistically significant test results.

Related important subtopics include privacy compliance (GDPR, CCPA), revenue optimization strategies, advanced analytics platforms (Mixpanel, Amplitude), attribution tracking, and cross-platform analytics synchronization.

---

