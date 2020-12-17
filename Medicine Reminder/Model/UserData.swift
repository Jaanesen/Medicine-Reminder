//
//  UserData.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import SwiftUI
import EventKit

class UserData: ObservableObject {
    @Published var lastRestingHeartRate: Double = 0.0
    @Published var restingHeartRates: Array<Double> = []
    @Published var triggerBoundary: Double = 0.0
    @Published var dates: Array<Date> = []
    @Published var dynamicBoundary: Bool = true
    @Published var dynamicBoundaryGap: Double = 3.0
    @Published var warningDates: Array<Date> = []
    @Published var notifyQuestion: Bool = false
    @Published var remindQuestion: Bool = false
    var lastWarnDate: Date = Date().addingTimeInterval(-604800)

    let notificationHandler = NotificationHandler()
    let eventStore = EKEventStore()

    
    init() {
        self.triggerBoundary = UserDefaults.standard.object(forKey: "triggerBoundary") as? Double ?? 0.0
        self.dynamicBoundary = UserDefaults.standard.object(forKey: "dynamicBoundary") as? Bool ?? true
        self.warningDates = UserDefaults.standard.object(forKey: "warningDates") as? Array<Date> ?? []
        self.dynamicBoundaryGap = UserDefaults.standard.object(forKey: "dynamicBoundaryGap") as? Double ?? 3.0
    }

    func setLastRestingHR(heartRate: Double) {
        lastRestingHeartRate = heartRate
    }

    func setTriggerBoundary(boundary: Double) {
        triggerBoundary = boundary
        UserDefaults.standard.set(triggerBoundary, forKey: "triggerBoundary")
    }
    
    func setDynamicBoundaryGap(gap: Double) {
        dynamicBoundaryGap = gap
        UserDefaults.standard.set(dynamicBoundaryGap, forKey: "dynamicBoundaryGap")
    }

    func setDynamicBoundary(bool: Bool) {
        dynamicBoundary = bool
        UserDefaults.standard.set(dynamicBoundary, forKey: "dynamicBoundary")
    }
    
    func changeNotifyQuestion(bool: Bool) {
        notifyQuestion = bool

        NSLog("Changed notifyQuestion to: \(notifyQuestion)")
    }
    
    func changeRemindQuestion(bool: Bool) {
        remindQuestion = bool
        NSLog("Changed notifyQuestion to: \(remindQuestion)")
    }


    func setRestingHRs(heartRates: Array<Double>, dates: Array<Date>) {
        NSLog("Setting resting heart rates")
        DispatchQueue.main.async {
            self.restingHeartRates = heartRates
            self.dates = dates

            //Check for initial resting heart rate
            if self.lastRestingHeartRate == 0.0 {
                self.setLastRestingHR(heartRate: self.restingHeartRates[self.restingHeartRates.count - 1])
                NSLog("Initial resting heart rate: \(self.lastRestingHeartRate)")
                return
            }
            //Check for new resting Heart Rate
            if self.isHRCurrent() && self.lastRestingHeartRate != heartRates[heartRates.count - 1]{
                self.setLastRestingHR(heartRate: heartRates[heartRates.count - 1])
            }
            NSLog("Checking notification trigger")
            //Check notification trigger
            if self.isHRCurrent() && self.lastRestingHeartRate > self.triggerBoundary && self.timeChecker() && self.triggerBoundary > 20.0 {
                NSLog("Passed trigger")
                if self.lastWarnDate.addingTimeInterval(600) < Date() {
                    NSLog("Passed Date check")
                    self.changeNotifyQuestion(bool: true)
                    self.lastWarnDate = Date()
                    self.notificationHandler.SendActionNotification(title: "Beta-blocker warning!", body: "Your resting heart rate value is: \(self.lastRestingHeartRate). This is above your set boundary: \(self.triggerBoundary). Have you remembered your medication today?", timeInterval: 1)
                    NSLog("Sent notification")

                } else {
                    NSLog("Failed Date trigger")
                    print(self.lastWarnDate.addingTimeInterval(600))
                }
            }
        }
    }
    
    func setLastWarnDate(date: Date) {
        self.lastWarnDate = date
    }
    
    func increaseBoundary() {
        NSLog("Increasing boundary by \(self.dynamicBoundaryGap)")
        let newValue = self.triggerBoundary + self.dynamicBoundaryGap
        setTriggerBoundary(boundary: newValue)
    }
    
    func logCorrectWarning(date: Date) {
        NSLog("Logging date of correct warning")
        warningDates.append(date)
        UserDefaults.standard.set(warningDates, forKey: "warningDates")
    }
    
    // MARK: - Extras
    
    func getCurrentHR(rHR: Double) -> String {
        if isHRCurrent() {
                return String(rHR)
            }
        return "--"
    }
    
    func isHRCurrent() -> Bool {
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
            bySettingHour: 14,
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
