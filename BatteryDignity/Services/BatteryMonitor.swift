import Foundation
import UIKit
import Combine

/// Observes live battery level and charging state so other services can make
/// rating and envelope-delay decisions.
final class BatteryMonitor: ObservableObject {
    @Published private(set) var batteryLevel: Double = 1.0
    @Published private(set) var isCharging: Bool = false

    private(set) var isMonitoring = false
    private var observers: [NSObjectProtocol] = []

    /// Battery level as a whole number from 0 to 100.
    var batteryLevelPercent: Int {
        Int((batteryLevel * 100).rounded())
    }

    /// True when the device is not charging and is at or below the low-battery threshold.
    var isLowBattery: Bool {
        !isCharging && batteryLevel <= AppConstants.lowBatteryThreshold
    }

    /// Starts observing battery level and charging-state changes.
    func startMonitoring() {
        guard !isMonitoring else { return }

        isMonitoring = true
        UIDevice.current.isBatteryMonitoringEnabled = true

        let center = NotificationCenter.default

        let levelObserver = center.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main