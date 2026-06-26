package com.example.projectmobileandroid.Network.Servises

import com.example.projectmobileandroid.Home.Model.NewsResponseDTO
import retrofit2.http.GET
import retrofit2.http.Query

interface NewsApiService {

    @GET("svc/search/v2/articlesearch.json")
    suspend fun getNews(
        @Query("q") query: String,
        @Query("api-key") apiKey: String
    ): NewsResponseDTO
}
