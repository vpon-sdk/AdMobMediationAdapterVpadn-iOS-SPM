//
//  GADMAdapterVponBannerAd.swift
//  Pods
//
//  Created by Roman Yu on 2026/1/5.
//

import AdSupport
import Foundation
import GoogleMobileAds
import VpadnSDKAdKit

public class GADMAdapterVponBannerAd: NSObject, MediationBannerAd {

    private weak var delegate: MediationBannerAdEventDelegate?

    private var vponBannerView: VponBannerView?

    private var loadCompletionHandler: GADMediationBannerLoadCompletionHandler?

    // MARK: - MediationBannerAd Protocol Requirement

    public var view: UIView {
        return vponBannerView ?? UIView()
    }

    // MARK: - Load Ad

    public func loadBannerAd(
        for adConfiguration: MediationBannerAdConfiguration,
        completionHandler: @escaping GADMediationBannerLoadCompletionHandler
    ) {

        self.loadCompletionHandler = completionHandler

        if !VponAdapterInfo.verifyVersion() {
            let error = VponAdapterInfo.defaultError()
            self.loadCompletionHandler = nil
            _ = completionHandler(nil, error)
            return
        }

        let licenseKey =
            adConfiguration.credentials.settings[
                VponAdapterInfo.displayAdAdUnitIDKey
            ] as? String ?? ""

        let adSize = adConfiguration.adSize
        var vponAdSize: VponAdSize
        if isAdSizeEqualToSize(size1: adSize, size2: AdSizeFluid)
            || isAdSizeEqualToSize(size1: adSize, size2: AdSizeInvalid)
            || isAdSizeEqualToSize(size1: adSize, size2: AdSizeSkyscraper)
        {

            let error = NSError(
                domain: VponAdapterInfo.ERROR_DOMAIN,
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Unsupported ad size: \(string(for: adSize))"
                ]
            )
            self.loadCompletionHandler = nil
            _ = completionHandler(nil, error)
            return
        }

        if isAdSizeEqualToSize(size1: adSize, size2: AdSizeBanner) {
            vponAdSize = .banner()
        } else if isAdSizeEqualToSize(size1: adSize, size2: AdSizeFullBanner) {
            vponAdSize = .fullBanner()
        } else if isAdSizeEqualToSize(size1: adSize, size2: AdSizeLargeBanner) {
            vponAdSize = .largeBanner()
        } else if isAdSizeEqualToSize(size1: adSize, size2: AdSizeLeaderboard) {
            vponAdSize = .leaderBoard()
        } else if isAdSizeEqualToSize(
            size1: adSize,
            size2: AdSizeMediumRectangle
        ) {
            vponAdSize = .mediumRectangle()
        } else {
            if [VponNetworkId.SKM, VponNetworkId.SKM].contains(
                VponAdRequestConfiguration.shared.networkId
            ) {
                vponAdSize = VponAdSize(size: adSize.size)
            } else {
                vponAdSize = getMappedSize(for: adSize)
            }
        }

        vponBannerView = VponBannerView(adSize: vponAdSize)
        vponBannerView?.licenseKey = licenseKey
        vponBannerView?.delegate = self

        let request = createVponRequest(from: adConfiguration)

        vponBannerView?.load(request)
    }
}

// MARK: - Private Helpers (Logic from your old code)

extension GADMAdapterVponBannerAd {

    private func getMappedSize(for gadAdSize: AdSize) -> VponAdSize {
        let width = gadAdSize.size.width
        let height = gadAdSize.size.height

        if width >= 320 && height >= 480 { return .largeRectangle() }
        if width >= 300 && height >= 250 { return .mediumRectangle() }
        if width >= 728 && height >= 90 { return .leaderBoard() }
        if width >= 468 && height >= 60 { return .fullBanner() }
        if width >= 320 && height >= 100 { return .largeBanner() }
        return .banner()
    }

    private func createVponRequest(from config: MediationBannerAdConfiguration)
        -> VponAdRequest
    {
        return VponAdapterInfo.createRequest(from: config)
    }
}

// MARK: - VponBannerViewDelegate

extension GADMAdapterVponBannerAd: VponBannerViewDelegate {

    public func bannerViewDidReceiveAd(_ bannerView: VponBannerView) {

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let handler = self.loadCompletionHandler
            else { return }
            self.delegate = handler(self, nil)
            self.loadCompletionHandler = nil
        }
    }

    public func bannerView(
        _ bannerView: VponBannerView,
        didFailToReceiveAdWithError error: Error
    ) {

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            _ = self.loadCompletionHandler?(nil, error)
            self.loadCompletionHandler = nil
            self.vponBannerView = nil
        }
    }

    public func bannerViewDidRecordClick(_ bannerView: VponBannerView) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.reportClick()
        }
    }
    public func bannerViewDidRecordImpression(_ bannerView: VponBannerView) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.reportImpression()
        }
    }
}
