package com.example.projectmobileandroid.Home.Model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class NewsResponseDTO(
    val status: String = "",
    val copyright: String = "",
    @SerialName("num_results")
    val numResults: Int = 0,
    val results: List<NewsItemDTO> = emptyList()
)

@Serializable
data class NewsItemDTO(
    @SerialName("slug_name")
    val slugName: String? = null,
    val section: String? = null,
    val subsection: String? = null,
    val title: String? = null,
    val abstract: String? = null,
    val uri: String? = null,
    val url: String? = null,
    val byline: String? = null,
    @SerialName("item_type")
    val itemType: String? = null,
    val source: String? = null,
    @SerialName("updated_date")
    val updatedDate: String? = null,
    @SerialName("created_date")
    val createdDate: String? = null,
    @SerialName("published_date")
    val publishedDate: String? = null,
    @SerialName("first_published_date")
    val firstPublishedDate: String? = null,
    @SerialName("material_type_facet")
    val materialTypeFacet: String? = null,
    val kicker: String? = null,
    val subheadline: String? = null,
    @SerialName("des_facet")
    val desFacet: List<String> = emptyList(),
    @SerialName("org_facet")
    val orgFacet: List<String> = emptyList(),
    @SerialName("per_facet")
    val perFacet: List<String> = emptyList(),
    @SerialName("geo_facet")
    val geoFacet: List<String> = emptyList(),
    @SerialName("related_urls")
    val relatedUrls: List<RelatedUrlDTO> = emptyList(),
    val multimedia: List<MultimediaDTO> = emptyList()
)

@Serializable
data class RelatedUrlDTO(
    @SerialName("suggested_link_text")
    val suggestedLinkText: String? = null,
    val url: String? = null
)

@Serializable
data class MultimediaDTO(
    val url: String? = null,
    val format: String? = null,
    val height: Int? = null,
    val width: Int? = null,
    val type: String? = null,
    val subtype: String? = null,
    val caption: String? = null,
    val copyright: String? = null
)