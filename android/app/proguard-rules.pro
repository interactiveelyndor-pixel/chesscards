# AppLovin MAX Proguard Keep & Suppress Rules
-keep class com.applovin.** { *; }
-dontwarn com.applovin.**

# Amazon PrivacyPass (optional attestation library referenced by omid)
-dontwarn com.amazon.privacypass.**
-dontwarn com.iab.omid.library.applovin.**
