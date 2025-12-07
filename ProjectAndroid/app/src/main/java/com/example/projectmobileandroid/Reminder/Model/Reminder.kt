package com.example.projectmobileandroid.Reminder.Model

import java.util.UUID

data class Reminder(
    val id: String = UUID.randomUUID().toString(),
    val text: String,
    val description: String,
    val priority: Priority,
    val flag: Boolean = false,
    val toDate: String? = null,
    val isDone: Boolean = false
)