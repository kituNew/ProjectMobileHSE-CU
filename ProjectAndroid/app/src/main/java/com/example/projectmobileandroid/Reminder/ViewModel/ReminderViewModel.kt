package com.example.projectmobileandroid.Reminder.ViewModel

import androidx.compose.runtime.mutableStateListOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.projectmobileandroid.Reminder.Model.Reminder
import com.example.projectmobileandroid.Reminder.Model.Priority
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class ReminderViewModel : ViewModel() {

    private val _reminders = mutableStateListOf(
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
    val reminders: List<Reminder> get() = _reminders

    private val removeDelayMs = 1000L   // 1 сек

    fun onReminderClicked(reminder: Reminder) {
        val index = _reminders.indexOfFirst { it.id == reminder.id }
        if (index == -1) return

        _reminders[index] = _reminders[index].copy(isDone = true)

        viewModelScope.launch {
            delay(removeDelayMs)
            val currentIndex = _reminders.indexOfFirst { it.id == reminder.id }
            if (currentIndex != -1 && _reminders[currentIndex].isDone) {
                _reminders.removeAt(currentIndex)
            }
        }
    }

    fun addReminder(reminder: Reminder) {
        _reminders.add(reminder)
    }
}
