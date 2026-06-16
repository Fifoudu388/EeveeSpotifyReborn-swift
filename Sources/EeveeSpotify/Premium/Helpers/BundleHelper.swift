import Foundation
import SwiftUI

class BundleHelper {
    private let bundleName = "EeveeSpotify"
    
    private let bundle: Bundle?
    private let enBundle: Bundle?
    
    static let shared = BundleHelper()
    
    private init() {
        let bundlePath = Bundle.main.path(forResource: bundleName, ofType: "bundle")
        self.bundle = bundlePath.flatMap { Bundle(path: $0) }
        self.enBundle = bundle.flatMap { Bundle(path: $0.path(forResource: "en", ofType: "lproj") ?? "") }
    }
    
    func uiImage(_ name: String) -> UIImage? {
        guard let bundle = bundle, let path = bundle.path(forResource: name, ofType: "png") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    
    func localizedString(_ key: String) -> String {
        guard let bundle = bundle else { return key }
        let value = bundle.localizedString(forKey: key, value: "No translation", table: nil)
        
        if value != "No translation" {
            return value
        }
        
        return enBundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
    
    func resolveConfiguration() throws -> ResolveConfiguration {
        guard
            let bundle = bundle,
            let url = bundle.url(forResource: "resolveconfiguration", withExtension: "bnk")
        else {
            throw NSError(domain: "EeveeSpotify", code: 1, userInfo: [NSLocalizedDescriptionKey: "resolveconfiguration.bnk not found"])
        }
        return try ResolveConfiguration(serializedBytes: try Data(contentsOf: url))
    }
}
