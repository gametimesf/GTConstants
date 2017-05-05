//
//  GTInterceptionManager.swift
//  Gametime
//
//  Created by Mike Silvis on 6/29/16.
//
//

import UIKit

public class GTInterceptionManager {
    open static let sharedInstance = GTInterceptionManager()

    fileprivate static let kInterceptionManagerKey = "kInterceptionManagerKey"
    fileprivate static let interceptionDefault = "GTInterceptionManagerDefault"

    //
    // MARK : Hotfixes
    //

    typealias HotfixDict = [String : AnyObject]

    fileprivate var hotfixes: HotfixDict = GTInterceptionManager.getSavedHotfixes() {
        didSet {
            GTInterceptionManager.save(hotfixes: hotfixes)
        }
    }

    //
    // MARK : Updates
    //

    fileprivate let updateHelper = GTUpdateHelper()

    public var updateNeeded: Bool {
        return updateHelper.updateNeeded
    }

    public var updateRule: UpdateRule? {
        return updateHelper.updateRule
    }

    //
    // MARK : Maintenance
    //

    public let maintenanceHelper = GTMaintenanceHelper()

    //
    // MARK : Networking States
    //

    public fileprivate(set) var syncState: SyncState = .unstarted {
        didSet {
            updateCompletion()
        }
    }

    public enum SyncState {
        case unstarted
        case pending
        case complete
        case error
    }

    public var dataSyncCompletion: ((SyncState) -> Void)? {
        didSet {
            updateCompletion()
        }
    }

    //
    // MARK : Helper functions
    //

    public func hotFix(key: String) -> NSNumber? {
        guard let fix = hotfixes[key] as? NSNumber else { return nil }

        return fix
    }

    public func hotFix(key: String) -> String? {
        guard let fix = hotfixes[key] as? String else { return nil }

        return fix
    }

    public func hotfix(key: String) -> AnyObject? {
        guard let fix = hotfixes[key] else { return nil }

        return fix
    }

    //
    // MARK : Networking
    //

    func sync() {
        guard let interceptionURL = GTConstantsManager.sharedInstance.interceptionsURL() else { return }
        syncState = .pending

        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil

        let defaultSession = URLSession(configuration: config)

        let dataTask = defaultSession.dataTask(with: interceptionURL, completionHandler: { [weak self] (data, _, error) in

            guard let data = data,
                let responseObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject]
                else { return }

            let iosUpdateData = (responseObject?["update"] as? [String: AnyObject])?["ios"]
            self?.updateHelper.configureUpdateRequirements(withData: iosUpdateData)

            self?.maintenanceHelper.updateWithData((responseObject?["maintenance"] as? [String: AnyObject])?["ios"])

            guard let hotfixes = responseObject?["hotfixes"] as? HotfixDict else {
                self?.syncState = error != nil ? .error : .complete
                return
            }
            self?.hotfixes = hotfixes

            self?.syncState = error != nil ? .error : .complete
        })

        dataTask.resume()
    }

    fileprivate func updateCompletion() {
        DispatchQueue.main.async { [weak self] in
            guard let state = self?.syncState else { return }
            self?.dataSyncCompletion?(state)
        }
    }

    //
    // MARK : Persistence
    //

    fileprivate class func getSavedHotfixes() -> HotfixDict {
        guard let fixes = UserDefaults(suiteName: GTInterceptionManager.interceptionDefault)?.object(forKey: GTInterceptionManager.kInterceptionManagerKey) as? HotfixDict else {
            return [:]
        }

        return fixes
    }

    fileprivate class func save(hotfixes: HotfixDict?) {
        UserDefaults(suiteName : GTInterceptionManager.interceptionDefault)?.set(hotfixes, forKey: GTInterceptionManager.kInterceptionManagerKey)
    }
}
