//
//  UserData.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import SwiftUI

class UserData: ObservableObject {
    @Published var lastRestingHeartRate: Double = 0.0
    @Published var restingHeartRates: Array<Double> = [0.0, 2.0]
    @Published var triggerBoundary: Double = 0.0

    let notificationHandler = NotificationHandler()

    func setLastRestingHR(heartRate: Double) {
        lastRestingHeartRate = heartRate
    }
    
    func setTriggerBoundary (boundary: Double) {
        triggerBoundary = boundary
    }

    func setRestingHRs(heartRates: Array<Double>) {
        DispatchQueue.main.async {
            self.restingHeartRates = heartRates

            if self.lastRestingHeartRate == 0.0 {
                self.lastRestingHeartRate = self.restingHeartRates[self.restingHeartRates.count - 1]
                NSLog("Initial resting heart rate: \(self.lastRestingHeartRate)")
            }
            if self.lastRestingHeartRate != self.restingHeartRates[self.restingHeartRates.count - 1] {
                self.setLastRestingHR(heartRate: self.restingHeartRates[self.restingHeartRates.count - 1])
                NSLog("New resting heart rate: \(self.lastRestingHeartRate)")
                self.notificationHandler.SendNormalNotification(title: "Resting heart rate changed!", body: "Your new resting heart rate value is: \(self.lastRestingHeartRate)", timeInterval: 1)
                NSLog("Sent notification")
            }
        }
    }
}
