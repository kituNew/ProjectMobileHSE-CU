package com.example.projectmobileandroid.DI

import android.content.Context
import com.example.projectmobileandroid.Favorites.Data.CachedFavoriteNewsRepository
import com.example.projectmobileandroid.Favorites.Domain.ObserveFavoriteNewsUseCase
import com.example.projectmobileandroid.Favorites.Domain.RemoveFavoriteNewsUseCase
import com.example.projectmobileandroid.Favorites.Domain.ToggleFavoriteNewsUseCase
import com.example.projectmobileandroid.Home.Data.NetworkNewsRepository
import com.example.projectmobileandroid.Home.Data.NewsRemoteDataSource
import com.example.projectmobileandroid.Home.Domain.GetNewsUseCase
import com.example.projectmobileandroid.Network.NetworkModule
import com.example.projectmobileandroid.Network.Servises.NewsApiService
import com.example.projectmobileandroid.Notes.Data.CachedNotesRepository
import com.example.projectmobileandroid.Notes.Domain.DeleteNoteUseCase
import com.example.projectmobileandroid.Notes.Domain.GetNoteUseCase
import com.example.projectmobileandroid.Notes.Domain.ObserveNotesUseCase
import com.example.projectmobileandroid.Notes.Domain.SaveNoteUseCase
import com.example.projectmobileandroid.Reminder.Data.CachedReminderRepository
import com.example.projectmobileandroid.Reminder.Domain.CompleteReminderUseCase
import com.example.projectmobileandroid.Reminder.Domain.DeleteCompletedReminderUseCase
import com.example.projectmobileandroid.Reminder.Domain.DeleteReminderUseCase
import com.example.projectmobileandroid.Reminder.Domain.ObserveRemindersUseCase
import com.example.projectmobileandroid.Reminder.Domain.SaveReminderUseCase

object AppContainer {

    private var isInitialized = false
    private lateinit var appContext: Context

    val getNewsUseCase: GetNewsUseCase by lazy {
        val apiService = NetworkModule.createService(NewsApiService::class.java)
        val remoteDataSource = NewsRemoteDataSource(apiService)
        val repository = NetworkNewsRepository(
            remoteDataSource = remoteDataSource,
            apiKey = NetworkModule.apiKey
        )

        GetNewsUseCase(repository)
    }

    private val notesRepository by lazy {
        CachedNotesRepository(appContext)
    }

    val reminderRepository by lazy {
        CachedReminderRepository(appContext)
    }

    private val favoriteNewsRepository by lazy {
        CachedFavoriteNewsRepository(appContext)
    }

    val observeNotesUseCase: ObserveNotesUseCase by lazy {
        ObserveNotesUseCase(notesRepository)
    }

    val getNoteUseCase: GetNoteUseCase by lazy {
        GetNoteUseCase(notesRepository)
    }

    val saveNoteUseCase: SaveNoteUseCase by lazy {
        SaveNoteUseCase(notesRepository)
    }

    val deleteNoteUseCase: DeleteNoteUseCase by lazy {
        DeleteNoteUseCase(notesRepository)
    }

    val observeRemindersUseCase: ObserveRemindersUseCase by lazy {
        ObserveRemindersUseCase(reminderRepository)
    }

    val saveReminderUseCase: SaveReminderUseCase by lazy {
        SaveReminderUseCase(reminderRepository)
    }

    val completeReminderUseCase: CompleteReminderUseCase by lazy {
        CompleteReminderUseCase(reminderRepository)
    }

    val deleteCompletedReminderUseCase: DeleteCompletedReminderUseCase by lazy {
        DeleteCompletedReminderUseCase(reminderRepository)
    }

    val deleteReminderUseCase: DeleteReminderUseCase by lazy {
        DeleteReminderUseCase(reminderRepository)
    }

    val observeFavoriteNewsUseCase: ObserveFavoriteNewsUseCase by lazy {
        ObserveFavoriteNewsUseCase(favoriteNewsRepository)
    }

    val toggleFavoriteNewsUseCase: ToggleFavoriteNewsUseCase by lazy {
        ToggleFavoriteNewsUseCase(favoriteNewsRepository)
    }

    val removeFavoriteNewsUseCase: RemoveFavoriteNewsUseCase by lazy {
        RemoveFavoriteNewsUseCase(favoriteNewsRepository)
    }

    fun init(context: Context) {
        if (isInitialized) return

        appContext = context.applicationContext
        NetworkModule.init(appContext)
        isInitialized = true
    }
}
