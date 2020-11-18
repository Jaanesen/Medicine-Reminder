//
//  ContentView.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import SwiftUI
import HealthKitUI

struct ContentView: View {
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        NavigationView {
            VStack {
                
                SimpleCard(title: "Current BPM Boundary", bodyText: "\(userData.triggerBoundary)")
                
                HeartCard(title: "avg. resting bpm".uppercased(), bodyText: "\(Int(userData.restingHeartRates.average))")
                
                BubbleCard(title: "Last 7 days:", values: userData.restingHeartRates)
                Spacer()
            }.navigationBarTitle(Text("Medicine Reminder"))
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
