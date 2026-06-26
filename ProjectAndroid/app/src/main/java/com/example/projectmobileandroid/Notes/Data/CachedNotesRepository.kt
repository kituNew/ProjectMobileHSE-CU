package com.example.projectmobileandroid.Notes.Data

import android.content.Context
import com.example.projectmobileandroid.Notes.Model.Note
import com.example.projectmobileandroid.Notes.Data.NotesRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update
import kotlinx.serialization.builtins.ListSerializer
import kotlinx.serialization.json.Json

class CachedNotesRepository(
    context: Context
) : NotesRepository {

    private val preferences = context.applicationContext.getSharedPreferences(
        "cached_notes",
        Context.MODE_PRIVATE
    )
    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
    }
    private val serializer = ListSerializer(Note.serializer())

    private val _notes = MutableStateFlow(loadNotes())
    override val notes: StateFlow<List<Note>> = _notes

    override fun getNote(id: Long): Note? {
        return notes.value.firstOrNull { it.id == id }
    }

    override fun save(note: Note) {
        _notes.update { currentNotes ->
            currentNotes
                .filterNot { it.id == note.id }
                .plus(note)
                .sortedByDescending { it.updatedAt }
                .also(::saveNotes)
        }
    }

    override fun delete(id: Long) {
        _notes.update { currentNotes ->
            currentNotes
                .filterNot { it.id == id }
                .also(::saveNotes)
        }
    }

    private fun loadNotes(): List<Note> {
        val rawNotes = preferences.getString(KEY_NOTES, null) ?: return emptyList()

        return runCatching {
            json.decodeFromString(serializer, rawNotes)
        }.getOrDefault(emptyList())
    }

    private fun saveNotes(notes: List<Note>) {
        preferences.edit()
            .putString(KEY_NOTES, json.encodeToString(serializer, notes))
            .apply()
    }

    private companion object {
        const val KEY_NOTES = "notes"
    }
}
