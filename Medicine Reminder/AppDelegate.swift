//
//  AppDelegate.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import UIKit
import HealthKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    let healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")


    let userData = UserData()
    let notificationHandler = NotificationHandler()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
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

        
        return true
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
        healthStore.enableBackgroundDelivery(for: quantityType, frequency: .immediate) {
            _, error in
            
            if error != nil {
                fatalError("*** Background Delivery error ***")
            }
            
            NSLog("Enabled background delivery for resting heart rate")
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
                NSLog("*** An error occurred while calculating the statistics: \(error?.localizedDescription ?? "") ***")
                return
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
            userData.increaseBoundary()
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


    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

