//
//  LockScreenWidgetBundle.swift
//  LockScreenWidget
//
//  Created by TJ Bindseil on 11/19/25.
//

import WidgetKit
import SwiftUI

@main
struct LockScreenWidgetBundle: WidgetBundle {
    var body: some Widget {
        LockScreenWidget()
        LockScreenWidgetControl()
    }
}
