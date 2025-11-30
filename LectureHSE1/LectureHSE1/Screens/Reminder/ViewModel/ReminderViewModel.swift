//
//  ReminderViewModel.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 30.11.2025.
//

import Foundation

class ReminderViewModel {
    var reminders: [Reminder] = []
    
    @discardableResult
    func loadReminders() -> [Reminder] {
        reminders = [Reminder(text: "okak", description: "okakakakaka", priority: .low, toDate: Date()),
                     Reminder(text: "pokak", description: "error", priority: .high, toDate: Date()),
                     Reminder(text: "sokak", description: "shisa", priority: .medium),
                     Reminder(text: "dokak", description: "pko", priority: .low, toDate: Date())]
        return reminders
    }
}
