//
//  EditBoundary.swift
//  Medicine Reminder
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import SwiftUI

struct EditBoundary: View {
    @EnvironmentObject var userData: UserData

    @State var bpmBoundary: String
    @State var dynamicBoundary: Bool
    @State var boundaryGap: String

    @State private var showingActionSheet = false

    var body: some View {
        ScrollView {
            Text("You can change the boundary value which decides when to trigger alerts.")
                .font(.body)
                .padding([.top, .horizontal])
                .foregroundColor(.secondary)

            GroupBox(label: Text("Set Value Manually")) {
                VStack {
                    HStack {
                        Text("Boundary value")
                        Spacer()
                        TextField("Boundary", text: $bpmBoundary)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120, alignment: .trailing)
                    }
                    HStack {
                        Button("Use average from last 7 days", action: { bpmBoundary = "\(String(format: "%.1f", Double(userData.restingHeartRates.average)))" })
                            .padding()
                    }
                    Text("The boundary value should be set to 1 BPM less than your weekly average when OFF beta-blockers, or 10-12 BPM more than your average when ON beta-blocker medication, dependent on the heart rate effect of your specific medication.")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }.groupBoxStyle(HealthGroupBoxStyle(color: .blue))
                .padding([.horizontal])
                .padding([.top], 5)

            GroupBox(label: Text("Change Dynamic Boundary")) {
                VStack {
                    HStack {
                        Toggle(isOn: $dynamicBoundary) {
                            Text("Dynamic boundary")
                        }
                    }
                    Text("Activating dynamic boundary means the boundary value will increase everytime you are alerted while taken your medicine. This is to adjust the boundary to a correct level and prevent multiple false-alerts.")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                    Divider()
                    HStack {
                        Text("Boundary Gap")
                        Spacer()
                        TextField("Gap", text: $boundaryGap)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120, alignment: .trailing)
                    }
                    Text("Change the gap in which the boundary value will change every time you get a notification even though you have taken your medicine.")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }.groupBoxStyle(HealthGroupBoxStyle(color: .blue))
                .padding([.horizontal])
                .padding([.top], 5)

            Button("Save", action: { self.showingActionSheet = true })
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text("Warning"), message: Text("Are you sure you want to change the boundary settings?"), buttons: [
                        .default(Text("Yes")) {
                            userData.setTriggerBoundary(boundary: Double(bpmBoundary.replacingOccurrences(of: ",", with: ".")) ?? 0.0)
                            userData.setDynamicBoundary(bool: dynamicBoundary)
                            userData.setDynamicBoundaryGap(gap: Double(boundaryGap.replacingOccurrences(of: ",", with: ".")) ?? 0.0)
                        },
                        .cancel(),
                    ])
                }
                .padding()
            Spacer()
        }
        .dismissKeyboardOnTap()
        .navigationBarTitle(Text("Boundary Value"), displayMode: .large)
        .navigationBarItems(trailing:
            Button("Save", action: { self.showingActionSheet = true })
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text("Warning"), message: Text("Are you sure you want to change the boundary settings?"), buttons: [
                        .default(Text("Yes")) { userData.setTriggerBoundary(boundary: Double(bpmBoundary.replacingOccurrences(of: ",", with: ".")) ?? 0.0)
                            userData.setDynamicBoundary(bool: dynamicBoundary)
                            userData.setDynamicBoundaryGap(gap: Double(boundaryGap.replacingOccurrences(of: ",", with: ".")) ?? 0.0)
                        },
                        .cancel(),
                    ])
                }
        )
    }
}

// MARK: - Dismiss keyboard

public extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}

public struct DismissKeyboardOnTap: ViewModifier {
    public func body(content: Content) -> some View {
        #if os(macOS)
        return content
        #else
        return content.gesture(tapGesture)
        #endif
    }
    
    private var tapGesture: some Gesture {
        TapGesture().onEnded(endEditing)
    }
    
    private func endEditing() {
        UIApplication.shared.connectedScenes
            .filter {$0.activationState == .foregroundActive}
            .map {$0 as? UIWindowScene}
            .compactMap({$0})
            .first?.windows
            .filter {$0.isKeyWindow}
            .first?.endEditing(true)
    }
}
