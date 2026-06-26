package com.example.projectmobileandroid.Reminder.ViewModel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.projectmobileandroid.Reminder.Domain.CompleteReminderUseCase
import com.example.projectmobileandroid.Reminder.Domain.DeleteCompletedReminderUseCase
import com.example.projectmobileandroid.Reminder.Domain.ObserveRemindersUseCase
import com.example.projectmobileandroid.Reminder.Domain.SaveReminderUseCase
import com.example.projectmobileandroid.Reminder.Model.Reminder
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class ReminderViewModel(
    private val observeRemindersUseCase: ObserveRemindersUseCase,
    private val saveReminderUseCase: SaveReminderUseCase,
    private val completeReminderUseCase: CompleteReminderUseCase,
    private val deleteCompletedReminderUseCase: DeleteCompletedReminderUseCase,
    private val scheduleDelayedAction: ((delayMs: Long, action: () -> Unit) -> Unit)? = null
) : ViewModel() {

    val reminders: StateFlow<List<Reminder>> = observeRemindersUseCase()

    fun onReminderClicked(reminder: Reminder) {
        completeReminderUseCase(reminder)
        scheduleAfterDelay(REMOVE_DELAY_MS) {
            deleteCompletedReminderUseCase(reminder.id)
        }
    }

    fun addReminder(reminder: Reminder) {
        saveReminderUseCase(reminder)
    }

    class Factory(
        private val observeRemindersUseCase: ObserveRemindersUseCase,
        private val saveReminderUseCase: SaveReminderUseCase,
        private val completeReminderUseCase: CompleteReminderUseCase,
        private val deleteCompletedReminderUseCase: DeleteCompletedReminderUseCase
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(ReminderViewModel::class.java)) {
                return ReminderViewModel(
                    observeRemindersUseCase = observeRemindersUseCase,
                    saveReminderUseCase = saveReminderUseCase,
                    completeReminderUseCase = completeReminderUseCase,
                    deleteCompletedReminderUseCase = deleteCompletedReminderUseCase
                ) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
    }

    private fun scheduleAfterDelay(
        delayMs: Long,
        action: () -> Unit
    ) {
        val scheduler = scheduleDelayedAction
        if (scheduler != null) {
            scheduler(delayMs, action)
            return
        }

        viewModelScope.launch {
            delay(delayMs)
            action()
        }
    }

    private companion object {
        const val REMOVE_DELAY_MS = 1000L
    }
}
