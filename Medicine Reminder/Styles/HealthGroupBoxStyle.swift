//
//  HealthGroupBoxStyle.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 21/11/2020.
//

import SwiftUI

struct HealthGroupBoxStyle: GroupBoxStyle {
    var color: Color
    var date: Date?

    @ScaledMetric var size: CGFloat = 1

    func makeBody(configuration: Configuration) -> some View {
        GroupBox(label: HStack {
            configuration.label.foregroundColor(color)
            Spacer()
            if date != nil {
                Text("\(date!)").font(.footnote).foregroundColor(.secondary).padding(.trailing, 4)
            }
        }) {
            configuration.content.padding(.top, 4)
        }
    }
}
