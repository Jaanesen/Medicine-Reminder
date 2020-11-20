//
//  UserData.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import SwiftUI

class UserData: ObservableObject {
    @Published var lastRestingHeartRate: Double = 0.0
    @Published var restingHeartRates: Array<Double> = []
    @Published var triggerBoundary: Double = 0.0
    @Published var dates: Array<Date> = []
    @Published var dynamicBoundary: Bool = true
    @Published var warningDates: Array<Date> = []

    let notificationHandler = NotificationHandler()
    
    init() {
        self.triggerBoundary = UserDefaults.standard.object(forKey: "triggerBoundary") as? Double ?? 0.0
        self.dynamicBoundary = UserDefaults.standard.object(forKey: "dynamicBoundary") as? Bool ?? true
        self.warningDates = UserDefaults.standard.object(forKey: "warningDates") as? Array<Date> ?? []
    }


    func setLastRestingHR(heartRate: Double) {
        lastRestingHeartRate = heartRate
    }

    func setTriggerBoundary(boundary: Double) {
        triggerBoundary = boundary
        UserDefaults.standard.set(triggerBoundary, forKey: "triggerBoundary")
        print(triggerBoundary)
    }

    func setDynamicBoundary(bool: Bool) {
        dynamicBoundary = bool
        UserDefaults.standard.set(dynamicBoundary, forKey: "dynamicBoundary")
    }

    func setRestingHRs(heartRates: Array<Double>, dates: Array<Date>) {
        DispatchQueue.main.async {
            self.restingHeartRates = heartRates
            self.dates = dates

            //Check for new resting heart rate
            if self.lastRestingHeartRate == 0.0 {
                self.setLastRestingHR(heartRate: self.restingHeartRates[self.restingHeartRates.count - 1])
                NSLog("Initial resting heart rate: \(self.lastRestingHeartRate)")
            }
            
            //Check notification trigger
            if self.isHRCurrent() && self.lastRestingHeartRate > self.triggerBoundary && self.timeChecker() {
                self.notificationHandler.SendActionNotification(title: "Resting heart rate changed!", body: "Your new resting heart rate value is: \(self.lastRestingHeartRate)", timeInterval: 1)
                NSLog("Sent notification")
            }
        }
    }
    
    func increaseBoundary(value: Double) {
        NSLog("Increasing boundary by \(value)")
        let newValue = self.triggerBoundary + value
        setTriggerBoundary(boundary: newValue)
    }
    
    func logCorrectWarning(date: Date) {
        NSLog("Logging date of correct warning")
        warningDates.append(date)
        UserDefaults.standard.set(warningDates, forKey: "warningDates")
    }
    
    // MARK: - Extras
    
    func getCurrentHR() -> String {
        if isHRCurrent() {
                return String(self.lastRestingHeartRate)
            }
        return "--"
    }
    
    private func isHRCurrent() -> Bool {
        if self.dates != [] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EE"
            
            let lastDate = dateFormatter.string(from: self.dates[self.dates.count - 1])
            let currentDate = dateFormatter.string(from: Date())
            
            if lastDate == currentDate {
                return true
            }
        }
        return false
    }
    
    private func timeChecker() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(
            bySettingHour: 10,
            minute: 0,
            second: 0,
            of: now)!
        
        let endTime = calendar.date(
            bySettingHour: 20,
            minute: 0,
            second: 0,
            of: now)!
        
        if now >= startTime &&
            now <= endTime
        {
            return true
        }
        return false
    }

}
