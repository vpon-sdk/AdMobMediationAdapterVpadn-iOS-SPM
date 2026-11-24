# AdMobMediationAdapterVpadn

[English](README.en.md) | 繁體中文

## 簡介

Vpon 的 iOS AdMob 中介（mediation）adapter。

AdMobMediationAdapterVpadn 串接 Google Mobile Ads SDK 與 VpadnSDK，讓 AdMob 的 waterfall 與 bidding 可以把 Banner、插頁、原生廣告的請求導向 Vpon。

AdMobMediationAdapterVpadn 以 [Swift Package Manager](https://swift.org/package-manager/) 提供。

📄 AdMob 中介設定指南：https://wiki.vpon.com/ios/mediation/admob/  
📄 VpadnSDK 文件：http://vpon-sdk.github.io/ios/

> [!IMPORTANT]
> **選擇版本**
>
> - **App 最低支援 iOS 16.0 以上**：使用 adapter **3.0.0**，版本規則選 *Up to Next Major Version*、從 `3.0.0` 開始。支援 Google Mobile Ads 12.x – 13.x 與 VpadnSDK 5.8.x（5.8.2 以上）。目前使用 2.2.x 的話，請把規則改成從 `3.0.0` 開始；*Up to Next Major* 不會自動從 2.x 升到 3.x。
> - **App 仍需支援 iOS 12–15**：使用 adapter **2.2.1**，版本規則選 *Up to Next Major Version*、從 `2.2.1` 開始。VpadnSDK 限定 5.8.0，Google Mobile Ads 為 12.x。
> - **請不要使用 adapter 2.2.0。** 它接受任何 VpadnSDK 5.x，包括需要 iOS 16.0 以上的版本，解析套件時可能因最低平台版本不符而無法建置。請改用 `2.2.1` 或 `3.0.0`，或在 App 加入 `https://github.com/vpon-sdk/VpadnSDK-iOS-SPM` 並指定 *Exact Version* `5.8.0`。

---

## 需求

- iOS 16.0 以上
- VpadnSDK 5.8.x（5.8.2 以上）。VpadnSDK 5.8.x 的更新，更新套件即可取得。
- Google Mobile Ads SDK 12.x – 13.x

---

## 安裝

### Swift Package Manager

1. 在 Xcode 選擇 **File > Add Package Dependencies**
2. 輸入套件網址：
   ```
   https://github.com/vpon-sdk/AdMobMediationAdapterVpadn-iOS-SPM
   ```
3. 版本規則選 **Up to Next Major Version**，輸入 `3.0.0`
4. 按 **Add Package**

Adapter 會自動一起加入：

- [VpadnSDKAdKit](https://github.com/vpon-sdk/VpadnSDK-iOS-SPM)
- [GoogleMobileAds](https://github.com/googleads/swift-package-manager-google-mobile-ads)

#### ⚠️ 安裝注意事項

使用 Swift Package Manager 時，Xcode 不會自動套用 binary 需要的 linker flag。  
請在 Target 的 **Other Linker Flags** 手動加入 `-ObjC`，否則執行時會閃退（`Selector not recognized`）。

**加入 `-ObjC` 的方式：**

1. 在 Xcode 選擇您的 **App Target**
2. 到 **Build Settings**，搜尋 **Other Linker Flags**
3. 加入 `-ObjC`

> 如果專案的其他地方也用 CocoaPods 安裝了 VpadnSDK 或 GoogleMobileAds，請一併改用 Swift Package Manager——混用可能造成連結時的重複符號錯誤。

---

## 從 CocoaPods 移轉

CocoaPods 上的最後一版是 adapter 2.2.0；2.2.1 之後只以 Swift Package Manager 提供。

如果專案目前使用 `pod 'AdMobMediationAdapterVpadn'`，請刪除這個 pod、執行 `pod install` 清除，再依上方[安裝](#安裝)的步驟以 SPM 加入套件。

---

## AdMob 中介設定

請在 AdMob 後台把 Vpon 設定為中介來源。詳細步驟（聯播網憑證、custom event class 名稱、參數對應）請參考：

📄 https://wiki.vpon.com/ios/mediation/admob/

---

## 使用方式

完成 AdMob 中介設定後，照一般 Google Mobile Ads API 請求廣告即可；當 AdMob 的 waterfall／bidding 選中 Vpon 時，adapter 會自動處理。

```swift
import GoogleMobileAds
```

要傳入 Vpon 專用的請求參數（content URL、content data、friendly obstructions），請在請求加上 `Extras`：

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

## 版本相容性

| Adapter | 最低 iOS | VpadnSDK          | Google Mobile Ads | 備註 |
|---------|----------|-------------------|-------------------|------|
| 3.0.0   | 16.0     | 5.8.x（≥ 5.8.2）  | 12.x – 13.x       |      |
| 2.2.1   | 12.0     | 5.8.0             | 12.x              | 給需要支援 iOS 12–15 的 App |
| 2.2.0   | 12.0     | ≥ 5.7.6（5.x）    | 12.x              | 可能解析到需要 iOS 16.0 的 VpadnSDK 版本——請改用 2.2.1 或 3.0.0 |

`3.0.0` 已以 VpadnSDK 5.8.2 搭配 Google Mobile Ads SDK 12.0.0 與 13.13.0 建置，並以 VpadnSDK 5.8.2 與 Google Mobile Ads SDK 13.13.0 透過 AdMob 中介測試（Xcode 27.2）。

---

## 修改與授權

本 repository 的原始碼僅供檢視與除錯。依 LICENSE，修改或再散佈須取得 Vpon 書面授權。問題回報、功能建議或授權相關詢問，請聯絡 <fae@vpon.com>。

---

## License

Copyright © Vpon Inc. All rights reserved.  
Unauthorized copying, distribution, or use of this SDK is strictly prohibited.  
Use of this SDK is subject to the [Vpon Terms of Service](http://www.vpon.com).
