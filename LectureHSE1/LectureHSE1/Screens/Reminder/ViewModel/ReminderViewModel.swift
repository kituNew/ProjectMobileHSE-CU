//
//  ReminderViewModel.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 30.11.2025.
//

import Foundation

class ReminderViewModel {
    private let repository: ReminderRepositoryProtocol
    var reminders: [Reminder] = []

    init(repository: ReminderRepositoryProtocol) {
        self.repository = repository
    }

    @discardableResult
    func loadReminders() -> [Reminder] {
        do {
            reminders = try repository.fetchReminders()
        } catch {
            reminders = []
        }
        return reminders
    }

    @discardableResult
    func addReminder(_ reminder: Reminder) -> [Reminder] {
        save(reminder)
    }

    @discardableResult
    func updateReminder(_ reminder: Reminder) -> [Reminder] {
        save(reminder)
    }

    @discardableResult
    func deleteReminder(id: String) -> [Reminder] {
        do {
            reminders = try repository.deleteReminder(id: id)
        } catch {
            reminders.removeAll { $0.id == id }
        }
        return reminders
    }

    private func save(_ reminder: Reminder) -> [Reminder] {
        do {
            reminders = try repository.saveReminder(reminder)
        } catch {
            if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
                reminders[index] = reminder
            } else {
                reminders.insert(reminder, at: 0)
            }
        }
        return reminders
    }
}
