// swift-tools-version:5.3
//
// Package.swift for AdMobMediationAdapterVpadn (Swift Package Manager)
//
// This manifest is mirrored from the development repo to the public SPM repo
// (vpon-sdk/AdMobMediationAdapterVpadn-iOS-SPM) by `ci/publish-spm.sh`.
//

import PackageDescription

let package = Package(
    name: "AdMobMediationAdapterVpadn",
    platforms: [
        // String form: `.v16` needs swift-tools-version 5.7+, this manifest is 5.3.
        .iOS("16.0")
    ],
    products: [
        .library(
            name: "AdMobMediationAdapterVpadn",
            targets: ["AdMobMediationAdapterVpadn"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/vpon-sdk/VpadnSDK-iOS-SPM",
            // 5.8.x only: a later minor (e.g. 5.9) may need a new adapter release.
            // ci/lib.sh reads the lower bound from the next line; keep this form.
            .upToNextMinor(from: "5.8.2")
        ),
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads",
            "12.0.0"..<"14.0.0"
        ),
    ],
    targets: [
        .target(
            name: "AdMobMediationAdapterVpadn",
            dependencies: [
                .product(
                    name: "VpadnSDKAdKit",
                    package: "VpadnSDK-iOS-SPM"
                ),
                .product(
                    name: "GoogleMobileAds",
                    package: "swift-package-manager-google-mobile-ads"
                ),
            ],
            path: "Sources/AdMobMediationAdapterVpadn"
        ),
    ]
)
