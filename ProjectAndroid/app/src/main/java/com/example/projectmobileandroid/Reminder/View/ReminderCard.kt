package com.example.projectmobileandroid.Reminder.View

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.CornerBasedShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CardElevation
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import com.example.projectmobileandroid.Reminder.Model.Reminder

@Composable
fun ReminderCard(
    reminder: Reminder,
    onClick: () -> Unit
) {
    val alpha by animateFloatAsState(
        targetValue = if (reminder.isDone) 0.4f else 1f,
        label = ""
    )

    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }   // клик по всей карточке
    ) {
        // Кружок слева (чекбокс/свитчер)
        Box(
            modifier = Modifier
                .size(24.dp)
                .clip(CircleShape)
                .background(
                    if (reminder.isDone) Color(0xFF4CAF50) else Color.White
                )
                .border(
                    width = 2.dp,
                    color = Color.Gray,
                    shape = CircleShape
                )
                .clickable(       // отдельный клик по кружочку
                    indication = null,
                    interactionSource = remember { MutableInteractionSource() }
                ) {
                    onClick()
                },
            contentAlignment = Alignment.Center
        ) {
            if (reminder.isDone) {
                Icon(
                    imageVector = Icons.Default.Check,
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.size(16.dp)
                )
            }
        }

        Spacer(Modifier.width(8.dp))

        Card(
            modifier = Modifier
                .weight(1f)
                .alpha(alpha),
            shape = MaterialTheme.shapes.large,
            elevation = CardDefaults.cardElevation(6.dp)
        ) {
            Column(Modifier.padding(16.dp)) {

                Row(
                    Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = reminder.text,
                        style = MaterialTheme.typography.titleMedium,
                        textDecoration = if (reminder.isDone)
                            TextDecoration.LineThrough else TextDecoration.None
                    )

                    if (reminder.flag) {
                        Text("❗", color = Color.Red)
                    }
                }

                Text(
                    reminder.description,
                    color = Color.Gray,
                    style = MaterialTheme.typography.bodyMedium,
                    textDecoration = if (reminder.isDone)
                        TextDecoration.LineThrough else TextDecoration.None
                )

                Spacer(Modifier.height(12.dp))

                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    repeat(3) { index ->
                        val color =
                            if (index <= reminder.priority.level) reminder.priority.color
                            else Color.LightGray

                        Box(
                            modifier = Modifier
                                .size(14.dp)
                                .clip(CircleShape)
                                .background(color)
                        )
                    }
                }

                Spacer(Modifier.height(12.dp))

                reminder.toDate?.let {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.End
                    ) {
                        Text(it, color = Color.Gray)
                    }
                }
            }
        }
    }
}