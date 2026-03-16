package com.example.projectmobileandroid.Home.Model

data class HomeUiState(
    val isLoading: Boolean = false,
    val allNews: List<News> = emptyList(),
    val visibleNews: List<News> = emptyList(),
    val query: String = "",
    val isFromCache: Boolean = false,
    val errorMessage: String? = null
)