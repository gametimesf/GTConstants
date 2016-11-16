//
//  GTInterceptionManager.swift
//  Gametime
//
//  Created by Mike Silvis on 6/29/16.
//
//

import UIKit

open class GTInterceptionManager: NSObject {
    open static let sharedInstance = GTInterceptionManager()
    
    fileprivate static let kInterceptionManagerKey = "kInterceptionManagerKey"
    fileprivate static let interceptionDefault = "GTInterceptionManagerDefault"
    
    typealias HotfixDict = [String : AnyObject]
    
    fileprivate var hotfixes : HotfixDict = [:] {
        didSet {
            GTInterceptionManager.saveHotfixes(hotfixes)
        }
    }

    override init() {
        super.init()
        
        hotfixes = GTInterceptionManager.getSavedHotfixes() ?? [:]
    }

    //
    // MARK : Helper functions
    //

    open func hotfixNumForKey(_ key : String) -> NSNumber? {
        guard let fix = hotfixes[key] as? NSNumber else { return nil }

        return fix
    }

    open func hotfixStringForKey(_ key : String) -> String? {
        guard let fix = hotfixes[key] as? String else { return nil }

        return fix
    }

    open func hotfixObjectforKey(_ key : String) -> AnyObject? {
        guard let fix = hotfixes[key] else { return nil }

        return fix
    }

    open func sync() {
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
    
    fileprivate class func getSavedHotfixes() -> HotfixDict? {
        return UserDefaults(suiteName: GTInterceptionManager.interceptionDefault)?.object(forKey: GTInterceptionManager.kInterceptionManagerKey) as? HotfixDict
    }
    
    fileprivate class func saveHotfixes(_ hotfixes : HotfixDict?) {
        UserDefaults(suiteName : GTInterceptionManager.interceptionDefault)?.set(hotfixes, forKey: GTInterceptionManager.kInterceptionManagerKey)
    }
}
