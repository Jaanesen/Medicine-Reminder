//
//  ExtensionDelegate.swift
//  Medicine Reminder WatchKit Extension
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import WatchKit
import HealthKit
import UserNotifications

class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {

    let healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    
    
    let userData = UserData()
    let notificationHandler = NotificationHandler()

    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        notificationHandler.NotificationAuthorizationHandler()
        UNUserNotificationCenter.current().delegate = self
        
        authorizeHealthKit { authorized, error in
            guard authorized else {
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    NSLog("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    NSLog(baseMessage)
                }
                return
            }
            NSLog("HealthKit Successfully Authorized.")
            self.startObserver()
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    // MARK: - Observer Query
    
    func startObserver() {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate) else {
            fatalError("*** Unable to create a resting heart rate type ***")
        }
        let query = HKObserverQuery(sampleType: quantityType, predicate: nil) { _, completionHandler, errorOrNil in
            if errorOrNil != nil {
                fatalError("*** Unable to create query:  \(errorOrNil?.localizedDescription ?? "") ***")
            }
            NSLog("Observer triggered, calling fetch")
            self.fetchRestingHeartRates()
            NSLog("Called fetching heart rates")
            
            NSLog("Calling completion handler")
            completionHandler()
            NSLog("Completion handler called")
        }
        healthStore.execute(query)
    }
    
    // MARK: - Heart Rate Query
    
    private func fetchRestingHeartRates() {
        let calendar = NSCalendar.current
        
        let anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: NSDate() as Date)
        
        
        guard let anchorDate = Calendar.current.date(from: anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        
        let interval = NSDateComponents()
        interval.day = 1
        
        let endDate = Date()
        
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) else {
            fatalError("*** Unable to calculate the start date ***")
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate) else {
            fatalError("*** Unable to create a step count type ***")
        }
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .discreteAverage,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval as DateComponents)
        
        // Set the results handlers
        query.initialResultsHandler = {
            _, results, error in
            guard let statsCollection = results else {
                fatalError("*** An error occurred while calculating the statistics: \(error?.localizedDescription ?? "") ***")
            }
            NSLog("Fetching heart rates")
            var values: Array<Double> = []
            var dates: Array<Date> = []
            // Add the average resting heart rate to array
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                
                if let quantity = statistics.averageQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    values.append(Double(String(format: "%.1f", value))!)
                    dates.append(date)
                }
            }
            if values != [] {
                self.userData.setRestingHRs(heartRates: values, dates: dates)
            }
        }
        NSLog("Executing query")
        healthStore.execute(query)
    }
    
    // MARK: - HealthKit Authorization
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        enum HealthkitSetupError: Error {
            case notAvailableOnDevice
            case dataTypeNotAvailable
        }
        
        // 1. Check to see if HealthKit Is Available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        // 2. Prepare the data types that will interact with HealthKit
        guard let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            completion(false, HealthkitSetupError.dataTypeNotAvailable)
            return
        }
        
        // 3. Prepare a list of types you want HealthKit to read and write
        let types: Set<HKSampleType> = [restingHeartRate]
        // 4. Request Authorization
        HKHealthStore().requestAuthorization(toShare: nil,
                                             read: types) { success, error in
            completion(success, error)
        }
    }
    
    // MARK: - Notification Delegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
            -> Void) {
        
        completionHandler([.badge, .sound])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:
                                    @escaping () -> Void) {
        
        // Perform the task associated with the action.
        switch response.actionIdentifier {
        case "YES_ACTION":
            userData.increaseBoundary(value: 0.1)
            break
            
        case "NO_ACTION":
            userData.logCorrectWarning(date: Date())
            break
            
        // Handle other actions…
        
        default:
            break
        }
        
        // Always call the completion handler when done.
        completionHandler()
    }


}
