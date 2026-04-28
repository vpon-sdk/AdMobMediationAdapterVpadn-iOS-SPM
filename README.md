# AdMobMediationAdapterVpadn

## Introduction

Vpon AdMob mediation adapter for iOS.

The AdMobMediationAdapterVpadn bridges Google Mobile Ads SDK and VpadnSDK, so that the AdMob waterfall and bidding can route banner, interstitial, and native ad requests to Vpon.

AdMobMediationAdapterVpadn is distributed via [Swift Package Manager](https://swift.org/package-manager/).

📄 AdMob Mediation Setup Guide: https://wiki.vpon.com/ios/mediation/admob/  
📄 VpadnSDK Document: http://vpon-sdk.github.io/ios/

---

## Requirements

- iOS 12.0+
- VpadnSDK 5.7.6+
- Google Mobile Ads SDK 12.0+

---

## Installation

### Swift Package Manager

1. In Xcode, go to **File > Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/vpon-sdk/AdMobMediationAdapterVpadn-iOS-SPM
   ```
3. Select version rule **Exact Version** and enter `2.2.0-beta3`
4. Click **Add Package**

> **Note:** Pre-release versions (e.g. `-beta2`) are not picked up by the **Up to Next Major** rule. You must use **Exact Version** to install a beta build.

The adapter automatically pulls in:

- [VpadnSDKAdKit](https://github.com/vpon-sdk/VpadnSDK-iOS-SPM)
- [GoogleMobileAds](https://github.com/googleads/swift-package-manager-google-mobile-ads)

#### ⚠️ Installation Notice

When using Swift Package Manager, Xcode does not automatically inherit binary linker flags.  
You must manually add `-ObjC` to your Target's **Other Linker Flags** to prevent runtime crashes (`Selector not recognized`).

**How to add `-ObjC`:**

1. In Xcode, select your **App Target**
2. Go to **Build Settings** → search for **Other Linker Flags**
3. Add `-ObjC`

> If your project also pulls VpadnSDK or GoogleMobileAds via CocoaPods elsewhere, switch those to Swift Package Manager too — mixing can cause duplicate-symbol linker errors.

---

## AdMob Mediation Setup

Configure Vpon as a mediation source in your AdMob dashboard. For step-by-step instructions (network credentials, custom event class names, parameter mapping), refer to:

📄 https://wiki.vpon.com/ios/mediation/admob/

---

## Usage

After completing AdMob mediation setup, request ads through the standard Google Mobile Ads API — the adapter routes to Vpon transparently when AdMob waterfall / bidding selects it.

```swift
import GoogleMobileAds
```

To pass Vpon-specific request parameters (content URL, content data, friendly obstructions), attach an `Extras` instance to your request:

```swift
import GoogleMobileAds

let request = Request()
let extras = Extras()
extras.additionalParameters = [
    "contentURL": "https://example.com",
    "contentData": ["key1": "value1", "key2": 1.2],
]
request.register(extras)
```

---

## Version Compatibility

| Adapter      | Vpon SDK | Google Mobile Ads |
|--------------|----------|-------------------|
| 2.2.0-beta3  | ≥ 5.7.6  | ≥ 12.0            |

---

## License

Copyright © Vpon Inc. All rights reserved.  
Unauthorized copying, distribution, or use of this SDK is strictly prohibited.  
Use of this SDK is subject to the [Vpon Terms of Service](http://www.vpon.com).
