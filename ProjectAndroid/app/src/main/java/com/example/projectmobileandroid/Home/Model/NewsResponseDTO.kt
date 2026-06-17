package com.example.projectmobileandroid.Home.Model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class NewsResponseDTO(
    val status: String = "",
    val copyright: String = "",
    val response: NewsSearchResponseDTO = NewsSearchResponseDTO()
)

@Serializable
data class NewsSearchResponseDTO(
    val docs: List<NewsItemDTO> = emptyList(),
    val metadata: NewsMetadataDTO = NewsMetadataDTO()
)

@Serializable
data class NewsMetadataDTO(
    val hits: Int = 0,
    val offset: Int = 0,
    val time: Int = 0
)

@Serializable
data class NewsItemDTO(
    @SerialName("_id")
    val id: String? = null,
    val abstract: String? = null,
    val snippet: String? = null,
    @SerialName("web_url")
    val webUrl: String? = null,
    val source: String? = null,
    @SerialName("pub_date")
    val pubDate: String? = null,
    @SerialName("section_name")
    val sectionName: String? = null,
    @SerialName("subsection_name")
    val subsectionName: String? = null,
    val headline: HeadlineDTO? = null,
    val byline: BylineDTO? = null,
    val multimedia: MultimediaDTO? = null,
    val uri: String? = null
)

@Serializable
data class HeadlineDTO(
    val main: String? = null,
    val kicker: String? = null,
    @SerialName("print_headline")
    val printHeadline: String? = null
)

@Serializable
data class BylineDTO(
    val original: String? = null
)

@Serializable
data class MultimediaDTO(
    val caption: String? = null,
    val credit: String? = null,
    @SerialName("default")
    val defaultImage: MultimediaImageDTO? = null,
    val thumbnail: MultimediaImageDTO? = null
)

@Serializable
data class MultimediaImageDTO(
    val url: String? = null,
    val height: Int? = null,
    val width: Int? = null
)
