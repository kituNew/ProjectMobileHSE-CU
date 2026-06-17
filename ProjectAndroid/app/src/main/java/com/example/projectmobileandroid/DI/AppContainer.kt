package com.example.projectmobileandroid.DI

import android.content.Context
import com.example.projectmobileandroid.Home.Data.NetworkNewsRepository
import com.example.projectmobileandroid.Home.Data.NewsRemoteDataSource
import com.example.projectmobileandroid.Home.Domain.GetNewsUseCase
import com.example.projectmobileandroid.Network.NetworkModule
import com.example.projectmobileandroid.Network.Servises.NewsApiService
import com.example.projectmobileandroid.Notes.Data.InMemoryNotesRepository
import com.example.projectmobileandroid.Notes.Domain.DeleteNoteUseCase
import com.example.projectmobileandroid.Notes.Domain.GetNoteUseCase
import com.example.projectmobileandroid.Notes.Domain.ObserveNotesUseCase
import com.example.projectmobileandroid.Notes.Domain.SaveNoteUseCase

object AppContainer {

    private var isInitialized = false

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
        InMemoryNotesRepository()
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

    fun init(context: Context) {
        if (isInitialized) return

        NetworkModule.init(context)
        isInitialized = true
    }
}
