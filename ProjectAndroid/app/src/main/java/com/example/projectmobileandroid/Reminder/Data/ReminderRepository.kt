package com.example.projectmobileandroid.Reminder.Data

import com.example.projectmobileandroid.Reminder.Model.Reminder
import kotlinx.coroutines.flow.StateFlow

interface ReminderRepository {
    val reminders: StateFlow<List<Reminder>>

    fun getReminder(id: String): Reminder?

    fun save(reminder: Reminder)

    fun delete(id: String)
}