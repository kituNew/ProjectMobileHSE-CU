package com.example.projectmobileandroid.Reminder.Data

import android.content.Context
import com.example.projectmobileandroid.Reminder.Domain.ReminderRepository
import com.example.projectmobileandroid.Reminder.Model.Priority
import com.example.projectmobileandroid.Reminder.Model.Reminder
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update
import kotlinx.serialization.builtins.ListSerializer
import kotlinx.serialization.json.Json

class CachedReminderRepository(
    context: Context
) : ReminderRepository {

    private val preferences = context.applicationContext.getSharedPreferences(
        "cached_reminders",
        Context.MODE_PRIVATE
    )
    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
    }
    private val serializer = ListSerializer(Reminder.serializer())

    private val _reminders = MutableStateFlow(loadReminders())
    override val reminders: StateFlow<List<Reminder>> = _reminders

    override fun getReminder(id: String): Reminder? {
        return reminders.value.firstOrNull { it.id == id }
    }

    override fun save(reminder: Reminder) {
        _reminders.update { currentReminders ->
            currentReminders
                .filterNot { it.id == reminder.id }
                .plus(reminder)
                .also(::saveReminders)
        }
    }

    override fun delete(id: String) {
        _reminders.update { currentReminders ->
            currentReminders
                .filterNot { it.id == id }
                .also(::saveReminders)
        }
    }

    private fun loadReminders(): List<Reminder> {
        val rawReminders = preferences.getString(KEY_REMINDERS, null)
        if (rawReminders == null) {
            return defaultReminders().also(::saveReminders)
        }

        return runCatching {
            json.decodeFromString(serializer, rawReminders)
        }.getOrDefault(emptyList())
    }

    private fun saveReminders(reminders: List<Reminder>) {
        preferences.edit()
            .putString(KEY_REMINDERS, json.encodeToString(serializer, reminders))
            .apply()
    }

    private fun defaultReminders(): List<Reminder> {
        return listOf(
            Reminder(
                text = "Сходить в магазин",
                description = "зайти в Пятерочку по адресу: Новомосковская",
                priority = Priority.MEDIUM,
                flag = true,
                toDate = "12.06 12:00"
            ),
            Reminder(
                text = "Сходить в магазин",
                description = "зайти в Пятерочку по адресу: Новомосковская",
                priority = Priority.HIGH,
                flag = true,
                toDate = "12.06 12:00"
            ),
            Reminder(
                text = "Сходить в магазин",
                description = "зайти в Пятерочку по адресу: Новомосковская",
                priority = Priority.LOW,
                flag = false,
                toDate = "12.06 12:00"
            )
        )
    }

    private companion object {
        const val KEY_REMINDERS = "reminders"
    }
}
