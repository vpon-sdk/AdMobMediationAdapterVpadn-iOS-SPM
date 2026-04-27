// swift-tools-version:5.3
//
// Package.swift for AdMobMediationAdapterVpadn (Swift Package Manager)
//
// This manifest is mirrored from the development repo to the public SPM repo
// (vpon-sdk/AdMobMediationAdapterVpadn-iOS-SPM) by `release-spm.sh`.
//

import PackageDescription

let package = Package(
    name: "AdMobMediationAdapterVpadn",
    platforms: [
        .iOS(.v12)
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
            from: "5.7.6"
        ),
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads",
            from: "12.0.0"
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
