//
//  SmallBubbleView.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import SwiftUI

struct SmallBubbleView: View {
    var values: Array<Double>
    var dates: Array<Date>
    
    @ViewBuilder var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(values.indices, id: \.self) { i in
                VStack {
                    Text("\(Int(values[i]))")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .frame(width: 17, height: 17, alignment: .center)
                        .padding(2)
                        .overlay(
                            Circle()
                                .stroke(Color.pink, lineWidth: 1)
                        )
                }
            }
        }
    }
}

func getDaysList(dates: Array<Date>) -> Array<String> {
    var list: Array<String> = []
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EE"
    for day in dates {
        let dayInWeek = dateFormatter.string(from: day)
        list.append(dayInWeek)
    }
    return list
}
