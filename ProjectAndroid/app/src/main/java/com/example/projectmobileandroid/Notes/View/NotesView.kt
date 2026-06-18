package com.example.projectmobileandroid.Notes.View

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.NoteAdd
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Save
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.projectmobileandroid.DI.AppContainer
import com.example.projectmobileandroid.Notes.Domain.Note
import com.example.projectmobileandroid.Notes.ViewModel.NotesViewModel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

private enum class NotesRoute {
    List,
    Create,
    Details
}

@Composable
fun NotesView(
    modifier: Modifier = Modifier,
    vm: NotesViewModel? = null
) {
    val context = androidx.compose.ui.platform.LocalContext.current
    AppContainer.init(context)
    val notesViewModel = vm ?: viewModel(
        factory = NotesViewModel.Factory(
            observeNotesUseCase = AppContainer.observeNotesUseCase,
            getNoteUseCase = AppContainer.getNoteUseCase,
            saveNoteUseCase = AppContainer.saveNoteUseCase,
            deleteNoteUseCase = AppContainer.deleteNoteUseCase
        )
    )
    var routeName by rememberSaveable { mutableStateOf(NotesRoute.List.name) }
    var selectedNoteId by rememberSaveable { mutableStateOf<Long?>(null) }
    val route = NotesRoute.valueOf(routeName)

    BackHandler(enabled = route != NotesRoute.List) {
        notesViewModel.clearEditor()
        selectedNoteId = null
        routeName = NotesRoute.List.name
    }

    when (route) {
        NotesRoute.List -> NotesListScreen(
            modifier = modifier,
            vm = notesViewModel,
            onCreateClick = {
                notesViewModel.startCreate()
                selectedNoteId = null
                routeName = NotesRoute.Create.name
            },
            onOpenNote = { note ->
                notesViewModel.startEdit(note.id)
                selectedNoteId = note.id
                routeName = NotesRoute.Details.name
            }
        )

        NotesRoute.Create -> NoteEditorScreen(
            modifier = modifier,
            vm = notesViewModel,
            title = "Новая заметка",
            onBack = {
                notesViewModel.clearEditor()
                routeName = NotesRoute.List.name
            },
            onSaved = {
                selectedNoteId = null
                routeName = NotesRoute.List.name
            },
            onDelete = null
        )

        NotesRoute.Details -> NoteEditorScreen(
            modifier = modifier,
            vm = notesViewModel,
            title = "Заметка",
            onBack = {
                notesViewModel.clearEditor()
                selectedNoteId = null
                routeName = NotesRoute.List.name
            },
            onSaved = {
                selectedNoteId = null
                routeName = NotesRoute.List.name
            },
            onDelete = selectedNoteId?.let { id ->
                {
                    notesViewModel.deleteNote(id)
                    selectedNoteId = null
                    routeName = NotesRoute.List.name
                }
            }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NotesListScreen(
    modifier: Modifier,
    vm: NotesViewModel,
    onCreateClick: () -> Unit,
    onOpenNote: (Note) -> Unit
) {
    val notes by vm.notes.collectAsState()

    Scaffold(
        modifier = modifier.fillMaxSize(),
        topBar = {
            CenterAlignedTopAppBar(
                title = {
                    Text("Заметки")
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(onClick = onCreateClick) {
                Icon(
                    imageVector = Icons.Default.Add,
                    contentDescription = "Создать заметку"
                )
            }
        }
    ) { paddingValues ->
        if (notes.isEmpty()) {
            EmptyNotesState(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues),
                onCreateClick = onCreateClick
            )
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(
                    items = notes,
                    key = { it.id }
                ) { note ->
                    NoteCard(
                        note = note,
                        onClick = { onOpenNote(note) },
                        onDeleteClick = { vm.deleteNote(note.id) }
                    )
                }
            }
        }
    }
}

@Composable
private fun EmptyNotesState(
    modifier: Modifier,
    onCreateClick: () -> Unit
) {
    Box(
        modifier = modifier.padding(24.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Surface(
                shape = RoundedCornerShape(20.dp),
                color = MaterialTheme.colorScheme.primaryContainer
            ) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.NoteAdd,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onPrimaryContainer,
                    modifier = Modifier.padding(18.dp)
                )
            }

            Text(
                text = "Пока заметок нет",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.SemiBold
            )

            Text(
                text = "Создайте первую запись для идей, планов или быстрых мыслей.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Button(onClick = onCreateClick) {
                Icon(
                    imageVector = Icons.Default.Add,
                    contentDescription = null
                )
                Text(
                    text = "Создать",
                    modifier = Modifier.padding(start = 8.dp)
                )
            }
        }
    }
}

@Composable
private fun NoteCard(
    note: Note,
    onClick: () -> Unit,
    onDeleteClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainerHigh
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Top
            ) {
                Column(
                    modifier = Modifier
                        .weight(1f)
                        .padding(end = 12.dp)
                ) {
                    Text(
                        text = note.title,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )

                    Spacer(modifier = Modifier.height(4.dp))

                    Text(
                        text = formatNoteDate(note.updatedAt),
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                IconButton(onClick = onDeleteClick) {
                    Icon(
                        imageVector = Icons.Default.Delete,
                        contentDescription = "Удалить заметку"
                    )
                }
            }

            if (note.text.isNotBlank()) {
                HorizontalDivider(modifier = Modifier.padding(vertical = 10.dp))

                Text(
                    text = note.text,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 3,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NoteEditorScreen(
    modifier: Modifier,
    vm: NotesViewModel,
    title: String,
    onBack: () -> Unit,
    onSaved: () -> Unit,
    onDelete: (() -> Unit)?
) {
    Scaffold(
        modifier = modifier.fillMaxSize(),
        topBar = {
            TopAppBar(
                title = { Text(title) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Назад"
                        )
                    }
                },
                actions = {
                    onDelete?.let { delete ->
                        IconButton(onClick = delete) {
                            Icon(
                                imageVector = Icons.Default.Delete,
                                contentDescription = "Удалить заметку"
                            )
                        }
                    }

                    IconButton(
                        onClick = {
                            if (vm.saveCurrentNote()) {
                                onSaved()
                            }
                        }
                    ) {
                        Icon(
                            imageVector = Icons.Default.Save,
                            contentDescription = "Сохранить заметку"
                        )
                    }
                }
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            item {
                OutlinedTextField(
                    value = vm.title,
                    onValueChange = vm::onTitleChange,
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    label = { Text("Заголовок") },
                    leadingIcon = {
                        Icon(
                            imageVector = Icons.Default.Edit,
                            contentDescription = null
                        )
                    }
                )
            }

            item {
                OutlinedTextField(
                    value = vm.text,
                    onValueChange = vm::onTextChange,
                    modifier = Modifier
                        .fillMaxWidth()
                        .heightIn(min = 260.dp),
                    label = { Text("Текст") },
                    minLines = 10
                )
            }

            item {
                FilledTonalButton(
                    onClick = {
                        if (vm.saveCurrentNote()) {
                            onSaved()
                        }
                    },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Icon(
                        imageVector = Icons.Default.Save,
                        contentDescription = null
                    )
                    Text(
                        text = "Сохранить",
                        modifier = Modifier.padding(start = 8.dp)
                    )
                }
            }
        }
    }
}

private fun formatNoteDate(updatedAt: Long): String {
    val formatter = SimpleDateFormat("dd.MM.yyyy HH:mm", Locale.getDefault())
    return formatter.format(Date(updatedAt))
}
