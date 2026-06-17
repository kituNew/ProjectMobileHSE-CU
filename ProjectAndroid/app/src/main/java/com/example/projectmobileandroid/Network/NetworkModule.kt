package com.example.projectmobileandroid.Network

import android.content.Context
import kotlinx.serialization.json.Json
import okhttp3.Cache
import okhttp3.CacheControl
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import java.io.File
import okhttp3.MediaType.Companion.toMediaType
import java.util.concurrent.TimeUnit

object NetworkModule {

    private lateinit var appContext: Context

    public var apiKey = "gAyEnGAME1VzDKDEVj4HHrm8W51m0QmXIaJDIn9JCLXzcm4u"

    fun init(context: Context) {
        appContext = context.applicationContext
    }

    private val json by lazy {
        Json {
            ignoreUnknownKeys = true
            isLenient = true
        }
    }

    private val okHttpClient by lazy {
        OkHttpClient.Builder()
            .cache(
                Cache(
                    directory = File(appContext.cacheDir, "http_cache"),
                    maxSize = 20L * 1024 * 1024
                )
            )
            .addInterceptor { chain ->
                var request = chain.request()

                if (!appContext.isOnline()) {
                    request = request.newBuilder()
                        .cacheControl(
                            CacheControl.Builder()
                                .onlyIfCached()
                                .maxStale(7, TimeUnit.DAYS)
                                .build()
                        )
                        .build()
                }

                chain.proceed(request)
            }
            .addNetworkInterceptor { chain ->
                val response = chain.proceed(chain.request())
                response.newBuilder()
                    .removeHeader("Pragma")
                    .header("Cache-Control", "public, max-age=120")
                    .build()
            }
            .build()
    }

    private val retrofit by lazy {
        Retrofit.Builder()
            .baseUrl("https://api.nytimes.com/")
            .client(okHttpClient)
            .addConverterFactory(
                json.asConverterFactory("application/json".toMediaType())
            )
            .build()
    }

    fun <T> createService(serviceClass: Class<T>): T {
        return retrofit.create(serviceClass)
    }
}
