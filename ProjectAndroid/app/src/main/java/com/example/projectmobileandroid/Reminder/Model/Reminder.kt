package com.example.projectmobileandroid.Reminder.Model

data class Reminder(
    val text: String,
    val description: String,
    val priority: Priority,
    val flag: Boolean = false,
    val toDate: String? = null,
    val isDone: Boolean = false
)