package com.example.projectmobileandroid.Notes.Data

import com.example.projectmobileandroid.Notes.Domain.Note
import com.example.projectmobileandroid.Notes.Domain.NotesRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update

class InMemoryNotesRepository : NotesRepository {

    private val _notes = MutableStateFlow<List<Note>>(emptyList())
    override val notes: StateFlow<List<Note>> = _notes

    override fun getNote(id: Long): Note? {
        return notes.value.firstOrNull { it.id == id }
    }

    override fun save(note: Note) {
        _notes.update { currentNotes ->
            val updatedNotes = currentNotes
                .filterNot { it.id == note.id }
                .plus(note)

            updatedNotes.sortedByDescending { it.updatedAt }
        }
    }

    override fun delete(id: Long) {
        _notes.update { currentNotes ->
            currentNotes.filterNot { it.id == id }
        }
    }
}
