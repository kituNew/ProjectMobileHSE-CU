package com.example.projectmobileandroid.Network

import android.content.Context
import coil.ImageLoader
import coil.disk.DiskCache

object ImageLoaderProvider {

    @Volatile
    private var imageLoader: ImageLoader? = null

    fun get(context: Context): ImageLoader {
        val appContext = context.applicationContext

        return imageLoader ?: synchronized(this) {
            imageLoader ?: ImageLoader.Builder(appContext)
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