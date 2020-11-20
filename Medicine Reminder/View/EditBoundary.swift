//
//  EditBoundary.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import SwiftUI

struct EditBoundary: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var bpmBoundary: String
    @State var dynamicBoundary: Bool

    @State private var showingActionSheet = false

    var body: some View {
        Text("You can change the boundary value which decides when to trigger alerts.")
            .font(.body)
            .padding([.top, .horizontal])
            .foregroundColor(.secondary)

        VStack {
            VStack {
                HStack {
                    Text("Change value manually")
                        .padding()
                    Spacer()
                    TextField("Boundary", text: $bpmBoundary)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .frame(width: 120, alignment: .trailing)
                }
                HStack {
                    Button("Use average from last 7 days", action: { bpmBoundary = "\(String(format: "%.1f", Double(userData.restingHeartRates.average)))" })
                        .padding([.horizontal])
                }
                Text("The boundary value should be set to 1 BPM less than your weekly average when OFF beta-blockers, or 10-12 BPM more than your average when ON beta-blocker medication, dependent on the heart rate effect of your specific medication.")
                    .padding()
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.sRGB, red: 150 / 255, green: 150 / 255, blue: 150 / 255, opacity: 0.3), lineWidth: 1)
            )
            .padding([.top, .horizontal])

            VStack {
                HStack {
                    Toggle(isOn: $dynamicBoundary) {
                        Text("Dynamic boundary")
                    }
                    .padding()
                }
                Text("Activating dynamic boundary means the boundary value will increase everytime you are alerted while taken your medicine. This is to adjust the boundary to a correct level and prevent multiple false-alerts.")
                    .padding([.horizontal, .bottom])
                    .foregroundColor(.secondary)
                    .font(.footnote)

            }
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.sRGB, red: 150 / 255, green: 150 / 255, blue: 150 / 255, opacity: 0.3), lineWidth: 1)
            )
            .padding([.top, .horizontal])

            Button("Save", action: { self.showingActionSheet = true })
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text("Warning"), message: Text("Are you sure you want to change the boundary settings?"), buttons: [
                        .default(Text("Yes")) { userData.setTriggerBoundary(boundary: Double(bpmBoundary) ?? 0.0)
                            userData.setDynamicBoundary(bool: dynamicBoundary)
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        .cancel(),
                    ])
                }
            Spacer()

        }
        .navigationBarTitle(Text("Boundary value"), displayMode: .large)
        .navigationBarItems(trailing:
                                Button("Save", action: { self.showingActionSheet = true })
                                .actionSheet(isPresented: $showingActionSheet) {
                                    ActionSheet(title: Text("Warning"), message: Text("Are you sure you want to change the boundary settings?"), buttons: [
                                        .default(Text("Yes")) { userData.setTriggerBoundary(boundary: Double(bpmBoundary) ?? 0.0)
                                            userData.setDynamicBoundary(bool: dynamicBoundary)
                                            self.presentationMode.wrappedValue.dismiss()
                                        },
                                        .cancel(),
                                    ])
                                }
        )

    }
}
