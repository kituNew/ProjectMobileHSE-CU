package com.example.projectmobileandroid.Network.Servises

import com.example.projectmobileandroid.Home.Model.NewsResponseDTO
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

interface NewsApiService {

    @GET("svc/news/v3/content/{source}/{section}.json")
    suspend fun getNews(
        @Path("source") source: String,
        @Path("section") section: String,
        @Query("api-key") apiKey: String
    ): NewsResponseDTO
}