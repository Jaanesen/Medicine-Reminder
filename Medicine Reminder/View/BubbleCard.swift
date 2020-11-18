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
    
    var body: some View {
        VStack {
            HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                HStack(spacing: 10)  {
                    ForEach(values, id: \.self) { num in
                        Text("\(Int(num))")
                            .clipShape(Circle())
                            .font(.title)
                            .foregroundColor(.primary)
                            .background(Rectangle().fill(Color.red).clipShape(Circle()))
                    }

                }

            }
            .layoutPriority(100)
            
            Spacer()
        }
        .padding()
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 1)
        )
        .padding([.top, .horizontal])
    }}
