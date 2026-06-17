package com.example.projectmobileandroid.Home.Data

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
        return apiService.getNews(
            query = query,
            apiKey = apiKey
        ).response.docs
    }
}
