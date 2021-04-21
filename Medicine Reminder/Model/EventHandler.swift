//
//  EventHandler.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 16/12/2020.
//

import EventKit

class EventHandler {
    
    let eventStore = EKEventStore()
    
    func scheduleReminder(hours: Int) {
        guard let calendar = self.eventStore.defaultCalendarForNewReminders() else { return }
        let newReminder = EKReminder(eventStore: eventStore)
        
        newReminder.calendar = calendar
        newReminder.title = "Beta-blocker Reminder"
        newReminder.priority = 1
        
        let timeInterval = 60*60*hours
        
        let alarmTime = Date().addingTimeInterval(Double(timeInterval))
        let alarm = EKAlarm(absoluteDate: alarmTime)
        
        newReminder.addAlarm(alarm)
        
        let dueDate = Date().addingTimeInterval(Double(timeInterval))
        newReminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dueDate)
        
        try! eventStore.save(newReminder, commit: true)
    }
    
    // MARK: - Event Authorization
    
    func authorizeEventKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        eventStore.requestAccess(to: .reminder) { success, error in
            completion(success, error)
        }
    }
}
