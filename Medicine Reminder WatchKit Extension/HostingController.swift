//
//  HostingController.swift
//  Medicine Reminder WatchKit Extension
//
//  Created by Jonathan Aanesen on 18/11/2020.
//

import WatchKit
import Foundation
import SwiftUI
import UIKit

class HostingController: WKHostingController<AnyView> {
    let userData = (WKExtension.shared().delegate as! ExtensionDelegate).userData

    override var body: AnyView {
        return AnyView(ContentView().environmentObject(userData))
    }
}
