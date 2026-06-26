package com.example.projectmobileandroid.Home.Model

import com.example.projectmobileandroid.Home.Model.BylineDTO
import com.example.projectmobileandroid.Home.Model.HeadlineDTO
import com.example.projectmobileandroid.Home.Model.MultimediaDTO
import com.example.projectmobileandroid.Home.Model.MultimediaImageDTO
import com.example.projectmobileandroid.Home.Model.NewsItemDTO
import com.example.projectmobileandroid.Home.Model.toDomain
import org.junit.Assert.assertEquals
import org.junit.Test

class NewsMappingTest {

    @Test
    fun toDomain_mapsNytArticleFieldsAndNormalizesRelativeImageUrl() {
        val dto = NewsItemDTO(
            id = null,
            abstract = null,
            snippet = "Short snippet",
            leadParagraph = "Lead paragraph",
            webUrl = "https://www.nytimes.com/article",
            source = "The New York Times",
            pubDate = "2026-06-18T10:15:00Z",
            sectionName = "Food",
            subsectionName = "Drinks",
            headline = HeadlineDTO(main = "Beer story"),
            byline = BylineDTO(original = "By Test Author"),
            multimedia = MultimediaDTO(
                defaultImage = MultimediaImageDTO(
                    url = "images/2026/06/beer.jpg",
                    height = 600,
                    width = 900
                )
            ),
            uri = "nyt://article/1"
        )

        val news = dto.toDomain()

        assertEquals("nyt://article/1", news.id)
        assertEquals("Beer story", news.title)
        assertEquals("Short snippet", news.abstractText)
        assertEquals("Lead paragraph", news.leadParagraph)
        assertEquals("The New York Times", news.source)
        assertEquals("By Test Author", news.byline)
        assertEquals("Food", news.section)
        assertEquals("Drinks", news.subsection)
        assertEquals("https://www.nytimes.com/article", news.url)
        assertEquals("2026-06-18T10:15:00Z", news.publishedDate)
        assertEquals(
            "https://www.nytimes.com/images/2026/06/beer.jpg",
            news.imageUrl
        )
    }
}
