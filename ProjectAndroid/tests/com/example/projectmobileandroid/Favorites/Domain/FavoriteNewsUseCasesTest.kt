package com.example.projectmobileandroid.Favorites.Domain

import com.example.projectmobileandroid.Favorites.Domain.FavoriteNewsRepository
import com.example.projectmobileandroid.Favorites.Domain.ObserveFavoriteNewsUseCase
import com.example.projectmobileandroid.Favorites.Domain.RemoveFavoriteNewsUseCase
import com.example.projectmobileandroid.Favorites.Domain.ToggleFavoriteNewsUseCase
import com.example.projectmobileandroid.Home.Model.News
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import org.junit.Assert.assertEquals
import org.junit.Assert.assertSame
import org.junit.Test

class FavoriteNewsUseCasesTest {

    @Test
    fun observeFavoriteNewsUseCase_returnsRepositoryFlow() {
        val repository = FakeFavoriteNewsRepository()
        val useCase = ObserveFavoriteNewsUseCase(repository)

        assertSame(repository.favorites, useCase())
    }

    @Test
    fun toggleFavoriteNewsUseCase_addsAndRemovesNews() {
        val repository = FakeFavoriteNewsRepository()
        val useCase = ToggleFavoriteNewsUseCase(repository)
        val news = sampleNews()

        useCase(news)
        assertEquals(listOf(news), repository.favorites.value)

        useCase(news)
        assertEquals(emptyList<News>(), repository.favorites.value)
    }

    @Test
    fun removeFavoriteNewsUseCase_removesNewsById() {
        val repository = FakeFavoriteNewsRepository()
        val news = sampleNews()
        repository.toggle(news)

        RemoveFavoriteNewsUseCase(repository)(news.id)

        assertEquals(emptyList<News>(), repository.favorites.value)
    }

    private class FakeFavoriteNewsRepository : FavoriteNewsRepository {
        private val storedFavorites = MutableStateFlow<List<News>>(emptyList())
        override val favorites: StateFlow<List<News>> = storedFavorites

        override fun isFavorite(id: String): Boolean {
            return favorites.value.any { it.id == id }
        }

        override fun toggle(news: News) {
            storedFavorites.value = if (isFavorite(news.id)) {
                favorites.value.filterNot { it.id == news.id }
            } else {
                listOf(news) + favorites.value
            }
        }

        override fun remove(id: String) {
            storedFavorites.value = favorites.value.filterNot { it.id == id }
        }
    }
}

private fun sampleNews(
    id: String = "news-1",
    title: String = "Beer story"
) = News(
    id = id,
    title = title,
    abstractText = "Abstract",
    byline = "Byline",
    section = "Food",
    subsection = "Drinks",
    url = "https://example.com/$id",
    publishedDate = "2026-06-18",
    imageUrl = "https://example.com/$id.jpg",
    snippet = "Snippet",
    leadParagraph = "Lead",
    source = "NYT"
)
