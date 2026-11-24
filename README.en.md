# AdMobMediationAdapterVpadn

English | [繁體中文](README.md)

## Introduction

Vpon AdMob mediation adapter for iOS.

The AdMobMediationAdapterVpadn bridges Google Mobile Ads SDK and VpadnSDK, so that the AdMob waterfall and bidding can route banner, interstitial, and native ad requests to Vpon.

AdMobMediationAdapterVpadn is distributed via [Swift Package Manager](https://swift.org/package-manager/).

📄 AdMob Mediation Setup Guide: https://wiki.vpon.com/ios/mediation/admob/  
📄 VpadnSDK Document: http://vpon-sdk.github.io/ios/

> [!IMPORTANT]
> **Choosing a version**
>
> - **Apps with a minimum deployment target of iOS 16.0+**: use adapter **3.0.0** with the *Up to Next Major Version* rule starting at `3.0.0`. It supports Google Mobile Ads 12.x – 13.x and VpadnSDK 5.8.x (5.8.2 or later). If you are on 2.2.x, change the rule to start at `3.0.0`; *Up to Next Major* does not move from 2.x to 3.x by itself.
> - **Apps that support iOS 12–15**: use adapter **2.2.1** with the *Up to Next Major Version* rule starting at `2.2.1`. It is limited to VpadnSDK 5.8.0 and Google Mobile Ads 12.x.
> - **Do not use adapter 2.2.0.** It accepts any VpadnSDK 5.x, including versions that require iOS 16.0+, so resolving packages can fail with a minimum-platform error. Use `2.2.1` or `3.0.0`, or add `https://github.com/vpon-sdk/VpadnSDK-iOS-SPM` to your app with *Exact Version* `5.8.0`.

---

## Requirements

- iOS 16.0+
- VpadnSDK 5.8.x (5.8.2 or later). VpadnSDK 5.8.x updates are picked up by updating packages.
- Google Mobile Ads SDK 12.x – 13.x

---

## Installation

### Swift Package Manager

1. In Xcode, go to **File > Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/vpon-sdk/AdMobMediationAdapterVpadn-iOS-SPM
   ```
3. Select version rule **Up to Next Major Version** and enter `3.0.0`
4. Click **Add Package**

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

## Migration from CocoaPods

Adapter 2.2.0 is the last version on CocoaPods; 2.2.1 and later are distributed via Swift Package Manager only.

If your project currently uses `pod 'AdMobMediationAdapterVpadn'`, remove the pod entry, run `pod install` to clean up, and follow the [Installation](#installation) instructions above to add the package via SPM.

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

| Adapter | Minimum iOS | VpadnSDK          | Google Mobile Ads | Notes |
|---------|-------------|-------------------|-------------------|-------|
| 3.0.0   | 16.0        | 5.8.x (≥ 5.8.2)   | 12.x – 13.x       |       |
| 2.2.1   | 12.0        | 5.8.0             | 12.x              | For apps that support iOS 12–15 |
| 2.2.0   | 12.0        | ≥ 5.7.6 (5.x)     | 12.x              | May resolve to a VpadnSDK version that requires iOS 16.0 — use 2.2.1 or 3.0.0 |

`3.0.0` has been built against VpadnSDK 5.8.2 with Google Mobile Ads SDK 12.0.0 and 13.13.0, and tested through AdMob mediation with VpadnSDK 5.8.2 and Google Mobile Ads SDK 13.13.0 (Xcode 27.2).

---

## Modifications

Source files in this repository are visible for inspection and debugging purposes. Per the LICENSE, modification or redistribution requires written authorization from Vpon. For bug reports, feature requests, or licensing inquiries, please contact <fae@vpon.com>.

---

## License

Copyright © Vpon Inc. All rights reserved.  
Unauthorized copying, distribution, or use of this SDK is strictly prohibited.  
Use of this SDK is subject to the [Vpon Terms of Service](http://www.vpon.com).
