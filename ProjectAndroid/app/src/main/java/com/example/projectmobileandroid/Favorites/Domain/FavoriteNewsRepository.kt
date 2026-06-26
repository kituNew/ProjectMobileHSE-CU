package com.example.projectmobileandroid.Favorites.Domain

import com.example.projectmobileandroid.Home.Model.News
import kotlinx.coroutines.flow.StateFlow

interface FavoriteNewsRepository {
    val favorites: StateFlow<List<News>>

    fun isFavorite(id: String): Boolean

    fun toggle(news: News)

    fun remove(id: String)
}
