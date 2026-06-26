package com.example.projectmobileandroid.Favorites.View

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.example.projectmobileandroid.Home.Model.News
import com.example.projectmobileandroid.Home.View.NewsCard
import com.example.projectmobileandroid.Network.ImageLoaderProvider

@Composable
fun FavoritesView(
    favorites: List<News>,
    onOpenArticle: (News) -> Unit,
    onToggleFavorite: (News) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val imageLoader = remember(context) { ImageLoaderProvider.get(context) }

    if (favorites.isEmpty()) {
        Box(
            modifier = modifier
                .fillMaxSize()
                .padding(24.dp),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "Избранных новостей пока нет",
                style = MaterialTheme.typography.titleMedium
            )
        }
        return
    }

    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        items(
            items = favorites,
            key = { it.id }
        ) { article ->
            NewsCard(
                article = article,
                imageLoader = imageLoader,
                isFavorite = true,
                onFavoriteClick = { onToggleFavorite(article) },
                onClick = { onOpenArticle(article) }
            )
        }
    }
}
