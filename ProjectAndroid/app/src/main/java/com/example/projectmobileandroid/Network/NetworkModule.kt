package com.example.projectmobileandroid.Network

import android.content.Context
import android.util.Log
import kotlinx.serialization.json.Json
import okhttp3.Cache
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import java.io.File
import okhttp3.MediaType.Companion.toMediaType
import java.util.concurrent.TimeUnit
import com.example.projectmobileandroid.BuildConfig

object NetworkModule {

    private lateinit var appContext: Context

    val apiKey: String
        get() = BuildConfig.NYT_API_KEY.ifBlank {
            "gAyEnGAME1VzDKDEVj4HHrm8W51m0QmXIaJDIn9JCLXzcm4u"
        }

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
            .connectTimeout(10, TimeUnit.SECONDS)
            .readTimeout(15, TimeUnit.SECONDS)
            .writeTimeout(15, TimeUnit.SECONDS)
            .callTimeout(20, TimeUnit.SECONDS)
            .dns(PublicIpv4Dns)
            .cache(
                Cache(
                    directory = File(appContext.cacheDir, "http_cache"),
                    maxSize = 20L * 1024 * 1024
                )
            )
            .addInterceptor { chain ->
                val request = chain.request()

                Log.d(TAG, "Sending request: ${request.method} ${request.url}")

                try {
                    val response = chain.proceed(request)
                    Log.d(
                        TAG,
                        "Response: code=${response.code}, cache=${response.cacheResponse != null}, network=${response.networkResponse != null}, url=${response.request.url}"
                    )
                    response
                } catch (throwable: Throwable) {
                    Log.e(TAG, "Request failed: ${request.method} ${request.url}", throwable)
                    throw throwable
                }
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

    private const val TAG = "NYT_NETWORK"
}
