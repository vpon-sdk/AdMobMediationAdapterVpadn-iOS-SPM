//
//  GADMAdapterVponInterstitialAd.swift
//  Pods
//
//  Created by Roman Yu on 2026/1/6.
//

import Foundation
import GoogleMobileAds
import VpadnSDKAdKit

public class GADMAdapterVponInterstitialAd: NSObject, MediationInterstitialAd {

    private weak var delegate: MediationInterstitialAdEventDelegate?

    private var vponInterstitialAd: VponInterstitialAd?

    private var loadCompletionHandler:
        GADMediationInterstitialLoadCompletionHandler?

    // MARK: - GADMediationInterstitialAd Protocol Requirement

    public func loadInterstitial(
        for adConfiguration: MediationInterstitialAdConfiguration,
        completionHandler:
            @escaping GADMediationInterstitialLoadCompletionHandler
    ) {

        self.loadCompletionHandler = completionHandler
        
        if !VponAdapterInfo.verifyVersion() {
            let error = VponAdapterInfo.defaultError()
            self.loadCompletionHandler = nil
            _ = completionHandler(nil, error)
            return
        }

        let licenseKey =
            adConfiguration.credentials.settings[VponAdapterInfo.displayAdAdUnitIDKey] as? String ?? ""

        let request = createVponRequest(from: adConfiguration)

        VponInterstitialAd.load(licenseKey: licenseKey, request: request) {
            [weak self] (ad, error) in
            guard let self = self else { return }
            guard let handler = self.loadCompletionHandler else { return }
            self.loadCompletionHandler = nil

            if let error = error {
                _ = handler(nil, error)
                return
            }

            guard let ad = ad else {
                _ = handler(nil, VponAdapterInfo.defaultError())
                return
            }

            self.vponInterstitialAd = ad
            ad.delegate = self
            self.delegate = handler(self, nil)
        }
    }

    public func present(from viewController: UIViewController) {
        if let ad = vponInterstitialAd {
            ad.present(fromRootViewController: viewController)
        } else {
            let error = NSError(
                domain: VponAdapterInfo.ERROR_DOMAIN,
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Ad not ready"]
            )
            delegate?.didFailToPresentWithError(error)
        }
    }

    // MARK: - Private Helpers

    private func createVponRequest(
        from config: MediationInterstitialAdConfiguration
    ) -> VponAdRequest {
        return VponAdapterInfo.createRequest(from: config)
    }
}

// MARK: - VponFullScreenContentDelegate

extension GADMAdapterVponInterstitialAd: VponFullScreenContentDelegate {

    public func adWillPresentScreen(_ interstitial: VponFullScreenContentAd) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.willPresentFullScreenView()
        }
    }

    public func adWillDismissScreen(_ interstitial: VponFullScreenContentAd) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.willDismissFullScreenView()
        }
    }

    public func adDidDismissScreen(_ interstitial: VponFullScreenContentAd) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didDismissFullScreenView()
            self?.vponInterstitialAd = nil
        }
    }

    public func adDidRecordClick(_ interstitial: VponFullScreenContentAd) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.reportClick()
        }
    }

    public func adDidRecordImpression(_ interstitial: VponFullScreenContentAd) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.reportImpression()
        }
    }

    public func ad(_ interstitial: VponFullScreenContentAd, didFailToPresentFullScreenContentWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didFailToPresentWithError(error)
            self?.vponInterstitialAd = nil
        }
    }
}
