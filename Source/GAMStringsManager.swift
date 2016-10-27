//
//  GAMStringsManager.swift
//  Gametime
//
//  Created by Mike Silvis on 8/16/16.
//
//

import UIKit

open class GAMStringsManager: NSObject {
    open static let sharedInstance = GAMStringsManager()

    open func stringForID(_ key : String?) -> String {
        guard let key = key else { return "" }

        return findString(key, safeToNotExist: false)
    }

    open func stringForIDWithList(_ key : String?, args: CVaListPointer) -> String {
        guard let key = key else { return "" }

        return NSString(format: findString(key, safeToNotExist: false), locale: Locale.current, arguments: args) as String
    }

    open func stringForID(_ key : String?, safetoNotExist: Bool) -> String {
        guard let key = key else { return "" }

        return findString(key, safeToNotExist: safetoNotExist)
    }

    //
    // MARK: Finders
    //

    fileprivate func findString(_ key: String, safeToNotExist: Bool) -> String {
        if let string = findInterceptedString(key) {
            return string
        }

        return findLocalizedString(key, safeToNotExist: safeToNotExist)
    }

    fileprivate func findLocalizedString(_ key : String, safeToNotExist: Bool) -> String {
        let string = NSLocalizedString(key, comment: "")

        if string == key {
            assert(safeToNotExist, "Key: \(key) does not exist. Please add it")
        }

        if safeToNotExist && string.isEmpty {
            return key
        }

        return string
    }

    fileprivate func findInterceptedString(_ key : String) -> String? {
        return GAMInterceptionManager.sharedInstance.hotfixStringForKey(key)
    }

}

