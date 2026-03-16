package com.example.projectmobileandroid.Notes.ViewModel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import com.example.projectmobileandroid.Notes.Model.NoteItem

class NotesViewModel : ViewModel() {

    var title by mutableStateOf("")
        private set

    var description by mutableStateOf("")
        private set

    var notes by mutableStateOf(listOf<NoteItem>())
        private set

    fun onTitleChange(value: String) {
        title = value
    }

    fun onDescriptionChange(value: String) {
        description = value
    }

    fun addNote() {
        val trimmedTitle = title.trim()
        val trimmedDescription = description.trim()

        if (trimmedTitle.isEmpty() && trimmedDescription.isEmpty()) return

        val newNote = NoteItem(
            id = System.currentTimeMillis(),
            title = trimmedTitle.ifEmpty { "Без названия" },
            description = trimmedDescription
        )

        notes = listOf(newNote) + notes
        title = ""
        description = ""
    }

    fun deleteNote(id: Long) {
        notes = notes.filterNot { it.id == id }
    }
}