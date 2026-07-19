//
//  OrderLiveActivityWidgetBundle.swift
//  OrderLiveActivityWidget
//
//  Entry point for the widget extension. Only hosts the one shared Live
//  Activity — no home screen timeline widgets in the MVP scope.
//

import WidgetKit
import SwiftUI

@main
struct OrderLiveActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        OrderLiveActivityWidget()
    }
}
