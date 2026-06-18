package com.example.projectmobileandroid.Home.Data

import android.util.Log
import com.example.projectmobileandroid.Home.Model.NewsItemDTO
import com.example.projectmobileandroid.Network.Servises.NewsApiService

interface NewsRemoteDataSourceProtocol {
    suspend fun searchNews(
        query: String,
        apiKey: String
    ): List<NewsItemDTO>
}

class NewsRemoteDataSource(
    private val apiService: NewsApiService
) : NewsRemoteDataSourceProtocol {

    override suspend fun searchNews(
        query: String,
        apiKey: String
    ): List<NewsItemDTO> {
        Log.d(
            TAG,
            "getNews(q=$query, apiKeyLength=${apiKey.length})"
        )

        return try {
            val response = apiService.getNews(
                query = query,
                apiKey = apiKey
            )
            val docs = response.response.docs.orEmpty()
            Log.d(TAG, "Parsed response: status=${response.status}, docs=${docs.size}")
            docs
        } catch (throwable: Throwable) {
            Log.e(
                TAG,
                "Retrofit request/parsing failed: ${throwable.javaClass.simpleName}: ${throwable.message}",
                throwable
            )
            throw throwable
        }
    }

    private companion object {
        const val TAG = "NYT_NETWORK"
    }
}
