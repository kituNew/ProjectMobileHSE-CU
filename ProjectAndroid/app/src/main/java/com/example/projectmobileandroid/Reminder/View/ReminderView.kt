package com.example.projectmobileandroid.Reminder.View

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.projectmobileandroid.Reminder.ViewModel.ReminderViewModel
import androidx.lifecycle.viewmodel.compose.viewModel

@Composable
fun ReminderView(
    modifier: Modifier = Modifier,
    viewModel: ReminderViewModel = viewModel()
) {
    var isAdding by remember { mutableStateOf(false) }
    val animDuration = 1000

    if (isAdding) {
        AddReminderScreen(
            onSave = { reminder ->
                viewModel.addReminder(reminder)
                isAdding = false
            },
            onCancel = { isAdding = false }
        )
    } else {
        Column(
            modifier = modifier
                .fillMaxSize()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Задачи", style = MaterialTheme.typography.headlineLarge)

                TextButton(onClick = { isAdding = true }) {
                    Text("+", fontSize = 28.sp, color = Color.Blue)
                }
            }

            Spacer(Modifier.height(16.dp))

            LazyColumn(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                items(
                    items = viewModel.reminders,
                    key = { it.id }
                ) { reminder ->
                    AnimatedVisibility(
                        visible = !reminder.isDone,
                        exit = fadeOut(
                            animationSpec = tween(animDuration)
                        ) + shrinkVertically(
                            animationSpec = tween(animDuration)
                        ),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        ReminderCard(
                            reminder = reminder,
                            onClick = { viewModel.onReminderClicked(reminder) }
                        )
                    }
                }
            }
        }
    }
}