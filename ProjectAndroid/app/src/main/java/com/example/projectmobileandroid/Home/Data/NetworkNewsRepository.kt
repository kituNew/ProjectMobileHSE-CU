package com.example.projectmobileandroid.Home.Data

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
        remoteDataSource.searchNews(
            query = query,
            apiKey = apiKey
        ).map { it.toDomain() }
    }
}
