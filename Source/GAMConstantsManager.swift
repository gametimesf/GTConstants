//
//  GAMConstantsManager.swift
//  Gametime
//
//  Created by Mike Silvis on 8/17/16.
//
//

import UIKit

public struct GAMConstantsManagerConfig {
    public let defaultConfigFile : String
    public let overrideConfigFile : String?
    
    public init(defaultConfigFile : String, overrideConfigFile : String?) {
        self.defaultConfigFile = defaultConfigFile
        self.overrideConfigFile = overrideConfigFile
    }
}

open class GAMConstantsManager: NSObject {
    open static let sharedInstance = GAMConstantsManager()
    
    typealias PlistDict = [String : AnyObject]
    fileprivate var plist : PlistDict = [:]
    
    fileprivate static let interceptionsURLKey = "interceptions_url"
    
    open var config : GAMConstantsManagerConfig? {
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

    fileprivate func setOverrideFile(_ file : String) {
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
    
    internal func interceptionsURL() -> URL? {
        guard interceptionsConfigured() else { return nil }
        
        return URL(string: findFromPlist(GAMConstantsManager.interceptionsURLKey) as! String)
    }

    //
    // MARK: Finders
    //

    open func intForID(_ key : String) -> NSInteger {
        guard let int = findObjectFromKey(key) as? NSInteger else {
            fatalError( "Key is missing : \(key)")
        }

        return int
    }

    open func numberForID(_ key : String) -> NSNumber {
        guard let number = findObjectFromKey(key) as? NSNumber else {
            fatalError( "Key is missing : \(key)")
        }

        return number
    }

    open func boolForID(_ key: String) -> Bool {
        guard let bool = findObjectFromKey(key) as? Bool else {
            fatalError( "Key is missing : \(key)")
        }

        return bool
    }

    open func stringForID(_ key : String) -> String {
        guard let string = findObjectFromKey(key) as? String else {
            fatalError("Key is missing : \(key)")
        }

        return string
    }

    //
    // MARK: Helpers
    //
    
    fileprivate func interceptionsConfigured() -> Bool {
        return (findFromPlist(GAMConstantsManager.interceptionsURLKey) as? String) != nil
    }

    fileprivate func getContentsOfFile(_ file : String) -> PlistDict {
        let path = Bundle.main.url(forResource: file, withExtension: "plist")

        guard let url = path, let plistDictionary = NSDictionary(contentsOf: url) as? PlistDict else {
            return [:]
        }

        return plistDictionary
    }

    fileprivate func findObjectFromKey(_ key : String) -> AnyObject? {
        if let object = findInterceptedObject(key) {
            return object
        }

        return findFromPlist(key)
    }

    fileprivate func findFromPlist(_ key : String) -> AnyObject? {
        guard let _ = config else {
            fatalError("You must provide a config param before accessing the constants manager")
        }
        
        return plist[key]
    }

    fileprivate func findInterceptedObject(_ key : String) -> AnyObject? {
        return GAMInterceptionManager.sharedInstance.hotfixObjectforKey(key)
    }

}

extension String {
    public func constantString() -> String {
        return GAMConstantsManager.sharedInstance.stringForID(self)
    }
}
