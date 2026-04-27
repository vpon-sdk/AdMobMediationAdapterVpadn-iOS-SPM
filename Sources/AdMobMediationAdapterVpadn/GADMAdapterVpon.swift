import Foundation
import GoogleMobileAds
import VpadnSDKAdKit

@objc(GADMAdapterVpon)
public class GADMAdapterVpon: NSObject, MediationAdapter {

    private var activeAds = NSHashTable<NSObject>.weakObjects()

    public required override init() {
        VponAdRequestConfiguration.shared.mediationProvider = .ADMOB
        super.init()
    }

    public static func adapterVersion() -> VersionNumber {
        return VponAdapterInfo.adapterVersionNumber()
    }

    public static func adSDKVersion() -> VersionNumber {
        return VponAdapterInfo.adSdkVersionNumber()
    }

    public static func networkExtrasClass() -> (any AdNetworkExtras.Type)? {
        return Extras.self
    }

    public static func setUp(
            with configuration: MediationServerConfiguration,
            completionHandler: @escaping GADMediationAdapterSetUpCompletionBlock
        ) {
            print("[GADMAdapterVpon]: setUp calls...")

            // 通知 AdMob 初始化完成
            completionHandler(nil)
        }

    public func loadBanner(
        for adConfiguration: MediationBannerAdConfiguration,
        completionHandler: @escaping GADMediationBannerLoadCompletionHandler
    ) {
        VponAdapterInfo.adapterNote()
        let bannerAd = GADMAdapterVponBannerAd()
        activeAds.add(bannerAd)
        
        bannerAd.loadBannerAd(for: adConfiguration) {
            [weak self] ad, error in
            if error != nil {
                self?.activeAds.remove(bannerAd)
            }
            return completionHandler(ad, error)
        }
    }

    public func loadInterstitial(
        for adConfiguration: MediationInterstitialAdConfiguration,
        completionHandler:
            @escaping GADMediationInterstitialLoadCompletionHandler
    ) {
        VponAdapterInfo.adapterNote()

        let interstitialAd = GADMAdapterVponInterstitialAd()
        activeAds.add(interstitialAd)

        interstitialAd.loadInterstitial(for: adConfiguration) {
            [weak self] ad, error in
            if error != nil {
                self?.activeAds.remove(interstitialAd)
            }
            return completionHandler(ad, error)
        }
    }
}
