//
//  Reminder.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 30.11.2025.
//

import Foundation
import UIKit

struct Reminder {
    var text: String
    var description: String
    var priority: Priority
    var flag: Bool = false
    var toDate: Date? = nil
    
    var isDone: Bool = false
}

enum Priority: Int, CaseIterable {
    case high = 2
    case medium = 1
    case low = 0
    
    var color: UIColor {
        switch self {
        case .high:
            return .red
        case .medium:
            return .yellow
        case .low:
            return .green
        }
    }
}
