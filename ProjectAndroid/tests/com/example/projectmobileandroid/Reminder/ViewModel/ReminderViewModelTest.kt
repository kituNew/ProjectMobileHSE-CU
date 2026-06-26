package com.example.projectmobileandroid.Reminder.ViewModel

import com.example.projectmobileandroid.Reminder.Data.ReminderRepository
import com.example.projectmobileandroid.Reminder.Domain.CompleteReminderUseCase
import com.example.projectmobileandroid.Reminder.Domain.DeleteCompletedReminderUseCase
import com.example.projectmobileandroid.Reminder.Domain.ObserveRemindersUseCase
import com.example.projectmobileandroid.Reminder.Domain.SaveReminderUseCase
import com.example.projectmobileandroid.Reminder.Model.Priority
import com.example.projectmobileandroid.Reminder.Model.Reminder
import com.example.projectmobileandroid.Reminder.ViewModel.ReminderViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class ReminderViewModelTest {

    private val repository = FakeReminderRepository()
    private var scheduledDelayMs: Long? = null
    private var scheduledAction: (() -> Unit)? = null
    private val viewModel = ReminderViewModel(
        observeRemindersUseCase = ObserveRemindersUseCase(repository),
        saveReminderUseCase = SaveReminderUseCase(repository),
        completeReminderUseCase = CompleteReminderUseCase(repository),
        deleteCompletedReminderUseCase = DeleteCompletedReminderUseCase(repository),
        scheduleDelayedAction = { delayMs, action ->
            scheduledDelayMs = delayMs
            scheduledAction = action
        }
    )

    @Test
    fun reminders_exposesRepositoryFlow() {
        val reminder = makeReminder(id = "visible")
        repository.save(reminder)

        assertEquals(listOf(reminder), viewModel.reminders.value)
    }

    @Test
    fun addReminder_savesReminder() {
        val reminder = makeReminder(id = "created")

        viewModel.addReminder(reminder)

        assertEquals(reminder, repository.getReminder("created"))
    }

    @Test
    fun onReminderClicked_marksReminderDoneAndSchedulesCompletedDeletion() {
        val reminder = makeReminder(id = "done-later")
        repository.save(reminder)

        viewModel.onReminderClicked(reminder)

        assertTrue(repository.getReminder("done-later")?.isDone == true)
        assertEquals(1000L, scheduledDelayMs)
        assertNotNull(repository.getReminder("done-later"))

        scheduledAction?.invoke()

        assertNull(repository.getReminder("done-later"))
    }

    private fun makeReminder(
        id: String,
        isDone: Boolean = false
    ): Reminder {
        return Reminder(
            id = id,
            text = "Task",
            description = "Description",
            priority = Priority.HIGH,
            isDone = isDone
        )
    }

    private class FakeReminderRepository : ReminderRepository {
        private val storedReminders = MutableStateFlow<List<Reminder>>(emptyList())
        override val reminders: StateFlow<List<Reminder>> = storedReminders

        override fun getReminder(id: String): Reminder? {
            return reminders.value.firstOrNull { it.id == id }
        }

        override fun save(reminder: Reminder) {
            storedReminders.value = reminders.value
                .filterNot { it.id == reminder.id }
                .plus(reminder)
        }

        override fun delete(id: String) {
            storedReminders.value = reminders.value.filterNot { it.id == id }
        }
    }
}
