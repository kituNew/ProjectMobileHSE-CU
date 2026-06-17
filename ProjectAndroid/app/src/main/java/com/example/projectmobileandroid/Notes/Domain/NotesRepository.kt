package com.example.projectmobileandroid.Notes.Domain

import kotlinx.coroutines.flow.StateFlow

interface NotesRepository {
    val notes: StateFlow<List<Note>>

    fun getNote(id: Long): Note?

    fun save(note: Note)

    fun delete(id: Long)
}
