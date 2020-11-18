//
//  EditBoundary.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import SwiftUI

struct EditBoundary: View {
    @EnvironmentObject var userData: UserData
    var numbers = 40...90
    var decimals = 0...9
    @State  var selectedNumber = 40
    @State  var selectedDecimal = 0

    var body: some View {
        Text("Here you can change the boundary!")
            .navigationBarTitle(Text("BPM Boundary"), displayMode: .large)
        
        
        HStack {
            Picker("Number",selection: $selectedNumber) {
                ForEach(numbers, id: \.self) { num in
                    Text("\(num)")
                }
            }
            Picker("Decimal",selection: $selectedDecimal) {
                ForEach(decimals, id: \.self) { dec in
                    Text("\(dec)")
                }
            }
        }
        .pickerStyle(MenuPickerStyle())
        
        Text("\(selectedNumber).\(selectedDecimal)")
        Spacer()
    }
}
