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
    
    static let adapterVersion = "2.2.0"
    static let limitVponSDKVersion = "5.7.6"
    
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
        log("Admob Version: \(MobileAds.shared.versionNumber)")
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
        let requiredVersion = requiredVersion.replacingOccurrences(of: "vpadn-sdk-i-v", with: "")
        let actualVersion = actualVersion.replacingOccurrences(of: "vpadn-sdk-i-v", with: "")
        
        let requiredComponents = requiredVersion.components(separatedBy: ".")
        let actualComponents = actualVersion.components(separatedBy: ".")
        
        for index in 0 ..< requiredComponents.count {
            guard actualComponents.count > index else {
                break
            }
            let requiredSplitVersion = requiredComponents[index]
            let actualSplitVersion = actualComponents[index]
            let result = requiredSplitVersion.compare(actualSplitVersion, options: .numeric)
            if result == .orderedAscending {
                break
            } else if result == .orderedSame {
                continue
            } else {
                return false
            }
        }
        return true
    }
    
    static func defaultError() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "No ads", NSLocalizedFailureReasonErrorKey: "No ads"]
        return NSError(domain: ERROR_DOMAIN, code: -999, userInfo: userInfo)
    }
    
    static func log(_ message: String) {
        print("<VPON> [NOTE] [Mediation] \(message)")
    }
    
    static func adapterVersionNumber() -> VersionNumber {
        let components = adapterVersion.split(separator: ".").map { Int($0) ?? 0 }
        let major = components.count > 0 ? components[0] : 0
        let minor = components.count > 1 ? components[1] : 0
        let patch = components.count > 2 ? components[2] : 0

        return VersionNumber(majorVersion: major, minorVersion: minor, patchVersion: patch)
    }

    
    static func adSdkVersionNumber() -> VersionNumber {
        let versionString = VponAdConfiguration.sdkVersion()
        let cleaned = versionString.trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
        let components = cleaned.split(separator: ".").map { Int($0) ?? 0 }
        let major = components.count > 0 ? components[0] : 0
        let minor = components.count > 1 ? components[1] : 0
        let patch = components.count > 2 ? components[2] : 0
        
        return VersionNumber(majorVersion: major, minorVersion: minor, patchVersion: patch)
    }
    
    static func createRequest(from adConfiguration: MediationAdConfiguration) -> VponAdRequest {
        let request = VponAdRequest()

        // 1. Seed contentData with adapter-reserved metadata. Integrator-supplied
        //    content data (from Extras) is merged on top, so integrator keys
        //    always win on collision.
        let admobVersion = MobileAds.shared.versionNumber
        var contentData: [String: Any] = [
            contentDataAdapterVersionKey: adapterVersion,
            contentDataAdMobSDKVersionKey: "\(admobVersion.majorVersion).\(admobVersion.minorVersion).\(admobVersion.patchVersion)",
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

