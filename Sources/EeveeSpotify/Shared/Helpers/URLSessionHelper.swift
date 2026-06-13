import UIKit
import os

class URLSessionHelper {
    static let shared = URLSessionHelper()
    
    private var requestsMap: [String: Data]
    private let lock: os_unfair_lock_t
    
    private init() {
        self.requestsMap = [:]
        self.lock = .allocate(capacity: 1)
        self.lock.initialize(to: os_unfair_lock())
    }
    
    deinit {
        lock.deinitialize(count: 1)
        lock.deallocate()
    }
    
    static var DarwinVersion: String {
        var sysinfo = utsname()
        uname(&sysinfo)
        let dv = String(
            bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)),
            encoding: .ascii
        )!.trimmingCharacters(in: .controlCharacters)
        return "Darwin/\(dv)"
    }
    
    static var CFNetworkVersion: String {
        let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
        let version = dictionary?["CFBundleShortVersionString"] as! String
        return "CFNetwork/\(version)"
    }
    
    func setOrAppend(_ data: Data, for url: URL) {
        let key = url.absoluteString
        os_unfair_lock_lock(lock)
        var loadedData = requestsMap[key] ?? Data()
        loadedData.append(data)
        requestsMap[key] = loadedData
        os_unfair_lock_unlock(lock)
    }
    
    func obtainData(for url: URL) -> Data? {
        let key = url.absoluteString
        os_unfair_lock_lock(lock)
        let data = requestsMap.removeValue(forKey: key)
        os_unfair_lock_unlock(lock)
        return data
    }
}
