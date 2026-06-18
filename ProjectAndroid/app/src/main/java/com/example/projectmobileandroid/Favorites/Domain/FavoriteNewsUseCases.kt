package com.example.projectmobileandroid.Favorites.Domain

import com.example.projectmobileandroid.Home.Model.News
import kotlinx.coroutines.flow.StateFlow

class ObserveFavoriteNewsUseCase(
    private val repository: FavoriteNewsRepository
) {
    operator fun invoke(): StateFlow<List<News>> {
        return repository.favorites
    }
}

class ToggleFavoriteNewsUseCase(
    private val repository: FavoriteNewsRepository
) {
    operator fun invoke(news: News) {
        repository.toggle(news)
    }
}

class RemoveFavoriteNewsUseCase(
    private val repository: FavoriteNewsRepository
) {
    operator fun invoke(id: String) {
        repository.remove(id)
    }
}
