package com.example.projectmobileandroid.Home.Model

object FallbackNews {
    val items = listOf(
        News(
            id = "fallback-beer-1",
            title = "Статьи NYT временно недоступны",
            abstractText = "Проверьте подключение к интернету и попробуйте обновить список.",
            byline = "",
            section = "Офлайн",
            subsection = "",
            url = "https://www.nytimes.com/search?query=beer",
            publishedDate = "",
            imageUrl = null
        )
    )
}
