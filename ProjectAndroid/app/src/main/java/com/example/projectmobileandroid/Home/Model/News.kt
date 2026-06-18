package com.example.projectmobileandroid.Home.Model

import kotlinx.serialization.Serializable

@Serializable
data class News(
    val id: String,
    val title: String,
    val abstractText: String,
    val byline: String,
    val section: String,
    val subsection: String,
    val url: String?,
    val publishedDate: String,
    val imageUrl: String?,
    val snippet: String = "",
    val leadParagraph: String = "",
    val source: String = ""
)

fun NewsItemDTO.toDomain(): News {
    val preferredImageUrl = multimedia?.defaultImage?.url
        ?: multimedia?.thumbnail?.url

    return News(
        id = id ?: uri ?: webUrl ?: headline?.main ?: "${pubDate}_${hashCode()}",
        title = headline?.main.orEmpty(),
        abstractText = abstract ?: snippet.orEmpty(),
        byline = byline?.original.orEmpty(),
        section = sectionName.orEmpty(),
        subsection = subsectionName.orEmpty(),
        url = webUrl,
        publishedDate = pubDate.orEmpty(),
        imageUrl = preferredImageUrl?.toNytImageUrl(),
        snippet = snippet.orEmpty(),
        leadParagraph = leadParagraph.orEmpty(),
        source = source.orEmpty()
    )
}

private fun String.toNytImageUrl(): String {
    return if (startsWith("http://") || startsWith("https://")) {
        this
    } else {
        "https://www.nytimes.com/$this"
    }
}
