package com.example.projectmobileandroid.Notes.Domain

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class NotesUseCasesTest {

    private val repository = FakeNotesRepository()

    @Test
    fun saveNoteUseCase_ignoresBlankNote() {
        val useCase = SaveNoteUseCase(
            repository = repository,
            clock = { 100L }
        )

        val result = useCase(
            id = null,
            title = "   ",
            text = " "
        )

        assertNull(result)
        assertEquals(emptyList<Note>(), repository.notes.value)
    }

    @Test
    fun saveNoteUseCase_createsUntitledNoteWhenTitleIsBlank() {
        val useCase = SaveNoteUseCase(
            repository = repository,
            clock = { 200L }
        )

        val result = useCase(
            id = null,
            title = "",
            text = "Текст заметки"
        )

        assertEquals("Без названия", result?.title)
        assertEquals("Текст заметки", result?.text)
        assertEquals(1, repository.notes.value.size)
    }

    @Test
    fun saveNoteUseCase_updatesExistingNoteWithoutDuplicate() {
        val createUseCase = SaveNoteUseCase(
            repository = repository,
            clock = { 300L }
        )
        val editUseCase = SaveNoteUseCase(
            repository = repository,
            clock = { 400L }
        )

        val createdNote = createUseCase(
            id = null,
            title = "Черновик",
            text = "old"
        )
        editUseCase(
            id = createdNote?.id,
            title = "Готово",
            text = "new"
        )

        assertEquals(1, repository.notes.value.size)
        assertEquals("Готово", repository.notes.value.first().title)
        assertEquals("new", repository.notes.value.first().text)
    }

    @Test
    fun deleteNoteUseCase_removesNoteById() {
        repository.save(
            Note(
                id = 1L,
                title = "A",
                text = "B",
                updatedAt = 10L
            )
        )

        DeleteNoteUseCase(repository)(1L)

        assertEquals(emptyList<Note>(), repository.notes.value)
    }

    private class FakeNotesRepository : NotesRepository {
        private val storedNotes = MutableStateFlow<List<Note>>(emptyList())
        override val notes: StateFlow<List<Note>> = storedNotes

        override fun getNote(id: Long): Note? {
            return notes.value.firstOrNull { it.id == id }
        }

        override fun save(note: Note) {
            storedNotes.value = (notes.value.filterNot { it.id == note.id } + note)
                .sortedByDescending { it.updatedAt }
        }

        override fun delete(id: Long) {
            storedNotes.value = notes.value.filterNot { it.id == id }
        }
    }
}
