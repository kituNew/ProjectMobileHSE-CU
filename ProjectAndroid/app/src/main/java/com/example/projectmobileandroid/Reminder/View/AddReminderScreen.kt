package com.example.projectmobileandroid.Reminder.View

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import com.example.projectmobileandroid.Reminder.Model.Reminder


import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.projectmobileandroid.Reminder.Model.Priority

@Composable
fun AddReminderScreen(
    onSave: (Reminder) -> Unit,
    onCancel: () -> Unit
) {
    var title by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var priority by remember { mutableStateOf(Priority.LOW) }
    var flag by remember { mutableStateOf(false) }
    var hasDeadline by remember { mutableStateOf(false) }
    var deadlineText by remember { mutableStateOf("26.02 10:00") } // просто текст, без пикера

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {

        // Верхняя панель с "Сохранить"
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp),
            horizontalArrangement = Arrangement.End,
            verticalAlignment = Alignment.CenterVertically
        ) {
            TextButton(
                onClick = {
                    if (title.isNotBlank()) {
                        onSave(
                            Reminder(
                                text = title,
                                description = description,
                                priority = priority,
                                flag = flag,
                                toDate = if (hasDeadline) deadlineText else null
                            )
                        )
                    }
                }
            ) {
                Text(
                    text = "Сохранить",
                    color = Color.Blue,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Medium
                )
            }
        }

        // Название
        GreyBlock {
            TextField(
                value = title,
                onValueChange = { title = it },
                placeholder = { Text("Название задачи *") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                colors = TextFieldDefaults.colors(
                    unfocusedContainerColor = Color.Transparent,
                    focusedContainerColor = Color.Transparent,
                    disabledContainerColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                    focusedIndicatorColor = Color.Transparent
                )
            )
        }

        Spacer(Modifier.height(12.dp))

        // Описание
        GreyBlock {
            TextField(
                value = description,
                onValueChange = { description = it },
                placeholder = { Text("описание") },
                modifier = Modifier.fillMaxWidth(),
                colors = TextFieldDefaults.colors(
                    unfocusedContainerColor = Color.Transparent,
                    focusedContainerColor = Color.Transparent,
                    disabledContainerColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                    focusedIndicatorColor = Color.Transparent
                )
            )
        }

        Spacer(Modifier.height(12.dp))

        // Приоритет
        GreyBlock {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Приоритет")

                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    PriorityDot(
                        selected = priority == Priority.LOW,
                        color = Priority.LOW.color
                    ) { priority = Priority.LOW }

                    PriorityDot(
                        selected = priority == Priority.MEDIUM,
                        color = Priority.MEDIUM.color
                    ) { priority = Priority.MEDIUM }

                    PriorityDot(
                        selected = priority == Priority.HIGH,
                        color = Priority.HIGH.color
                    ) { priority = Priority.HIGH }
                }
            }
        }

        Spacer(Modifier.height(12.dp))

        // Флаг
        GreyBlock {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("Флаг")
                    Text("  ❗", color = Color.Red)
                }

                Switch(
                    checked = flag,
                    onCheckedChange = { flag = it }
                )
            }
        }

        Spacer(Modifier.height(12.dp))

        // Выполнить до
        GreyBlock {
            Column(
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Выполнить до")

                    Switch(
                        checked = hasDeadline,
                        onCheckedChange = { hasDeadline = it }
                    )
                }

                if (hasDeadline) {
                    Spacer(Modifier.height(12.dp))
                    Box(
                        modifier = Modifier
                            .align(Alignment.End)
                            .clip(RoundedCornerShape(12.dp))
                            .background(Color(0xFFE5E5E5))
                            .padding(horizontal = 12.dp, vertical = 6.dp)
                    ) {
                        Text(
                            text = deadlineText,
                            color = Color.Blue
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun GreyBlock(
    content: @Composable ColumnScope.() -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(Color(0xFFE5E5E5))
            .padding(horizontal = 12.dp, vertical = 8.dp),
        content = content
    )
}

@Composable
private fun PriorityDot(
    selected: Boolean,
    color: Color,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .size(24.dp)
            .clip(RoundedCornerShape(50))
            .background(if (selected) color else Color(0xFFE0E0E0))
            .padding(4.dp)
            .clickable { onClick() },
        contentAlignment = Alignment.Center
    ) { }
}