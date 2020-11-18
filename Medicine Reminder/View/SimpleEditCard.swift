//
//  SwiftUIView.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import SwiftUI

struct SimpleEditCard: View {
    
    var title: String
    var bodyText: String
    
    var body: some View {
        VStack {            HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                HStack {
                    Text(bodyText)
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                    Spacer()
                    Image(systemName: "pencil")
                        .font(.title)
                        .foregroundColor(.secondary)
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
    }
}
