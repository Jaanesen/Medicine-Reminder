//
//  ContentView.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import HealthKitUI
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userData: UserData
    
    let eventHandler = EventHandler()

    init() {
        UIScrollView.appearance().backgroundColor = .systemGroupedBackground
    }

    var body: some View {
        NavigationView {
            ScrollView {
                GroupBox(label: Label("Heart Rate Boundary", systemImage: "exclamationmark.circle")) {
                    HealthValueView(value: userData.triggerBoundary, unit: "BPM")
                }.groupBoxStyle(HealthGroupBoxStyleNav(color: .pink, destination: EditBoundary(bpmBoundary: "\(userData.triggerBoundary)", dynamicBoundary: userData.dynamicBoundary, boundaryGap: "\(userData.dynamicBoundaryGap)")))
                    .padding([.horizontal, .top])

                GroupBox(label: Label("Resting Heart Rate", systemImage: "heart.fill")) {
                    HealthValueView(value: userData.isHRCurrent() ? userData.restingHeartRates[userData.restingHeartRates.count - 1] : 0.0, unit: "BPM")
                }.groupBoxStyle(HealthGroupBoxStyle(color: .pink))
                    .padding([.horizontal])
                    .padding([.top], 5)

                GroupBox(label: Label("Average Resting Heart Rate", systemImage: "sum")) {
                    HealthValueView(value: Double(userData.restingHeartRates.average), unit: "BPM")
                }.groupBoxStyle(HealthGroupBoxStyle(color: .pink))
                    .padding([.horizontal])
                    .padding([.top], 5)

                GroupBox(label: Label("Last 7 Days", systemImage: "calendar")) {
                    BubbleView(values: userData.restingHeartRates, dates: userData.dates)
                }.groupBoxStyle(HealthGroupBoxStyle(color: .pink))
                    .padding([.horizontal])
                    .padding([.top], 5)

                Spacer()
            }
            .navigationBarTitle(Text("Medicine Reminder"), displayMode: .large)
            .alert(isPresented: $userData.notifyQuestion) { () -> Alert in
                let primaryButton = Alert.Button.default(Text("Yes")) {
                    userData.increaseBoundary()
                    userData.changeNotifyQuestion(bool: false)
                }
                let secondaryButton = Alert.Button.cancel(Text("No")) {
                    userData.logCorrectWarning(date: Date())
                    userData.changeNotifyQuestion(bool: false)
                    userData.changeRemindQuestion(bool: true)
                }
                return Alert(title: Text("Beta-blocker warning!"), message: Text("Have you remembered your medication today?"), primaryButton: primaryButton, secondaryButton: secondaryButton)
            }
            .actionSheet(isPresented: $userData.remindQuestion) {
                ActionSheet(title: Text("Beta Blocker Reminder"), message: Text("Would you like to be reminded about taking your medicine later? Select how many hours:"), buttons: [
                    .default(Text("No")) {
                        userData.changeRemindQuestion(bool: false)
                    },
                    .default(Text("1 Hour")) {
                        eventHandler.scheduleReminder(hours: 1)
                        userData.changeRemindQuestion(bool: false)
                    },
                    .default(Text("2 Hours")) {
                        eventHandler.scheduleReminder(hours: 2)
                        userData.changeRemindQuestion(bool: false)
                    },
                    .default(Text("3 Hours")) {
                        eventHandler.scheduleReminder(hours: 3)
                        userData.changeRemindQuestion(bool: false)
                    },
                    .default(Text("4 Hours")) {
                        eventHandler.scheduleReminder(hours: 4)
                        userData.changeRemindQuestion(bool: false)
                    },
                    .cancel(),
                ])
            }
        }
    }
}

// MARK: - Extensions

extension Array where Element: BinaryFloatingPoint {
    /// The average value of all the items in the array
    var average: Double {
        if isEmpty {
            return 0.0
        } else {
            let sum = reduce(0, +)
            return Double(sum) / Double(count)
        }
    }
}
