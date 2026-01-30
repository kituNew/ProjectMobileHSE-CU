package com.example.projectmobileandroid.Home.View

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.projectmobileandroid.Home.ViewModel.HomeViewModelTest
import com.example.projectmobileandroid.Home.ViewModel.SearchUiStateTest

@Composable
fun HomeViewTest(
    modifier: Modifier = Modifier,
    vm: HomeViewModelTest = viewModel()
) {
    val query by vm.query.collectAsState()
    val state by vm.uiState.collectAsState()

    Column(
        Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        OutlinedTextField(
            value = query,
            onValueChange = { vm.onQueryChanged(it) },
            singleLine = true,
            label = { Text("Search users") },
            modifier = Modifier.fillMaxWidth()
        )

        when (val s = state) {
            SearchUiStateTest.Idle -> Text("Type something to search…")

            is SearchUiStateTest.Loading -> {
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    CircularProgressIndicator(modifier = Modifier.size(18.dp))
                    Text("Loading: ${s.query}")
                }
            }

            is SearchUiStateTest.Error -> {
                Text("Error for \"${s.query}\": ${s.message}")
                // TODO (не обязательно): кнопка Retry (но тогда нужно хранить lastQuery)
            }

            is SearchUiStateTest.Data -> {
                Text("Results for \"${s.query}\": ${s.items.size}")
                LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    items(s.items, key = { it.id }) { user ->
                        Card(Modifier.fillMaxWidth()) {
                            Text(user.name, modifier = Modifier.padding(12.dp))
                        }
                    }
                }
            }
        }
    }
}
