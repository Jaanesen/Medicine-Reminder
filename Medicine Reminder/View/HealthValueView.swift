//
//  HealthValueView.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 21/11/2020.
//

import SwiftUI

struct HealthValueView: View {
    var value: Double
    var unit: String
    
    @ScaledMetric var size: CGFloat = 1
    
    @ViewBuilder var body: some View {
        HStack {
            Text(value == 0.0 ? "--" : "\(String(format: "%.1f", value))")
                .font(.system(size: 30 * size, weight: .bold, design: .rounded)) + Text(" \(unit)").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
            Spacer()
        }
    }
}
