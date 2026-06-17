package com.example.projectmobileandroid.Home.Domain

import com.example.projectmobileandroid.Home.Model.News
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Test

class GetNewsUseCaseTest {

    @Test
    fun invoke_trimsQueryBeforeCallingRepository() = runBlocking {
        val repository = FakeNewsRepository()
        val useCase = GetNewsUseCase(repository)

        val result = useCase("  beer  ")

        assertEquals("beer", repository.lastQuery)
        assertEquals(repository.news, result)
    }

    private class FakeNewsRepository : NewsRepository {
        val news = listOf(
            News(
                id = "1",
                title = "Beer story",
                abstractText = "Abstract",
                byline = "Byline",
                section = "Food",
                subsection = "Drinks",
                url = "https://example.com",
                publishedDate = "2026-06-17",
                imageUrl = null
            )
        )

        var lastQuery: String? = null

        override suspend fun searchNews(query: String): List<News> {
            lastQuery = query
            return news
        }
    }
}
