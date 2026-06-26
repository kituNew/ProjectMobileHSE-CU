package com.example.projectmobileandroid.Reminder.Data

import com.example.projectmobileandroid.Reminder.Data.CachedReminderRepository
import com.example.projectmobileandroid.Reminder.Model.Priority
import com.example.projectmobileandroid.Reminder.Model.Reminder
import com.example.projectmobileandroid.Support.InMemoryContext
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class CachedReminderRepositoryTest {

    @Test
    fun newRepository_seedsDefaultRemindersOnlyOnce() {
        val context = InMemoryContext()

        val repository = CachedReminderRepository(context)
        val restoredRepository = CachedReminderRepository(context)

        assertEquals(3, repository.reminders.value.size)
        assertEquals(repository.reminders.value, restoredRepository.reminders.value)
    }

    @Test
    fun save_persistsReminderBetweenRepositoryInstances() {
        val context = InMemoryContext()
        val reminder = Reminder(
            id = "reminder-1",
            text = "Call",
            description = "Call back",
            priority = Priority.HIGH,
            flag = true,
            toDate = "18.06 12:00"
        )

        CachedReminderRepository(context).save(reminder)
        val restoredRepository = CachedReminderRepository(context)

        assertEquals(reminder, restoredRepository.getReminder(reminder.id))
    }

    @Test
    fun delete_removesReminderFromCache() {
        val context = InMemoryContext()
        val reminder = Reminder(
            id = "reminder-2",
            text = "Read",
            description = "Read article",
            priority = Priority.MEDIUM
        )
        val repository = CachedReminderRepository(context)
        repository.save(reminder)

        repository.delete(reminder.id)

        val restoredRepository = CachedReminderRepository(context)
        assertNull(restoredRepository.getReminder(reminder.id))
    }
}
