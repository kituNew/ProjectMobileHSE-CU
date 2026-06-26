package com.example.projectmobileandroid.Reminder.Model

import androidx.compose.ui.graphics.Color
import kotlinx.serialization.Serializable

@Serializable
enum class Priority(val level: Int, val color: Color) {
    LOW(0, Color(0xFF86E36F)),     // зеленый
    MEDIUM(1, Color(0xFFFFE066)),  // желтый
    HIGH(2, Color(0xFFFF6B6B));    // красный
}
