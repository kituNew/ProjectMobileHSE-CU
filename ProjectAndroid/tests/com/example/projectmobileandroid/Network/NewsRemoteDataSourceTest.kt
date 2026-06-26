package com.example.projectmobileandroid.Network

import com.example.projectmobileandroid.Home.Data.NewsRemoteDataSource
import com.example.projectmobileandroid.Home.Model.HeadlineDTO
import com.example.projectmobileandroid.Home.Model.NewsItemDTO
import com.example.projectmobileandroid.Home.Model.NewsResponseDTO
import com.example.projectmobileandroid.Home.Model.NewsSearchResponseDTO
import com.example.projectmobileandroid.Network.Servises.NewsApiService
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertSame
import org.junit.Assert.assertThrows
import org.junit.Test

class NewsRemoteDataSourceTest {

    @Test
    fun searchNews_returnsDocsAndPassesQueryAndApiKey() = runBlocking {
        val service = FakeNewsApiService(
            response = NewsResponseDTO(
                status = "OK",
                response = NewsSearchResponseDTO(
                    docs = listOf(sampleDto(id = "nyt-1"))
                )
            )
        )
        val dataSource = NewsRemoteDataSource(service)

        val docs = dataSource.searchNews(
            query = "beer",
            apiKey = "api-key"
        )

        assertEquals("beer", service.lastQuery)
        assertEquals("api-key", service.lastApiKey)
        assertEquals("nyt-1", docs.single().id)
    }

    @Test
    fun searchNews_returnsEmptyListWhenDocsAreNull() = runBlocking {
        val service = FakeNewsApiService(
            response = NewsResponseDTO(
                status = "OK",
                response = NewsSearchResponseDTO(docs = null)
            )
        )
        val dataSource = NewsRemoteDataSource(service)

        val docs = dataSource.searchNews(
            query = "beer",
            apiKey = "api-key"
        )

        assertEquals(emptyList<NewsItemDTO>(), docs)
    }

    @Test
    fun searchNews_rethrowsServiceError() {
        val error = IllegalStateException("boom")
        val dataSource = NewsRemoteDataSource(
            FakeNewsApiService(error = error)
        )

        val thrown = assertThrows(IllegalStateException::class.java) {
            runBlocking {
                dataSource.searchNews(
                    query = "beer",
                    apiKey = "api-key"
                )
            }
        }

        assertSame(error, thrown)
    }

    private class FakeNewsApiService(
        private val response: NewsResponseDTO = NewsResponseDTO(),
        private val error: Throwable? = null
    ) : NewsApiService {
        var lastQuery: String? = null
        var lastApiKey: String? = null

        override suspend fun getNews(
            query: String,
            apiKey: String
        ): NewsResponseDTO {
            lastQuery = query
            lastApiKey = apiKey
            error?.let { throw it }
            return response
        }
    }
}

private fun sampleDto(
    id: String
) = NewsItemDTO(
    id = id,
    headline = HeadlineDTO(main = "Beer story")
)
