//
//  GTStringsManager.swift
//  Gametime
//
//  Created by Mike Silvis on 8/16/16.
//
//

import UIKit

public class GTStringsManager {
    public static let sharedInstance = GTStringsManager()

    public func string(key: String?) -> String {
        guard let key = key else { return "" }

        return find(key: key, safeToNotExist: false)
    }

    public func string(key: String?, args: CVaListPointer) -> String {
        guard let key = key else { return "" }

        return NSString(format: find(key: key, safeToNotExist: false), locale: Locale.current, arguments: args) as String
    }

    public func string(key: String?, safetoNotExist: Bool) -> String {
        guard let key = key else { return "" }

        return find(key: key, safeToNotExist: safetoNotExist)
    }

    //
    // MARK: Finders
    //

    fileprivate func find(key: String, safeToNotExist: Bool) -> String {
        if let string = findIntercepted(key: key) {
            return string
        }

        return findLocalized(key: key, safeToNotExist: safeToNotExist)
    }

    fileprivate func findLocalized(key: String, safeToNotExist: Bool) -> String {
        let string = NSLocalizedString(key, comment: "")

        if string == key {
            assert(safeToNotExist, "Key: \(key) does not exist. Please add it")
        }

        if safeToNotExist && string.isEmpty {
            return key
        }

        return string
    }

    fileprivate func findIntercepted(key: String) -> String? {
        return GTInterceptionManager.sharedInstance.hotFix(key: key)
    }

}

// To be used by objc only
public class GTStringBridger: NSObject {
    static func string(key: String) -> String {
        return GTStringsManager.sharedInstance.string(key: key)
    }
}
