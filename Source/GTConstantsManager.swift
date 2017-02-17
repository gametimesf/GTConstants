//
//  GTConstantsManager.swift
//  Gametime
//
//  Created by Mike Silvis on 8/17/16.
//
//

import UIKit

public struct GTConstantsManagerConfig {
    public let defaultConfigFile: String
    public let overrideConfigFile: [String]

    public init(defaultConfigFile: String, overrideConfigFile: [String]) {
        self.defaultConfigFile = defaultConfigFile
        self.overrideConfigFile = overrideConfigFile
    }
}

public class GTConstantsManager {
    open static let sharedInstance = GTConstantsManager()

    typealias PlistDict = [String : AnyObject]
    fileprivate var plist: PlistDict = [:]

    fileprivate static let interceptionsURLKey = "interceptions_url"

    open var config: GTConstantsManagerConfig? {
        didSet {
            guard let config = config else { return }

            plist = getContents(file: config.defaultConfigFile)

            config.overrideConfigFile.forEach { setOveride(file: $0) }

            if interceptionsConfigured() {
                GTInterceptionManager.sharedInstance.sync()
            }
        }
    }

    fileprivate func setOveride(file: String) {
        let updatedPlist = getContents(file: file)

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

        return URL(string: findPlist(key: GTConstantsManager.interceptionsURLKey) as! String)
    }

    //
    // MARK: Finders
    //

    public func int(key: String) -> NSInteger {
        guard let int = find(key: key) as? NSInteger else {
            fatalError( "Key is missing : \(key)")
        }

        return int
    }

    public func number(key: String) -> NSNumber {
        guard let number = find(key: key) as? NSNumber else {
            fatalError( "Key is missing : \(key)")
        }

        return number
    }

    public func bool(key: String) -> Bool {
        guard let bool = find(key: key) as? Bool else {
            fatalError( "Key is missing : \(key)")
        }

        return bool
    }

    public func string(key: String) -> String {
        guard let string = find(key: key) as? String else {
            fatalError("Key is missing : \(key)")
        }

        return string
    }

    //
    // MARK: Helpers
    //

    fileprivate func interceptionsConfigured() -> Bool {
        return (findPlist(key: GTConstantsManager.interceptionsURLKey) as? String) != nil
    }

    fileprivate func getContents(file: String) -> PlistDict {
        let path = Bundle.main.url(forResource: file, withExtension: "plist")

        guard let url = path, let plistDictionary = NSDictionary(contentsOf: url) as? PlistDict else {
            return [:]
        }

        return plistDictionary
    }

    fileprivate func find(key: String) -> AnyObject? {
        if let object = findIntercepted(key: key) {
            return object
        }

        return findPlist(key: key)
    }

    fileprivate func findPlist(key: String) -> AnyObject? {
        guard let _ = config else {
            fatalError("You must provide a config param before accessing the constants manager")
        }

        return plist[key]
    }

    fileprivate func findIntercepted(key: String) -> AnyObject? {
        return GTInterceptionManager.sharedInstance.hotfix(key: key)
    }

}

// To be used by objc only
public class GTConstantsBridger: NSObject {
    static func string(key: String) -> String {
        return GTConstantsManager.sharedInstance.string(key: key)
    }

    static func number(key: String) -> NSNumber {
        return GTConstantsManager.sharedInstance.number(key: key)
    }
}

extension String {
    public func constantString() -> String {
        return GTConstantsManager.sharedInstance.string(key: self)
    }
}
