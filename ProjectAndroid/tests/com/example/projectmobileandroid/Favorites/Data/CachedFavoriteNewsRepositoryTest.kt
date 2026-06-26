package com.example.projectmobileandroid.Favorites.Data

import com.example.projectmobileandroid.Favorites.Data.CachedFavoriteNewsRepository
import com.example.projectmobileandroid.Home.Model.News
import com.example.projectmobileandroid.Support.InMemoryContext
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class CachedFavoriteNewsRepositoryTest {

    @Test
    fun toggle_persistsFullNewsBetweenRepositoryInstances() {
        val context = InMemoryContext()
        val news = sampleNews()

        CachedFavoriteNewsRepository(context).toggle(news)
        val restoredRepository = CachedFavoriteNewsRepository(context)

        assertTrue(restoredRepository.isFavorite(news.id))
        assertEquals(listOf(news), restoredRepository.favorites.value)
    }

    @Test
    fun remove_deletesFavoriteFromCache() {
        val context = InMemoryContext()
        val news = sampleNews()
        val repository = CachedFavoriteNewsRepository(context)
        repository.toggle(news)

        repository.remove(news.id)

        val restoredRepository = CachedFavoriteNewsRepository(context)
        assertFalse(restoredRepository.isFavorite(news.id))
        assertEquals(emptyList<News>(), restoredRepository.favorites.value)
    }
}

private fun sampleNews() = News(
    id = "favorite-1",
    title = "Favorite story",
    abstractText = "Abstract",
    byline = "Byline",
    section = "Food",
    subsection = "Drinks",
    url = "https://example.com/favorite",
    publishedDate = "2026-06-18",
    imageUrl = "https://example.com/favorite.jpg",
    snippet = "Snippet",
    leadParagraph = "Lead",
    source = "NYT"
)
