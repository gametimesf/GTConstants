//
//  GTMaintenanceHelper.swift
//  GTConstants
//
//  Created by Ali Ajmine on 4/28/17.
//  Copyright © 2017 Mike Silvis. All rights reserved.
//

import Foundation

public class GTMaintenanceHelper {

    private var pollingTimer: Timer?
    private var pollingAttempt: Double = 0

    public var isUndergoingMaintenance: Bool {
        return config.active
    }

    public var maintenanceMessage: String {
        return config.message ?? ""
    }

    private struct MaintenanceConfig {
        let active: Bool
        var pollingInterval: TimeInterval
        let message: String?

        static let defaultInterval: TimeInterval = 30
        static let intervalIncrement: TimeInterval = 30

        init(isActive: Bool = false, interval: TimeInterval = MaintenanceConfig.defaultInterval, message: String? = "") {
            self.active = isActive
            self.message = message
            self.pollingInterval = interval
        }
    }

    private var config = MaintenanceConfig()

    public var pollingCompletion: (() -> Void)? {
        didSet {
            guard pollingCompletion != nil else {
                endPolling()
                return
            }

            beginPolling()
        }
    }

    //
    // MARK : Networking
    //

    private func syncMaintenanceData(completion: @escaping () -> Void) {
        guard let interceptionURL = GTConstantsManager.sharedInstance.interceptionsURL() else {
            completion()
            return
        }

        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let defaultSession = URLSession(configuration: config)

        let dataTask = defaultSession.dataTask(with: interceptionURL, completionHandler: { [weak self] (data, _, error) in
            guard let data = data,
                let responseObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject]
                else { return }

            self?.updateWithData((responseObject?["maintenance"] as? [String: AnyObject])?["ios"])
            completion()
        })
        
        dataTask.resume()
    }

    internal func updateWithData(_ data: AnyObject?) {
        guard let data = data as? [String: AnyObject] else { return }

        let messageKey = "message"
        let activeKey = "active"
        let intervalKey = "poll_interval"

        var message: String? {
            return data[messageKey] as? String
        }

        var isUndergoingMaintenance: Bool {
            return data[activeKey] as? Bool ?? false
        }

        var pollInterval: TimeInterval? {
            return data[intervalKey] as? TimeInterval
        }

        guard let interval = pollInterval else {
            config = MaintenanceConfig(isActive: isUndergoingMaintenance, message: message)
            return
        }

        config = MaintenanceConfig(isActive: isUndergoingMaintenance, interval: interval, message: message)
    }

    //
    // MARK : Polling
    //

    private func beginPolling() {
        guard #available(iOS 10.0, *) else { return }

        var adjustedInterval: TimeInterval {
            return config.pollingInterval + pollingAttempt * MaintenanceConfig.intervalIncrement
        }

        pollingTimer = Timer.scheduledTimer(withTimeInterval: adjustedInterval,
                                            repeats: true, block: poll())
    }

    private func poll() -> (Timer) -> Void {
        return { [weak self] timer in

            self?.syncMaintenanceData {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }

                    strongSelf.pollingCompletion?()

                    guard strongSelf.isUndergoingMaintenance == true else { return }
                    strongSelf.pollingAttempt += 1
                    strongSelf.endPolling()
                    strongSelf.beginPolling()
                }
            }
        }
    }

    private func endPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
}
