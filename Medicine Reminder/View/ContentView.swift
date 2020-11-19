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

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: EditBoundary(bpmBoundary: "\(userData.triggerBoundary)", dynamicBoundary: userData.dynamicBoundary)) {
                    SimpleEditCard(title: "Current HR Boundary".uppercased(), bodyText: "\(userData.triggerBoundary)")
                }

                HeartCard(title: "Current resting heart rate".uppercased(), bodyText: getCurrentHR())

                HeartCard(title: "Average resting HR".uppercased(), bodyText: "\(String(format: "%.1f", Double(userData.restingHeartRates.average)))")

                BubbleCard(title: "Last 7 days:".uppercased(), values: userData.restingHeartRates, dates: userData.dates)
                Spacer()
            }.navigationBarTitle(Text("Medicine Reminder"))
        }
    }

    private func getCurrentHR() -> String {
        if userData.dates != [] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EE"
            
            let lastDate = dateFormatter.string(from: userData.dates[userData.dates.count - 1])
            let currentDate = dateFormatter.string(from: Date())

            if lastDate == currentDate {
                return String(userData.lastRestingHeartRate)
            }
        }
        return "--"
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
