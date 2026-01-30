package com.example.projectmobileandroid.Home.View

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.projectmobileandroid.Home.ViewModel.CalcUiState
import com.example.projectmobileandroid.Home.ViewModel.ThreadToCoroutineViewModel

@Composable
fun ThreadToCoroutineScreen(vm: ThreadToCoroutineViewModel = viewModel()) {
    val state by vm.state.collectAsState()

    Column(
        Modifier.fillMaxSize().padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            Button(
                onClick = { vm.start() }, // TODO: заменить на start()
                enabled = state !is CalcUiState.Running
            ) {
                Text("Start")
            }

            OutlinedButton(
                onClick = { vm.cancel() }, // TODO: заменить на cancel()
                enabled = state is CalcUiState.Running
            ) {
                Text("Cancel")
            }
        }

        Divider()

        when (val s = state) {
            CalcUiState.Idle -> Text("Idle")
            CalcUiState.Canceled -> Text("Canceled")
            is CalcUiState.Error -> Text("Error: ${s.message}")
            is CalcUiState.Done -> Text("Done! result = ${s.result}")
            is CalcUiState.Running -> {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text("Running: ${s.progress}%")
                    LinearProgressIndicator(progress = s.progress / 100f)
                }
            }
        }
    }
}
