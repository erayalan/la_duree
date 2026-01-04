//
//  PerceptionOfTimeWidgetBundle.swift
//  PerceptionOfTimeWidget
//
//  Created by eray.alan on 7/30/25.
//

import WidgetKit
import SwiftUI

@main
struct PerceptionOfTimeWidgetBundle: WidgetBundle {
    var body: some Widget {
        PerceptionOfTimeWidget()
        PerceptionOfTimeWidgetControl()
        PerceptionOfTimeWidgetLiveActivity()
    }
}
