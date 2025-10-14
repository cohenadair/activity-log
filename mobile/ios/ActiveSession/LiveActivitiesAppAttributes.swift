//
//  LiveActivitiesAppAttributes.swift
//  Runner
//
//  Created by Cohen Adair on 2025-10-14.
//

import ActivityKit
import Foundation

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable { }

    var id = UUID()
}
