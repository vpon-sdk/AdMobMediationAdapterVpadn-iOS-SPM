//
//  GADVpadnNativeAdCustomEvent.swift
//  Pods
//
//  Created by Roman Yu on 2026/1/7.
//

import AdSupport
import GoogleMobileAds
import VpadnSDKAdKit

@objc(GADVpadnNativeAdCustomEvent)
public class GADVpadnNativeAdCustomEvent: NSObject, MediationAdapter,
    MediationNativeAd
{

    required public override init() {
        super.init()
    }

    // MARK: - Properties
    private var vponNativeAd: VponNativeAd?
    private weak var delegate: MediationNativeAdEventDelegate?
    private var completionHandler: GADMediationNativeLoadCompletionHandler?

    private var mappedMediaView: VponMediaView = VponMediaView()
    private weak var adContainer: UIView?
    private var registerViewTimer: Timer?

    private var iconImage: NativeAdImage?
    private var coverImages: [NativeAdImage]?

    // MARK: - GADMediationNativeAd Mapping (資產映射)
    public var headline: String? { return vponNativeAd?.headline }
    public var body: String? { return vponNativeAd?.body }
    public var callToAction: String? { return vponNativeAd?.callToAction }
    public var icon: NativeAdImage? { return iconImage }
    public var images: [NativeAdImage]? { return coverImages }
    public var mediaView: UIView? { return mappedMediaView }
    public var hasVideoContent: Bool {
        return vponNativeAd?.mediaContent?.hasVideoContent ?? false
    }
    public var advertiser: String? { return vponNativeAd?.advertise }

    public var starRating: NSDecimalNumber? { return nil }
    public var store: String? { return nil }
    public var price: String? { return nil }
    public var extraAssets: [String: Any]? {
        if let social = vponNativeAd?.socialContext {
            return ["socialContext": social]
        }
        return nil
    }

    // MARK: - GADMediationAdapter (入口方法)
    public static func adapterVersion() -> VersionNumber {
        return VponAdapterInfo.adapterVersionNumber()
    }

    public static func adSDKVersion() -> VersionNumber {
        return VponAdapterInfo.adSdkVersionNumber()
    }

    public static func networkExtrasClass() -> AdNetworkExtras.Type? {
        return Extras.self
    }

    public static func setUp(
        with configuration: MediationServerConfiguration,
        completionHandler: @escaping GADMediationAdapterSetUpCompletionBlock
    ) {
        completionHandler(nil)
    }

    public func loadNativeAd(
        for adConfiguration: MediationNativeAdConfiguration,
        completionHandler: @escaping GADMediationNativeLoadCompletionHandler
    ) {
        VponAdapterInfo.adapterNote()
        self.completionHandler = completionHandler

        if !VponAdapterInfo.verifyVersion() {
            let error = VponAdapterInfo.defaultError()
            self.completionHandler = nil
            _ = completionHandler(nil, error)
            return
        }

        let licenseKey =
            adConfiguration.credentials.settings[
                VponAdapterInfo.nativeAdAdUnitIDKey
            ] as? String ?? ""

        let adLoader = VponNativeAdLoader(
            licenseKey: licenseKey,
            rootViewController: nil
        )
        adLoader.delegate = self
        adLoader.load(VponAdapterInfo.createRequest(from: adConfiguration))
    }

    // MARK: - Interaction handles
    public func handlesUserClicks() -> Bool { return true }
    public func handlesUserImpressions() -> Bool { return true }

    public func didRender(
        in view: UIView,
        clickableAssetViews: [GADNativeAssetIdentifier: UIView],
        nonclickableAssetViews: [GADNativeAssetIdentifier: UIView],
        viewController: UIViewController
    ) {
        self.adContainer = view
        self.mappedMediaView.mediaContent = vponNativeAd?.mediaContent
        self.vponNativeAd?.loadMediaView(mappedMediaView)
        startRegisterViewTimer()
    }

    // ✅ 修復 1：新增 didUntrackView
    public func didUntrackView(_ view: UIView?) {
        mappedMediaView.unregisterAllEvents()
        registerViewTimer?.invalidate()
        registerViewTimer = nil
        adContainer = nil
    }

    // ✅ 修復 2：新增 didRecordClickOnAsset
    public func didRecordClickOnAsset(
        withName assetName: GADNativeAssetIdentifier,
        view: UIView,
        viewController: UIViewController
    ) {
        vponNativeAd?.clickHandler(view)
    }
}

// MARK: - Vpon SDK Helper Logic
extension GADVpadnNativeAdCustomEvent {

    private func startRegisterViewTimer() {
        registerViewTimer?.invalidate()
        registerViewTimer = nil

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let timer = Timer(timeInterval: 0.2, repeats: false) { [weak self] _ in
                guard let self = self, let container = self.adContainer else {
                    return
                }
                if container.superview != nil {
                    self.vponNativeAd?.registerAdView(container)
                } else {
                    self.startRegisterViewTimer()
                }
            }
            RunLoop.main.add(timer, forMode: .common)
            self.registerViewTimer = timer
        }
    }

    private func loadImages(for nativeAd: VponNativeAd) {
        // 如果沒有任何圖片需要載入，直接完成
        if nativeAd.icon == nil && nativeAd.coverImage == nil {
            successCompletion()
            return
        }

        let group = DispatchGroup()
        var downloadedIcon: UIImage?
        var downloadedCover: UIImage?

        if let iconURL = nativeAd.icon?.imageURL {
            group.enter()
            downloadImage(from: iconURL) { img in
                downloadedIcon = img
                group.leave()
            }
        }

        let imgExtensions = ["png", "jpg", "jpeg"]
        if let coverURL = nativeAd.coverImage?.imageURL,
            imgExtensions.contains(coverURL.pathExtension)
        {
            group.enter()
            downloadImage(from: coverURL) { img in
                downloadedCover = img
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            if let img = downloadedIcon {
                self.iconImage = NativeAdImage(image: img)
            }
            if let img = downloadedCover {
                self.coverImages = [NativeAdImage(image: img)]
            }
            self.successCompletion()
        }
    }

    private func successCompletion() {
        guard let completionHandler = self.completionHandler else { return }
        self.delegate = completionHandler(self, nil)
        self.completionHandler = nil
    }

    private func downloadImage(
        from url: URL,
        completion: @escaping (UIImage?) -> Void
    ) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}

// MARK: - VponNativeAdLoaderDelegate & VponNativeAdDelegate
extension GADVpadnNativeAdCustomEvent: VponNativeAdLoaderDelegate,
    VponNativeAdDelegate
{
    public func adLoader(
        _ adLoader: VponNativeAdLoader,
        didReceive nativeAd: VponNativeAd
    ) {
        self.vponNativeAd = nativeAd
        self.vponNativeAd?.delegate = self
        loadImages(for: nativeAd)
    }

    public func adLoader(
        _ adLoader: VponNativeAdLoader,
        didFailToReceiveAdWithError error: Error
    ) {
        DispatchQueue.main.async {
            _ = self.completionHandler?(nil, error)
            self.completionHandler = nil
        }
    }

    public func nativeAdDidRecordImpression(_ nativeAd: VponNativeAd) {
        DispatchQueue.main.async { self.delegate?.reportImpression() }
    }

    public func nativeAdDidRecordClick(_ nativeAd: VponNativeAd) {
        DispatchQueue.main.async { self.delegate?.reportClick() }
    }
}
