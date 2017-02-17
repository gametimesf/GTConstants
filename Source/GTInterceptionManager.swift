//
//  GTInterceptionManager.swift
//  Gametime
//
//  Created by Mike Silvis on 6/29/16.
//
//

import UIKit

open class GTInterceptionManager {
    open static let sharedInstance = GTInterceptionManager()
    
    fileprivate static let kInterceptionManagerKey = "kInterceptionManagerKey"
    fileprivate static let interceptionDefault = "GTInterceptionManagerDefault"
    
    typealias HotfixDict = [String : AnyObject]
    
    fileprivate var hotfixes : HotfixDict = GTInterceptionManager.getSavedHotfixes() {
        didSet {
            GTInterceptionManager.save(hotfixes: hotfixes)
        }
    }

    //
    // MARK : Helper functions
    //

    func hotFix(key : String) -> NSNumber? {
        guard let fix = hotfixes[key] as? NSNumber else { return nil }

        return fix
    }

    public func hotFix(key : String) -> String? {
        guard let fix = hotfixes[key] as? String else { return nil }

        return fix
    }

    func hotfix(key : String) -> AnyObject? {
        guard let fix = hotfixes[key] else { return nil }

        return fix
    }

    func sync() {
        guard let interceptionURL = GTConstantsManager.sharedInstance.interceptionsURL() else { return }
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let dataTask = defaultSession.dataTask(with: interceptionURL, completionHandler: { [weak self] (data, response, error) in
            guard let data = data,
                let responseObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject],
                let hotfixes = responseObject?["hotfixes"] as? HotfixDict
                else { return }
            
            self?.hotfixes = hotfixes
        }) 
        
        dataTask.resume()
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
    
    fileprivate class func save(hotfixes : HotfixDict?) {
        UserDefaults(suiteName : GTInterceptionManager.interceptionDefault)?.set(hotfixes, forKey: GTInterceptionManager.kInterceptionManagerKey)
    }
}
