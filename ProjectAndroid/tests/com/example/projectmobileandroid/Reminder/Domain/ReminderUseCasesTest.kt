package com.example.projectmobileandroid.Reminder.Domain

import com.example.projectmobileandroid.Reminder.Data.ReminderRepository
import com.example.projectmobileandroid.Reminder.Domain.CompleteReminderUseCase
import com.example.projectmobileandroid.Reminder.Domain.DeleteCompletedReminderUseCase
import com.example.projectmobileandroid.Reminder.Domain.DeleteReminderUseCase
import com.example.projectmobileandroid.Reminder.Domain.ObserveRemindersUseCase
import com.example.projectmobileandroid.Reminder.Domain.SaveReminderUseCase
import com.example.projectmobileandroid.Reminder.Model.Priority
import com.example.projectmobileandroid.Reminder.Model.Reminder
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test

class ReminderUseCasesTest {

    private val repository = FakeReminderRepository()

    @Test
    fun observeRemindersUseCase_returnsRepositoryStateFlow() {
        val useCase = ObserveRemindersUseCase(repository)

        assertSame(repository.reminders, useCase())
    }

    @Test
    fun saveReminderUseCase_savesReminderInRepository() {
        val reminder = makeReminder(id = "new")

        SaveReminderUseCase(repository)(reminder)

        assertEquals(reminder, repository.getReminder("new"))
    }

    @Test
    fun completeReminderUseCase_marksReminderDoneWithoutDeletingIt() {
        val reminder = makeReminder(id = "todo")
        repository.save(reminder)

        CompleteReminderUseCase(repository)(reminder)

        val completedReminder = repository.getReminder("todo")
        assertEquals("todo", completedReminder?.id)
        assertTrue(completedReminder?.isDone == true)
    }

    @Test
    fun deleteCompletedReminderUseCase_deletesOnlyCompletedReminder() {
        val incompleteReminder = makeReminder(id = "incomplete")
        val completedReminder = makeReminder(id = "complete", isDone = true)
        repository.save(incompleteReminder)
        repository.save(completedReminder)

        val useCase = DeleteCompletedReminderUseCase(repository)
        useCase("incomplete")
        useCase("complete")

        assertFalse(repository.getReminder("incomplete")?.isDone == true)
        assertNull(repository.getReminder("complete"))
    }

    @Test
    fun deleteReminderUseCase_deletesReminderById() {
        repository.save(makeReminder(id = "delete-me"))

        DeleteReminderUseCase(repository)("delete-me")

        assertEquals(emptyList<Reminder>(), repository.reminders.value)
    }

    private fun makeReminder(
        id: String,
        isDone: Boolean = false
    ): Reminder {
        return Reminder(
            id = id,
            text = "Task",
            description = "Description",
            priority = Priority.MEDIUM,
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
