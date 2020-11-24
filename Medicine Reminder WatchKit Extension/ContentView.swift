//
//  ContentView.swift
//  Medicine Reminder WatchKit Extension
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userData: UserData
    @State var scrollText = false
    
    var body: some View {
        VStack {
            Label("Resting Heart Rate", systemImage: "heart.fill")
                .foregroundColor(.pink)
            Text((userData.isHRCurrent() ? "\(String(format: "%.1f", userData.restingHeartRates[userData.restingHeartRates.count-1]))" : "--"))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .padding()
            Label("Last 7 days", systemImage: "calendar")
                .foregroundColor(.pink)
            SmallBubbleView(values: userData.restingHeartRates, dates: userData.dates)
                .padding()
            
        }
        .navigationBarTitle("Medicine Reminder")
    }
}
