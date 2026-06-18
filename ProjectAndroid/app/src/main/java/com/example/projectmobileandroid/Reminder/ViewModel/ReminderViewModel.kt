package com.example.projectmobileandroid.Reminder.ViewModel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.projectmobileandroid.Reminder.Domain.ReminderRepository
import com.example.projectmobileandroid.Reminder.Model.Reminder
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class ReminderViewModel(
    private val repository: ReminderRepository
) : ViewModel() {

    val reminders: StateFlow<List<Reminder>> = repository.reminders

    private val removeDelayMs = 1000L   // 1 сек

    fun onReminderClicked(reminder: Reminder) {
        repository.save(reminder.copy(isDone = true))

        viewModelScope.launch {
            delay(removeDelayMs)
            val currentReminder = repository.getReminder(reminder.id)
            if (currentReminder?.isDone == true) {
                repository.delete(reminder.id)
            }
        }
    }

    fun addReminder(reminder: Reminder) {
        repository.save(reminder)
    }

    class Factory(
        private val repository: ReminderRepository
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(ReminderViewModel::class.java)) {
                return ReminderViewModel(repository) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
    }
}
