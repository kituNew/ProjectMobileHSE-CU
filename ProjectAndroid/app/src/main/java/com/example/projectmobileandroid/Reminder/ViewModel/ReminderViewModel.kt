package com.example.projectmobileandroid.Reminder.ViewModel

import androidx.lifecycle.ViewModel
import com.example.projectmobileandroid.Reminder.Model.Reminder
import com.example.projectmobileandroid.Reminder.Model.Priority

class ReminderViewModel: ViewModel() {
    val reminders = listOf(
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