package com.example.projectmobileandroid.Notes.Data

import com.example.projectmobileandroid.Notes.Data.CachedNotesRepository
import com.example.projectmobileandroid.Notes.Model.Note
import com.example.projectmobileandroid.Support.InMemoryContext
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class CachedNotesRepositoryTest {

    @Test
    fun save_persistsNoteBetweenRepositoryInstances() {
        val context = InMemoryContext()
        val note = Note(
            id = 1L,
            title = "Title",
            text = "Text",
            updatedAt = 100L
        )

        CachedNotesRepository(context).save(note)
        val restoredRepository = CachedNotesRepository(context)

        assertEquals(note, restoredRepository.getNote(1L))
        assertEquals(listOf(note), restoredRepository.notes.value)
    }

    @Test
    fun delete_removesNoteFromCache() {
        val context = InMemoryContext()
        val repository = CachedNotesRepository(context)
        repository.save(
            Note(
                id = 2L,
                title = "Title",
                text = "Text",
                updatedAt = 200L
            )
        )

        repository.delete(2L)

        val restoredRepository = CachedNotesRepository(context)
        assertNull(restoredRepository.getNote(2L))
        assertEquals(emptyList<Note>(), restoredRepository.notes.value)
    }
}
