//
//  GAMConstantsManager.swift
//  Gametime
//
//  Created by Mike Silvis on 8/17/16.
//
//

import UIKit

struct GAMConstantsManagerConfig {
    let defaultConfigFile : String
    let overrideConfigFile : String?
}

class GAMConstantsManager: NSObject {
    static let sharedInstance = GAMConstantsManager()
    
    typealias PlistDict = [String : AnyObject]
    private var plist : PlistDict = [:]
    
    private static let interceptionsURLKey = "interceptions_url"
    
    var config : GAMConstantsManagerConfig? {
        didSet {
            guard let config = config else { return }
            
            plist = getContentsOfFile(config.defaultConfigFile)
            
            if let overrideFile = config.overrideConfigFile {
                setOverrideFile(overrideFile)
            }
            
            if interceptionsConfigured() {
                GAMInterceptionManager.sharedInstance.sync()
            }
        }
    }

    private func setOverrideFile(file : String) {
        let updatedPlist = getContentsOfFile(file)

        for key in updatedPlist.keys {
            guard let newSetting = updatedPlist[key] else { return }

            print("Overriding default setting key: \(key)")

            plist[key] = newSetting
        }
    }
    
    //
    // MARK: Interceptions
    //
    
    func interceptionsURL() -> NSURL? {
        guard interceptionsConfigured() else { return nil }
        
        return NSURL(string: findFromPlist(GAMConstantsManager.interceptionsURLKey) as! String)
    }

    //
    // MARK: Finders
    //

    func intForID(key : String) -> NSInteger {
        guard let int = findObjectFromKey(key) as? NSInteger else {
            fatalError( "Key is missing : \(key)")
        }

        return int
    }

    func numberForID(key : String) -> NSNumber {
        guard let number = findObjectFromKey(key) as? NSNumber else {
            fatalError( "Key is missing : \(key)")
        }

        return number
    }

    func boolForID(key: String) -> Bool {
        guard let bool = findObjectFromKey(key) as? Bool else {
            fatalError( "Key is missing : \(key)")
        }

        return bool
    }

    func stringForID(key : String) -> String {
        guard let string = findObjectFromKey(key) as? String else {
            fatalError("Key is missing : \(key)")
        }

        return string
    }

    //
    // MARK: Helpers
    //
    
    private func interceptionsConfigured() -> Bool {
        return (findFromPlist(GAMConstantsManager.interceptionsURLKey) as? String) != nil
    }

    private func getContentsOfFile(file : String) -> PlistDict {
        let path = NSBundle.mainBundle().URLForResource(file, withExtension: "plist")

        guard let url = path, let plistDictionary = NSDictionary(contentsOfURL: url) as? PlistDict else {
            return [:]
        }

        return plistDictionary
    }

    private func findObjectFromKey(key : String) -> AnyObject? {
        if let object = findInterceptedObject(key) {
            return object
        }

        return findFromPlist(key)
    }

    private func findFromPlist(key : String) -> AnyObject? {
        guard let _ = config else {
            fatalError("You must provide a config param before accessing the constants manager")
        }
        
        return plist[key]
    }

    private func findInterceptedObject(key : String) -> AnyObject? {
        return GAMInterceptionManager.sharedInstance.hotfixObjectforKey(key)
    }

}

extension String {
    func constantString() -> String {
        return (GAMConstantsManager.sharedInstance.stringForID(self) ?? self)
    }
}
