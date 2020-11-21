//
//  BubbleCard.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import SwiftUI

struct BubbleView: View {
    var title: String
    var values: Array<Double>
    var dates: Array<Date>

    @ViewBuilder var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ForEach(values.indices, id: \.self) { i in
                VStack {
                    Text(getDaysList(dates: dates)[i])
                        .frame(width: 35, alignment: .center)

                    Text("\(Int(values[i]))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(width: 35, height: 35, alignment: .center)
                        .padding(2)
                        .overlay(
                            Circle()
                                .stroke(Color.pink, lineWidth: 2)
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
