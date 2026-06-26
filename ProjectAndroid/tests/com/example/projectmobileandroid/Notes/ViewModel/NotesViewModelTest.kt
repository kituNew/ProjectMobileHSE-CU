package com.example.projectmobileandroid.Notes.ViewModel

import com.example.projectmobileandroid.Notes.Data.NotesRepository
import com.example.projectmobileandroid.Notes.Domain.DeleteNoteUseCase
import com.example.projectmobileandroid.Notes.Domain.GetNoteUseCase
import com.example.projectmobileandroid.Notes.Domain.ObserveNotesUseCase
import com.example.projectmobileandroid.Notes.Domain.SaveNoteUseCase
import com.example.projectmobileandroid.Notes.Model.Note
import com.example.projectmobileandroid.Notes.ViewModel.NotesViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class NotesViewModelTest {

    private val repository = FakeNotesRepository()
    private val viewModel = NotesViewModel(
        observeNotesUseCase = ObserveNotesUseCase(repository),
        getNoteUseCase = GetNoteUseCase(repository),
        saveNoteUseCase = SaveNoteUseCase(
            repository = repository,
            clock = { 100L }
        ),
        deleteNoteUseCase = DeleteNoteUseCase(repository)
    )

    @Test
    fun startEdit_loadsNoteIntoEditor() {
        repository.save(sampleNote(id = 7L))

        viewModel.startEdit(7L)

        assertEquals("Title", viewModel.title)
        assertEquals("Body", viewModel.text)
    }

    @Test
    fun startCreate_clearsEditor() {
        repository.save(sampleNote(id = 7L))
        viewModel.startEdit(7L)

        viewModel.startCreate()

        assertEquals("", viewModel.title)
        assertEquals("", viewModel.text)
    }

    @Test
    fun saveCurrentNote_savesEditorContent() {
        viewModel.onTitleChange("  New title  ")
        viewModel.onTextChange("  New text  ")

        val saved = viewModel.saveCurrentNote()

        assertTrue(saved)
        assertEquals("New title", viewModel.title)
        assertEquals("New text", viewModel.text)
        assertEquals(listOf(sampleNote(id = 100L, title = "New title", text = "New text")), repository.notes.value)
    }

    @Test
    fun saveCurrentNote_returnsFalseForBlankEditor() {
        val saved = viewModel.saveCurrentNote()

        assertFalse(saved)
        assertEquals(emptyList<Note>(), repository.notes.value)
    }

    @Test
    fun deleteEditingNote_removesNoteAndClearsEditor() {
        repository.save(sampleNote(id = 3L))
        viewModel.startEdit(3L)

        viewModel.deleteNote(3L)

        assertEquals(emptyList<Note>(), repository.notes.value)
        assertEquals("", viewModel.title)
        assertEquals("", viewModel.text)
    }

    private class FakeNotesRepository : NotesRepository {
        private val storedNotes = MutableStateFlow<List<Note>>(emptyList())
        override val notes: StateFlow<List<Note>> = storedNotes

        override fun getNote(id: Long): Note? {
            return notes.value.firstOrNull { it.id == id }
        }

        override fun save(note: Note) {
            storedNotes.value = notes.value
                .filterNot { it.id == note.id }
                .plus(note)
                .sortedByDescending { it.updatedAt }
        }

        override fun delete(id: Long) {
            storedNotes.value = notes.value.filterNot { it.id == id }
        }
    }
}

private fun sampleNote(
    id: Long,
    title: String = "Title",
    text: String = "Body",
    updatedAt: Long = 100L
) = Note(
    id = id,
    title = title,
    text = text,
    updatedAt = updatedAt
)
