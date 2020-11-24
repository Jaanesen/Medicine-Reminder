//
//  NotificationHandler.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import SwiftUI
import UserNotifications

class NotificationHandler {
    
    @EnvironmentObject var userData: UserData
    
    func SendActionNotification(title: String, body: String, timeInterval: Double) {
        // Define the custom actions.
        let yesAction = UNNotificationAction(identifier: "YES_ACTION",
                                                title: "Yes",
                                                options: UNNotificationActionOptions(rawValue: 0))
        let noAction = UNNotificationAction(identifier: "NO_ACTION",
                                                 title: "No",
                                                 options: UNNotificationActionOptions(rawValue: 0))
        // Define the notification type
        let meetingInviteCategory =
            UNNotificationCategory(identifier: "MEDICINE_REMINDER", actions: [yesAction,noAction], intentIdentifiers: [], options: .customDismissAction)

        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([meetingInviteCategory])
        
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = "MEDICINE_REMINDER"

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval, repeats: false)
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // Schedule the request with the system.
        notificationCenter.add(request) { error in
            if error != nil {
                // Handle any errors.
                NSLog("Error occured while delivering notifications to center")
            } else {
                NSLog("Successfully delivered notifications to center")
            }
        }
        return        
    }
        
    func SendNormalNotification(title: String, body: String, timeInterval: Double) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.defaultCritical
        
        // Create the trigger as a repeating event.
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval, repeats: false)
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if error != nil {
                // Handle any errors.
                NSLog("Error occured while delivering notifications to center")
            } else {
                NSLog("Successfully delivered notifications to center")
            }
        }
        return
    }
    
    // MARK: - Notification Authorization
    
    func NotificationAuthorizationHandler() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            
            if error != nil {
                NSLog("*** Notification authorization failed ***")
            }
        }
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                    (settings.authorizationStatus == .provisional) else { return }
        }
    }


}
