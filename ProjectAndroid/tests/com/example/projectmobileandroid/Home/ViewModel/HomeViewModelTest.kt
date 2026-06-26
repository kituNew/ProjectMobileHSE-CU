package com.example.projectmobileandroid.Home.ViewModel

import com.example.projectmobileandroid.Home.Domain.GetNewsUseCase
import com.example.projectmobileandroid.Home.Domain.NewsRepository
import com.example.projectmobileandroid.Home.Model.FallbackNews
import com.example.projectmobileandroid.Home.Model.News
import com.example.projectmobileandroid.Home.ViewModel.HomeViewModel
import com.example.projectmobileandroid.Support.MainDispatcherRule
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class HomeViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    @Test
    fun init_loadsDefaultNewsQuery() = runTest(mainDispatcherRule.testDispatcher) {
        val repository = FakeNewsRepository(news = listOf(sampleNews()))

        val viewModel = HomeViewModel(GetNewsUseCase(repository))
        advanceUntilIdle()

        assertEquals(listOf("buisness"), repository.queries)
        assertFalse(viewModel.uiState.value.isLoading)
        assertEquals(repository.news, viewModel.uiState.value.visibleNews)
        assertFalse(viewModel.uiState.value.isFromCache)
    }

    @Test
    fun onQueryChange_debouncesAndLoadsTrimmedQuery() = runTest(mainDispatcherRule.testDispatcher) {
        val repository = FakeNewsRepository(news = listOf(sampleNews(id = "search")))
        val viewModel = HomeViewModel(GetNewsUseCase(repository))
        advanceUntilIdle()
        repository.queries.clear()

        viewModel.onQueryChange("  beer  ")
        advanceTimeBy(500)
        advanceUntilIdle()

        assertEquals("  beer  ", viewModel.uiState.value.query)
        assertEquals(listOf("beer"), repository.queries)
        assertEquals(repository.news, viewModel.uiState.value.visibleNews)
    }

    @Test
    fun loadNews_whenUseCaseThrowsShowsFallbackNews() = runTest(mainDispatcherRule.testDispatcher) {
        val repository = FakeNewsRepository(error = IllegalStateException("network failed"))

        val viewModel = HomeViewModel(GetNewsUseCase(repository))
        advanceUntilIdle()

        assertFalse(viewModel.uiState.value.isLoading)
        assertTrue(viewModel.uiState.value.isFromCache)
        assertEquals(FallbackNews.items, viewModel.uiState.value.visibleNews)
        assertEquals("network failed", viewModel.uiState.value.errorMessage)
    }

    private class FakeNewsRepository(
        val news: List<News> = emptyList(),
        private val error: Throwable? = null
    ) : NewsRepository {
        val queries = mutableListOf<String>()

        override suspend fun searchNews(query: String): List<News> {
            queries.add(query)
            error?.let { throw it }
            return news
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
