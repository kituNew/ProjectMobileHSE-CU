package com.example.projectmobileandroid.Home.Domain

import com.example.projectmobileandroid.Home.Model.News

interface NewsRepository {
    suspend fun searchNews(query: String): List<News>
}
