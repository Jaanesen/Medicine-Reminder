//
//  BubbleCard.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import SwiftUI

struct BubbleCard: View {
    var title: String
    var values: Array<Double>
    var dates: Array<Date>

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    HStack(alignment: .center, spacing: 10) {
                        ForEach(values.indices, id: \.self) { i in
                            VStack {
                                Text(getDaysList(dates: dates)[i])
                                Text("\(Int(values[i]))")
                                    .frame(width: 35, height: 35, alignment: .center)
                                    .padding(2)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.red, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150 / 255, green: 150 / 255, blue: 150 / 255, opacity: 0.3), lineWidth: 1)
        )
        .padding([.top, .horizontal])
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
