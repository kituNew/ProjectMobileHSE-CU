package com.example.projectmobileandroid.Home.ViewModel

import android.content.Context
import com.example.projectmobileandroid.Home.Model.News
import com.example.projectmobileandroid.Home.Model.toDomain
import com.example.projectmobileandroid.Network.NetworkModule
import com.example.projectmobileandroid.Network.Servises.NewsApiService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class NewsRepository(context: Context) {

    private val apiService = NetworkModule.createService(NewsApiService::class.java)

    suspend fun getNews(
        source: String,
        section: String
    ): List<News> = withContext(Dispatchers.IO) {
        apiService.getNews(
            source = source,
            section = section,
            apiKey = NetworkModule.apiKey
        ).results.map { it.toDomain() }
    }
}