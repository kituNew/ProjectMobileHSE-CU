package com.example.projectmobileandroid.Notes.Domain

import kotlinx.coroutines.flow.StateFlow

class ObserveNotesUseCase(
    private val repository: NotesRepository
) {
    operator fun invoke(): StateFlow<List<Note>> {
        return repository.notes
    }
}

class GetNoteUseCase(
    private val repository: NotesRepository
) {
    operator fun invoke(id: Long): Note? {
        return repository.getNote(id)
    }
}

class SaveNoteUseCase(
    private val repository: NotesRepository,
    private val clock: () -> Long = { System.currentTimeMillis() }
) {
    operator fun invoke(
        id: Long?,
        title: String,
        text: String
    ): Note? {
        val trimmedTitle = title.trim()
        val trimmedText = text.trim()
        if (trimmedTitle.isEmpty() && trimmedText.isEmpty()) return null

        val note = Note(
            id = id ?: clock(),
            title = trimmedTitle.ifEmpty { "Без названия" },
            text = trimmedText,
            updatedAt = clock()
        )

        repository.save(note)
        return note
    }
}

class DeleteNoteUseCase(
    private val repository: NotesRepository
) {
    operator fun invoke(id: Long) {
        repository.delete(id)
    }
}
