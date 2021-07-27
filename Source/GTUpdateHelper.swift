//
//  GTUpdateHelper.swift
//  GTConstants
//
//  Created by Ali Ajmine on 3/2/17.
//  Copyright © 2017 Mike Silvis. All rights reserved.
//

import UIKit

public enum Restriction: Int {
    case low
    case medium
    case high
}

public enum UpdateType {
    case OS
    case app
}

public struct UpdateRule {
    public let type: UpdateType
    public let version: String
    public let restriction: Restriction
    public let message: String?
}

internal class GTUpdateHelper {

    fileprivate var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    fileprivate var osVersion: String {
        return UIDevice.current.systemVersion
    }

    fileprivate struct UpdateConfig {

        struct Version {
            let number: String
            let message: String?

            init(number: String, message: String? = nil) {
                self.number = number
                self.message = message
            }
        }

        let active: Bool
        let restriction: Restriction
        let minimumAppVersion: Version
        let minimumOSVersion: Version

        init(active: Bool, restriction: Restriction, minimumAppVersion: Version, minimumOSVersion: Version) {
            self.active = active
            self.restriction = restriction
            self.minimumAppVersion = minimumAppVersion
            self.minimumOSVersion = minimumOSVersion
        }
    }

    fileprivate var updateConfigs: [UpdateConfig] = []

    //
    // MARK: - Interface
    //

    fileprivate(set) internal var updateRule: UpdateRule?

    internal var updateNeeded: Bool {
        return updateRule != nil
    }

    internal func configureUpdateRequirements(withData data: AnyObject?) {
        buildUpdateConfigs(withData: data)
        configureUpdateRequirements()
    }

    //
    // MARK: - Helpers
    //

    fileprivate func configureUpdateRequirements() {
        guard !updateConfigs.isEmpty || updateRule == nil else { return }

        func buildUpdateRule(forConfig updateConfig: UpdateConfig) -> UpdateRule? {
            let minAppVersion = updateConfig.minimumAppVersion
            let minOSVersion = updateConfig.minimumOSVersion

            if appVersion.isOlder(thanVersion: minAppVersion.number) {
                return UpdateRule(type: .app, version: minAppVersion.number, restriction: updateConfig.restriction, message: minAppVersion.message)
            } else if osVersion.isOlder(thanVersion: minOSVersion.number) {
                return UpdateRule(type: .OS, version: minOSVersion.number, restriction: updateConfig.restriction, message: minOSVersion.message)
            }

            return nil
        }

        guard let rule = updateConfigs.filter({ config in
            return config.active
        }).sorted(by: { lhs, rhs in
            return lhs.restriction.rawValue > rhs.restriction.rawValue
        }).map({ config in
            return buildUpdateRule(forConfig: config)
        }).filter({ rule -> Bool in
            return rule != nil
        }).first else { return }
        
        updateRule = rule
    }

    //
    // MARK: - Config Helpers
    //

    fileprivate func buildUpdateConfigs(withData data: AnyObject?) {
        guard let configDicts = data as? [[String: AnyObject]] else { return }

        for dict in configDicts {
            guard let updateConfig = updateConfig(dict) else { continue }
            updateConfigs.append(updateConfig)
        }
    }

    fileprivate func updateConfig(_ dict: [String: AnyObject]?) -> UpdateConfig? {
        guard let dict = dict else { return nil }

        let versionKey = "version"
        let messageKey = "message"
        let restrictionKey = "restriction"
        let activeKey = "active"
        let minAppVersionKey = "min_app_version"
        let minOSVersionKey = "min_os_version"

        func restriction(forKey key: String) -> Restriction? {
            guard var restriction = dict[key] as? Int else {
                return nil
            }

            restriction = max(restriction, Restriction.low.rawValue)
            restriction = min(restriction, Restriction.high.rawValue)
            
            return Restriction(rawValue: restriction)
        }

        func active(forKey key: String) -> Bool? {
            return dict[key] as? Bool
        }

        func version(forKey key: String) -> UpdateConfig.Version? {
            guard let versionDict = dict[key] as? [String: AnyObject], let version = versionDict[versionKey] as? String else {
                return nil
            }

            func localizedMessage() -> String? {
                guard let messageDict = versionDict[messageKey] as? [String: AnyObject],
                    let languageKey = Bundle.main.preferredLocalizations.first else {
                        return nil
                }

                return messageDict[languageKey] as? String
            }

            guard let message = localizedMessage() else {
                return UpdateConfig.Version(number: version)
            }

            return UpdateConfig.Version(number: version, message: message)
        }

        guard let activeValue = active(forKey: activeKey), let restrictionValue = restriction(forKey: restrictionKey),
            let minAppVersionValue = version(forKey: minAppVersionKey), let minOSVersionValue = version(forKey: minOSVersionKey) else {
                return nil
        }

        return UpdateConfig(active: activeValue, restriction: restrictionValue,
                            minimumAppVersion: minAppVersionValue, minimumOSVersion: minOSVersionValue)
    }
}

fileprivate extension String {
    func isOlder(thanVersion version: String) -> Bool {
        guard !self.isEmpty && !version.isEmpty else { return false }
        return self.compare(version, options: String.CompareOptions.numeric) == ComparisonResult.orderedAscending
    }
}
