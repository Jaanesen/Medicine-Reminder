//
//  HealthGroupBoxStyle.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 21/11/2020.
//

import SwiftUI

struct HealthGroupBoxStyleNav<V: View>: GroupBoxStyle {
    var color: Color
    var destination: V
    var date: Date?
    
    @ScaledMetric var size: CGFloat = 1
    
    func makeBody(configuration: Configuration) -> some View {
        NavigationLink(destination: destination) {
            GroupBox(label: HStack {
                configuration.label.foregroundColor(color)
                Spacer()
                if date != nil {
                    Text("\(date!)").font(.footnote).foregroundColor(.secondary).padding(.trailing, 4)
                }
                Text("Edit").foregroundColor(.secondary)
                Image(systemName: "chevron.right").foregroundColor(.secondary).imageScale(.small)
            }) {
                configuration.content.padding(.top, 4)
            }
        }.buttonStyle(PlainButtonStyle())
    }
}
