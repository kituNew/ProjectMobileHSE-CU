package com.example.projectmobileandroid.Network

import android.content.Context
import coil.ImageLoader
import coil.disk.DiskCache
import okhttp3.OkHttpClient
import java.util.concurrent.TimeUnit

object ImageLoaderProvider {

    @Volatile
    private var imageLoader: ImageLoader? = null

    fun get(context: Context): ImageLoader {
        val appContext = context.applicationContext

        return imageLoader ?: synchronized(this) {
            imageLoader ?: ImageLoader.Builder(appContext)
                .okHttpClient {
                    OkHttpClient.Builder()
                        .dns(PublicIpv4Dns)
                        .connectTimeout(8, TimeUnit.SECONDS)
                        .readTimeout(15, TimeUnit.SECONDS)
                        .writeTimeout(15, TimeUnit.SECONDS)
                        .callTimeout(20, TimeUnit.SECONDS)
                        .build()
                }
                .diskCache {
                    DiskCache.Builder()
                        .directory(appContext.cacheDir.resolve("image_cache"))
                        .maxSizePercent(0.02)
                        .build()
                }
                .crossfade(true)
                .build()
                .also { imageLoader = it }
        }
    }
}
