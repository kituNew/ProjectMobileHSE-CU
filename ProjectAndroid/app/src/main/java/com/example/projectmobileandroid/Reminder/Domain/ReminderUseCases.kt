package com.example.projectmobileandroid.Reminder.Domain

import com.example.projectmobileandroid.Reminder.Data.ReminderRepository
import com.example.projectmobileandroid.Reminder.Model.Reminder
import kotlinx.coroutines.flow.StateFlow

class ObserveRemindersUseCase(
    private val repository: ReminderRepository
) {
    operator fun invoke(): StateFlow<List<Reminder>> {
        return repository.reminders
    }
}

class SaveReminderUseCase(
    private val repository: ReminderRepository
) {
    operator fun invoke(reminder: Reminder) {
        repository.save(reminder)
    }
}

class CompleteReminderUseCase(
    private val repository: ReminderRepository
) {
    operator fun invoke(reminder: Reminder) {
        repository.save(reminder.copy(isDone = true))
    }
}

class DeleteCompletedReminderUseCase(
    private val repository: ReminderRepository
) {
    operator fun invoke(id: String) {
        val reminder = repository.getReminder(id)
        if (reminder?.isDone == true) {
            repository.delete(id)
        }
    }
}

class DeleteReminderUseCase(
    private val repository: ReminderRepository
) {
    operator fun invoke(id: String) {
        repository.delete(id)
    }
}
