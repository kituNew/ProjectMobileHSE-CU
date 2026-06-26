package com.example.projectmobileandroid.Notes.ViewModel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.example.projectmobileandroid.Notes.Domain.DeleteNoteUseCase
import com.example.projectmobileandroid.Notes.Domain.GetNoteUseCase
import com.example.projectmobileandroid.Notes.Model.Note
import com.example.projectmobileandroid.Notes.Domain.ObserveNotesUseCase
import com.example.projectmobileandroid.Notes.Domain.SaveNoteUseCase
import kotlinx.coroutines.flow.StateFlow

class NotesViewModel(
    observeNotesUseCase: ObserveNotesUseCase,
    private val getNoteUseCase: GetNoteUseCase,
    private val saveNoteUseCase: SaveNoteUseCase,
    private val deleteNoteUseCase: DeleteNoteUseCase
) : ViewModel() {

    val notes: StateFlow<List<Note>> = observeNotesUseCase()

    var title by mutableStateOf("")
        private set

    var text by mutableStateOf("")
        private set

    private var editingNoteId: Long? = null

    fun onTitleChange(value: String) {
        title = value
    }

    fun onTextChange(value: String) {
        text = value
    }

    fun startCreate() {
        editingNoteId = null
        title = ""
        text = ""
    }

    fun startEdit(id: Long) {
        val note = getNoteUseCase(id)
        editingNoteId = note?.id
        title = note?.title.orEmpty()
        text = note?.text.orEmpty()
    }

    fun saveCurrentNote(): Boolean {
        val savedNote = saveNoteUseCase(
            id = editingNoteId,
            title = title,
            text = text
        ) ?: return false

        editingNoteId = savedNote.id
        title = savedNote.title
        text = savedNote.text
        return true
    }

    fun deleteNote(id: Long) {
        deleteNoteUseCase(id)
        if (editingNoteId == id) {
            startCreate()
        }
    }

    fun clearEditor() {
        startCreate()
    }

    class Factory(
        private val observeNotesUseCase: ObserveNotesUseCase,
        private val getNoteUseCase: GetNoteUseCase,
        private val saveNoteUseCase: SaveNoteUseCase,
        private val deleteNoteUseCase: DeleteNoteUseCase
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(NotesViewModel::class.java)) {
                return NotesViewModel(
                    observeNotesUseCase = observeNotesUseCase,
                    getNoteUseCase = getNoteUseCase,
                    saveNoteUseCase = saveNoteUseCase,
                    deleteNoteUseCase = deleteNoteUseCase
                ) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
    }
}
