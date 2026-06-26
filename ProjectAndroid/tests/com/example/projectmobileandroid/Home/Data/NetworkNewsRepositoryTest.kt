package com.example.projectmobileandroid.Home.Data

import com.example.projectmobileandroid.Home.Data.NetworkNewsRepository
import com.example.projectmobileandroid.Home.Data.NewsRemoteDataSourceProtocol
import com.example.projectmobileandroid.Home.Model.HeadlineDTO
import com.example.projectmobileandroid.Home.Model.MultimediaDTO
import com.example.projectmobileandroid.Home.Model.MultimediaImageDTO
import com.example.projectmobileandroid.Home.Model.NewsItemDTO
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Test

class NetworkNewsRepositoryTest {

    @Test
    fun searchNews_passesQueryAndApiKeyToRemoteDataSource() = runBlocking {
        val remoteDataSource = FakeNewsRemoteDataSource(
            articles = listOf(sampleDto(id = "article-1"))
        )
        val repository = NetworkNewsRepository(
            remoteDataSource = remoteDataSource,
            apiKey = "test-api-key"
        )

        val news = repository.searchNews("beer")

        assertEquals("beer", remoteDataSource.lastQuery)
        assertEquals("test-api-key", remoteDataSource.lastApiKey)
        assertEquals("article-1", news.single().id)
        assertEquals("Beer story", news.single().title)
        assertEquals("https://www.nytimes.com/images/beer.jpg", news.single().imageUrl)
    }

    private class FakeNewsRemoteDataSource(
        private val articles: List<NewsItemDTO>
    ) : NewsRemoteDataSourceProtocol {
        var lastQuery: String? = null
        var lastApiKey: String? = null

        override suspend fun searchNews(
            query: String,
            apiKey: String
        ): List<NewsItemDTO> {
            lastQuery = query
            lastApiKey = apiKey
            return articles
        }
    }
}

private fun sampleDto(
    id: String = "article-1"
) = NewsItemDTO(
    id = id,
    abstract = "Abstract",
    snippet = "Snippet",
    webUrl = "https://www.nytimes.com/article",
    headline = HeadlineDTO(main = "Beer story"),
    multimedia = MultimediaDTO(
        defaultImage = MultimediaImageDTO(url = "images/beer.jpg")
    )
)
