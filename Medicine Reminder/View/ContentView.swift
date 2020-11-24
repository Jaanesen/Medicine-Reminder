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
    
    init() {
        UIScrollView.appearance().backgroundColor = .systemGroupedBackground
    }


    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    GroupBox(label: Label("Heart Rate Boundary", systemImage: "exclamationmark.circle")) {
                        HealthValueView(value: "\(userData.triggerBoundary)", unit: "BPM")
                    }.groupBoxStyle(HealthGroupBoxStyleNav(color: .pink, destination: EditBoundary(bpmBoundary: "\(userData.triggerBoundary)", dynamicBoundary: userData.dynamicBoundary)))
                    .padding([.horizontal, .top])

                    GroupBox(label: Label("Resting Heart Rate", systemImage: "heart.fill")) {
                        HealthValueView(value: userData.getCurrentHR(rHR: userData.lastRestingHeartRate), unit: "BPM")
                    }.groupBoxStyle(HealthGroupBoxStyle(color: .pink ))
                    .padding([.horizontal])
                    .padding([.top], 5)

                    GroupBox(label: Label("Average Resting Heart Rate", systemImage: "sum")) {
                        HealthValueView(value: "\(String(format: "%.1f", Double(userData.restingHeartRates.average)))", unit: "BPM")
                    }.groupBoxStyle(HealthGroupBoxStyle(color: .pink ))
                    .padding([.horizontal])
                    .padding([.top], 5)

                    GroupBox(label: Label("Last 7 Days", systemImage: "calendar")) {
                                BubbleView(values: userData.restingHeartRates, dates: userData.dates)                    }.groupBoxStyle(HealthGroupBoxStyle(color: .pink ))
                    .padding([.horizontal])
                        .padding([.top], 5)

                    

                    Spacer()
                }
            }
            .navigationBarTitle(Text("Medicine Reminder"), displayMode: .large)
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
