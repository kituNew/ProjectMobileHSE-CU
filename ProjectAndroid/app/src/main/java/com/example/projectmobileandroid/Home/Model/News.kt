package com.example.projectmobileandroid.Home.Model

data class News(
    val id: String,
    val title: String,
    val abstractText: String,
    val byline: String,
    val section: String,
    val subsection: String,
    val url: String?,
    val publishedDate: String,
    val imageUrl: String?
)

fun NewsItemDTO.toDomain(): News {
    val preferredImageUrl =
        multimedia.firstOrNull {
            !it.url.isNullOrBlank() &&
                    (it.format?.contains("threeByTwo", ignoreCase = true) == true ||
                            it.format?.contains("Large", ignoreCase = true) == true)
        }?.url
            ?: multimedia.firstOrNull { !it.url.isNullOrBlank() }?.url

    return News(
        id = uri ?: url ?: slugName ?: title ?: "${publishedDate}_${hashCode()}",
        title = title.orEmpty(),
        abstractText = abstract.orEmpty(),
        byline = byline.orEmpty(),
        section = section.orEmpty(),
        subsection = subsection.orEmpty(),
        url = url,
        publishedDate = publishedDate.orEmpty(),
        imageUrl = preferredImageUrl
    )
}