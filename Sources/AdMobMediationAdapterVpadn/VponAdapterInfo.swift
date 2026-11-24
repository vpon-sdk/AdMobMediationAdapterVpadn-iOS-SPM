//
//  VponAdapterInfo.swift
//  Pods
//
//  Created by Roman Yu on 2026/1/13.
//
import VpadnSDKAdKit
import GoogleMobileAds

struct VponAdapterInfo {
    
    // MARK: - Constants
    
    static let adapterVersion = "3.0.0"
    static let limitVponSDKVersion = "5.8.0"
    
    /// "parameter"
    static let nativeAdAdUnitIDKey = "parameter"
    static let displayAdAdUnitIDKey = "pubid"
    static let ERROR_DOMAIN = "com.vpon.vpadnsdk"

    // Reserved contentData keys injected by this adapter on every Vpon ad
    // request, so Vpon backend can correlate the request with the adapter
    // and AdMob SDK versions in use. Underscore prefix marks them as
    // adapter-reserved; integrator-supplied content data with the same key
    // wins (we never overwrite integrator data).
    private static let contentDataAdapterVersionKey = "_vpon_admob_adapter_version"
    private static let contentDataAdMobSDKVersionKey = "_vpon_admob_sdk_version"
    
    struct ExtrasKey {
        
        /// "Vpon"
        static let labelName = "Vpon"
        /// "contentURL"
        static let contentURL = "contentURL"
        /// "contentData"
        static let contentData = "contentData"
        /// "friendlyObstructions"
        static let friendlyObstructions = "friendlyObstructions"
        /// "view"
        static let friendlyObstructionsView = "view"
        /// "purpose"
        static let friendlyObstructionsPurpose = "purpose"
        /// "desc"
        static let friendlyObstructionsDesc = "desc"
    }
    
    // MARK: - Helpers
    
    static func adapterNote() {
        log("Admob Version: \(string(for: MobileAds.shared.versionNumber))")
        log("Adapter Version: \(adapterVersion)")
    }

    static func verifyVersion() -> Bool {
        let result = inspectVersion(VponAdConfiguration.sdkVersion(), isLargerEqualThanVersion: limitVponSDKVersion)
        if !result {
            log("The version of VpadnSDKAdKit must be greater than \(limitVponSDKVersion)")
        }
        return result
    }

    static func inspectVersion(_ actualVersion: String, isLargerEqualThanVersion requiredVersion: String) -> Bool {
        return !versionComponents(actualVersion).lexicographicallyPrecedes(versionComponents(requiredVersion))
    }

    /// Parses a version string into exactly [major, minor, patch].
    ///
    /// Accepts the raw VpadnSDK format ("vpadn-sdk-i-v5.8.0"), a "v" prefix,
    /// and pre-release / build suffixes ("2.3.0-beta1", "5.8.0+abc"): anything
    /// before the first digit and after the first "-" / "+" is dropped.
    /// Missing or non-numeric components become 0. A pre-release therefore
    /// compares equal to its release (5.8.0-alpha1 == 5.8.0).
    static func versionComponents(_ version: String) -> [Int] {
        guard let start = version.firstIndex(where: { ("0"..."9").contains($0) }) else {
            return [0, 0, 0]
        }
        var core = version[start...]
        if let suffix = core.firstIndex(where: { $0 == "-" || $0 == "+" }) {
            core = core[..<suffix]
        }
        var components = core.split(separator: ".").prefix(3).map { Int($0) ?? 0 }
        while components.count < 3 {
            components.append(0)
        }
        return components
    }

    static func versionNumber(from version: String) -> VersionNumber {
        let components = versionComponents(version)
        return VersionNumber(majorVersion: components[0], minorVersion: components[1], patchVersion: components[2])
    }
    
    static func defaultError() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "No ads", NSLocalizedFailureReasonErrorKey: "No ads"]
        return NSError(domain: ERROR_DOMAIN, code: -999, userInfo: userInfo)
    }
    
    static func log(_ message: String) {
        print("<VPON> [NOTE] [Mediation] \(message)")
    }
    
    static func adapterVersionNumber() -> VersionNumber {
        return versionNumber(from: adapterVersion)
    }

    static func adSdkVersionNumber() -> VersionNumber {
        // sdkVersion() returns "vpadn-sdk-i-v5.8.0"; versionComponents strips the prefix.
        return versionNumber(from: VponAdConfiguration.sdkVersion())
    }
    
    static func createRequest(from adConfiguration: MediationAdConfiguration) -> VponAdRequest {
        let request = VponAdRequest()

        // 1. Seed contentData with adapter-reserved metadata. Integrator-supplied
        //    content data (from Extras) is merged on top, so integrator keys
        //    always win on collision.
        var contentData: [String: Any] = [
            contentDataAdapterVersionKey: adapterVersion,
            contentDataAdMobSDKVersionKey: string(for: MobileAds.shared.versionNumber),
        ]

        // 2. Process Extras (provided by adConfiguration.extras)
        if let extras = adConfiguration.extras as? Extras,
           let params = extras.additionalParameters {

            // --- Content Data (merge over adapter metadata) ---
            if let integratorContentData = params[ExtrasKey.contentData] as? [String: Any] {
                integratorContentData.forEach { contentData[$0.key] = $0.value }
            }

            // --- Content URL ---
            if let contentUrl = params[ExtrasKey.contentURL] as? String {
                request.setContentUrl(contentUrl)
            }

            // --- Friendly Obstructions ---
            if let friendlyObs = params[ExtrasKey.friendlyObstructions] as? [[String: Any]] {
                for item in friendlyObs {
                    guard let view = item[ExtrasKey.friendlyObstructionsView] as? UIView,
                          let desc = item[ExtrasKey.friendlyObstructionsDesc] as? String else {
                        continue
                    }

                    var purpose: VponFriendlyObstructionType = .other
                    if let rawPurpose = item[ExtrasKey.friendlyObstructionsPurpose] as? Int {
                        purpose = VponAdObstruction.getVponPurpose(rawPurpose)
                    }
                    request.addFriendlyObstruction(view, purpose: purpose, description: desc)
                }
            }
        }

        request.setContentData(contentData)
        return request
    }
}

