//
//  extension-GTInspectable.swift
//  GTConstants
//
//  Created by Mike Silvis on 8/24/16.
//  Copyright © 2016 Mike Silvis. All rights reserved.
//

import UIKit

extension String {
    public func localized() -> String {
        return GTStringsManager.sharedInstance.string(key: self)
    }

    public func localized(args: CVarArg...) -> String {
        return withVaList(args) {
            return GTStringsManager.sharedInstance.string(key: self, args: $0)
        } as String
    }
}

public extension UIBarButtonItem {
    @IBInspectable var localizedText: String? {
        get {
            return title
        }
        set {
            title = newValue?.localized()
        }
    }
}

public extension UIViewController {
    @IBInspectable var localizedTitle: String? {
        get {
            return title
        }
        set {
            title = newValue?.localized()
        }
    }
}

public extension UIButton {
    @IBInspectable var localizedText: String? {
        get {
            return titleLabel?.text
        }
        set {
            setTitle(newValue?.localized(), for: UIControl.State())
        }
    }
}

public extension UILabel {
    @IBInspectable var localizedText: String? {
        get {
            return text
        }
        set {
            text = newValue?.localized()
        }
    }
}
