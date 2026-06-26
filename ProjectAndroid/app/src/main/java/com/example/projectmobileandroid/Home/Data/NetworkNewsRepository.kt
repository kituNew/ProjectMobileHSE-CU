package com.example.projectmobileandroid.Home.Data

import android.util.Log
import com.example.projectmobileandroid.Home.Domain.NewsRepository
import com.example.projectmobileandroid.Home.Model.News
import com.example.projectmobileandroid.Home.Model.toDomain
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class NetworkNewsRepository(
    private val remoteDataSource: NewsRemoteDataSourceProtocol,
    private val apiKey: String
) : NewsRepository {

    override suspend fun searchNews(query: String): List<News> = withContext(Dispatchers.IO) {
        val news = remoteDataSource.searchNews(
            query = query,
            apiKey = apiKey
        ).map { it.toDomain() }

        Log.d(
            TAG,
            "Mapped news images: ${news.take(3).joinToString { it.imageUrl ?: "null" }}"
        )

        news
    }

    private companion object {
        const val TAG = "NYT_NETWORK"
    }
}
