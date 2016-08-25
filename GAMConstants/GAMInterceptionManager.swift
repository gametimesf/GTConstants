//
//  GAMInterceptionManager.swift
//  Gametime
//
//  Created by Mike Silvis on 6/29/16.
//
//

import UIKit

class GAMInterceptionManager: NSObject {
    static let sharedInstance = GAMInterceptionManager()

    private static let kInterceptionManagerKey = "kInterceptionManagerKey"
    private static let interceptionDefault = "GAMInterceptionManagerDefault"

    typealias HotfixDict = [String : AnyObject]

    private var hotfixes : HotfixDict = [:] {
        didSet {
            GAMInterceptionManager.saveHotfixes(hotfixes)
        }
    }

    override init() {
        super.init()

        hotfixes = GAMInterceptionManager.getSavedHotfixes() ?? [:]
    }

    //
    // MARK : Helper functions
    //

    func hotfixNumForKey(key : String) -> NSNumber? {
        guard let fix = hotfixes[key] as? NSNumber else { return nil }

        return fix
    }

    func hotfixStringForKey(key : String) -> String? {
        guard let fix = hotfixes[key] as? String else { return nil }

        return fix
    }

    func hotfixObjectforKey(key : String) -> AnyObject? {
        guard let fix = hotfixes[key] else { return nil }

        return fix
    }

    func sync() {
        guard let interceptionURL = GAMConstantsManager.sharedInstance.interceptionsURL() else { return }

        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

        let dataTask = defaultSession.dataTaskWithURL(interceptionURL) { [weak self] (data, response, error) in
            guard let data = data,
                let responseObject = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String : AnyObject],
                let hotfixes = responseObject?["hotfixes"] as? HotfixDict
                else { return }

            self?.hotfixes = hotfixes
        }

        dataTask.resume()
    }

    //
    // MARK : Persistence
    //

    private class func getSavedHotfixes() -> HotfixDict? {
        return NSUserDefaults(suiteName: GAMInterceptionManager.interceptionDefault)?.objectForKey(GAMInterceptionManager.kInterceptionManagerKey) as? HotfixDict
    }

    private class func saveHotfixes(hotfixes : HotfixDict?) {
        NSUserDefaults(suiteName : GAMInterceptionManager.interceptionDefault)?.setObject(hotfixes, forKey: GAMInterceptionManager.kInterceptionManagerKey)
    }
}
