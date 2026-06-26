package com.example.projectmobileandroid.Home.Domain

import com.example.projectmobileandroid.Home.Model.News

class GetNewsUseCase(
    private val repository: NewsRepository
) {
    suspend operator fun invoke(query: String): List<News> {
        return repository.searchNews(query.trim())
    }
}
