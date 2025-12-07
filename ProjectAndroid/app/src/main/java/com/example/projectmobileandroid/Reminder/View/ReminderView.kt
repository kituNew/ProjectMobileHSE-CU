package com.example.projectmobileandroid.Reminder.View

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.projectmobileandroid.Reminder.ViewModel.ReminderViewModel
import androidx.lifecycle.viewmodel.compose.viewModel


@Composable
fun ReminderView(
    modifier: Modifier = Modifier,
    viewModel: ReminderViewModel = viewModel()
) {
    val animDuration = 1000

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text("Задачи", style = MaterialTheme.typography.headlineLarge)

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
