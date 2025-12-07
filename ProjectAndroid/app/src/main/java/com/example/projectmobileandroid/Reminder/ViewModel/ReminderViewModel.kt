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
            id = 1L,
            text = "Сходить в магазин",
            description = "зайти в Пятерочку по адресу: Новомосковская",
            priority = Priority.MEDIUM,
            flag = true,
            toDate = "12.06 12:00"
        ),
        Reminder(
            id = 2L,
            text = "Сходить в магазин",
            description = "зайти в Пятерочку по адресу: Новомосковская",
            priority = Priority.HIGH,
            flag = true,
            toDate = "12.06 12:00"
        ),
        Reminder(
            id = 3L,
            text = "Сходить в магазин",
            description = "зайти в Пятерочку по адресу: Новомосковская",
            priority = Priority.LOW,
            flag = false,
            toDate = "12.06 12:00"
        )
    )
    val reminders: List<Reminder> get() = _reminders

    private val removeDelayMs = 1000L

    fun onReminderClicked(reminder: Reminder) {
        val index = _reminders.indexOfFirst { it.id == reminder.id }
        if (index == -1) return

        // помечаем как выполненный
        _reminders[index] = _reminders[index].copy(isDone = true)

        viewModelScope.launch {
            delay(removeDelayMs)
            // если он всё ещё есть и всё ещё done — удаляем
            val currentIndex = _reminders.indexOfFirst { it.id == reminder.id }
            if (currentIndex != -1 && _reminders[currentIndex].isDone) {
                _reminders.removeAt(currentIndex)
            }
        }
    }
}
