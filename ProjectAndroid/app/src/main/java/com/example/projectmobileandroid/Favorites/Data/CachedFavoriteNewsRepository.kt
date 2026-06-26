package com.example.projectmobileandroid.Favorites.Data

import android.content.Context
import com.example.projectmobileandroid.Favorites.Domain.FavoriteNewsRepository
import com.example.projectmobileandroid.Home.Model.News
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update
import kotlinx.serialization.builtins.ListSerializer
import kotlinx.serialization.json.Json

class CachedFavoriteNewsRepository(
    context: Context
) : FavoriteNewsRepository {

    private val preferences = context.applicationContext.getSharedPreferences(
        "favorite_news",
        Context.MODE_PRIVATE
    )
    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
    }
    private val serializer = ListSerializer(News.serializer())

    private val _favorites = MutableStateFlow(loadFavorites())
    override val favorites: StateFlow<List<News>> = _favorites

    override fun isFavorite(id: String): Boolean {
        return favorites.value.any { it.id == id }
    }

    override fun toggle(news: News) {
        _favorites.update { currentFavorites ->
            val updatedFavorites = if (currentFavorites.any { it.id == news.id }) {
                currentFavorites.filterNot { it.id == news.id }
            } else {
                listOf(news) + currentFavorites
            }

            updatedFavorites.also(::saveFavorites)
        }
    }

    override fun remove(id: String) {
        _favorites.update { currentFavorites ->
            currentFavorites
                .filterNot { it.id == id }
                .also(::saveFavorites)
        }
    }

    private fun loadFavorites(): List<News> {
        val rawFavorites = preferences.getString(KEY_FAVORITES, null) ?: return emptyList()

        return runCatching {
            json.decodeFromString(serializer, rawFavorites)
        }.getOrDefault(emptyList())
    }

    private fun saveFavorites(favorites: List<News>) {
        preferences.edit()
            .putString(KEY_FAVORITES, json.encodeToString(serializer, favorites))
            .apply()
    }

    private companion object {
        const val KEY_FAVORITES = "favorites"
    }
}
