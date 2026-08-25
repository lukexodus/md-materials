## Advertisement Integration


Advertisement integration provides revenue through display ads, interstitial ads, rewarded video ads, and native ads. Google AdMob is the primary advertising platform for Android apps.

**Key Points:**

- Different ad formats serve different use cases and user experiences
- Ad loading should be handled asynchronously to avoid blocking UI
- User consent management is required for personalized ads under privacy regulations
- Ad mediation can optimize revenue by competing multiple ad networks

**AdMob Setup:**

```kotlin
class AdManager(private val context: Context) {
    
    init {
        MobileAds.initialize(context) { initializationStatus ->
            // AdMob initialization complete
        }
    }
    
    fun loadBannerAd(adView: AdView) {
        val adRequest = AdRequest.Builder().build()
        adView.loadAd(adRequest)
    }
    
    fun loadInterstitialAd(callback: (InterstitialAd?) -> Unit) {
        val adRequest = AdRequest.Builder().build()
        
        InterstitialAd.load(
            context,
            "ca-app-pub-3940256099942544/1033173712", // Test ad unit ID
            adRequest,
            object : InterstitialAdLoadCallback() {
                override fun onAdLoaded(interstitialAd: InterstitialAd) {
                    callback(interstitialAd)
                }
                
                override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                    callback(null)
                }
            }
        )
    }
}
```

**Rewarded Video Ads:**

```kotlin
class RewardedAdManager(private val context: Context) {
    
    private var rewardedAd: RewardedAd? = null
    
    fun loadRewardedAd() {
        val adRequest = AdRequest.Builder().build()
        
        RewardedAd.load(
            context,
            "ca-app-pub-3940256099942544/5224354917",
            adRequest,
            object : RewardedAdLoadCallback() {
                override fun onAdLoaded(ad: RewardedAd) {
                    rewardedAd = ad
                    setupRewardedAdCallbacks()
                }
                
                override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                    rewardedAd = null
                }
            }
        )
    }
    
    fun showRewardedAd(
        activity: Activity,
        onUserRewarded: (RewardItem) -> Unit
    ) {
        rewardedAd?.show(activity) { rewardItem ->
            onUserRewarded(rewardItem)
            loadRewardedAd() // Preload next ad
        }
    }
    
    private fun setupRewardedAdCallbacks() {
        rewardedAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                rewardedAd = null
            }
            
            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                rewardedAd = null
            }
        }
    }
}
```

**Native Ads Implementation:**

```kotlin
class NativeAdLoader(
    private val context: Context,
    private val onAdLoaded: (NativeAd) -> Unit
) {
    
    private val adLoader = AdLoader.Builder(context, "ca-app-pub-3940256099942544/2247696110")
        .forNativeAd { nativeAd ->
            onAdLoaded(nativeAd)
        }
        .withAdListener(object : AdListener() {
            override fun onAdFailedToLoad(adError: LoadAdError) {
                // Handle ad load failure
            }
        })
        .build()
    
    fun loadAd() {
        adLoader.loadAd(AdRequest.Builder().build())
    }
}

fun populateNativeAdView(nativeAd: NativeAd, adView: NativeAdView) {
    adView.headlineView = adView.findViewById(R.id.ad_headline)
    adView.bodyView = adView.findViewById(R.id.ad_body)
    adView.iconView = adView.findViewById(R.id.ad_icon)
    
    (adView.headlineView as TextView).text = nativeAd.headline
    (adView.bodyView as TextView).text = nativeAd.body
    (adView.iconView as ImageView).setImageDrawable(nativeAd.icon?.drawable)
    
    adView.setNativeAd(nativeAd)
}
```

