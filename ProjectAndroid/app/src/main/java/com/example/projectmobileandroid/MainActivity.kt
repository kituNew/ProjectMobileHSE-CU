package com.example.projectmobileandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.List
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.adaptive.navigationsuite.NavigationSuiteScaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.PreviewScreenSizes
import com.example.projectmobileandroid.DI.AppContainer
import com.example.projectmobileandroid.Favorites.View.FavoritesView
import com.example.projectmobileandroid.Home.Model.News
import com.example.projectmobileandroid.Home.View.HomeView
import com.example.projectmobileandroid.Home.View.NewsDetailView
import com.example.projectmobileandroid.Notes.View.NotesView
import com.example.projectmobileandroid.Reminder.View.ReminderView
import com.example.projectmobileandroid.ui.theme.ProjectMobileAndroidTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AppContainer.init(this)
        enableEdgeToEdge()
        setContent {
            ProjectMobileAndroidTheme {
                ProjectMobileAndroidApp()
            }
        }
    }
}

@PreviewScreenSizes
@Composable
fun ProjectMobileAndroidApp() {
    val context = LocalContext.current
    AppContainer.init(context)

    var currentDestination by rememberSaveable { mutableStateOf(AppDestinations.HOME) }
    var selectedArticle by remember { mutableStateOf<News?>(null) }
    val favoriteNews by AppContainer.observeFavoriteNewsUseCase()
        .collectAsState()
    val favoriteIds = favoriteNews.map { it.id }.toSet()

    selectedArticle?.let { article ->
        NewsDetailView(
            article = article,
            isFavorite = favoriteIds.contains(article.id),
            onToggleFavorite = {
                AppContainer.toggleFavoriteNewsUseCase(article)
            },
            modifier = Modifier.fillMaxSize(),
            onClose = {
                selectedArticle = null
            }
        )
        return
    }

    NavigationSuiteScaffold(
        navigationSuiteItems = {
            AppDestinations.entries.forEach {
                item(
                    icon = {
                        Icon(
                            it.icon,
                            contentDescription = it.label
                        )
                    },
                    label = { Text(it.label) },
                    selected = it == currentDestination,
                    onClick = { currentDestination = it }
                )
            }
        }
    ) {
        Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
            when (currentDestination) {
                AppDestinations.HOME ->
                    HomeView(
                        modifier = Modifier.padding(innerPadding),
                        favoriteIds = favoriteIds,
                        onToggleFavorite = AppContainer.toggleFavoriteNewsUseCase::invoke,
                        onOpenArticle = { article ->
                            selectedArticle = article
                        }
                    )
                AppDestinations.Favorites ->
                    FavoritesView(
                        favorites = favoriteNews,
                        modifier = Modifier.padding(innerPadding),
                        onOpenArticle = { article ->
                            selectedArticle = article
                        },
                        onToggleFavorite = AppContainer.toggleFavoriteNewsUseCase::invoke
                    )
                AppDestinations.Reminder ->
                    ReminderView(modifier = Modifier.padding(innerPadding))
                AppDestinations.Notes ->
                    NotesView(modifier = Modifier.padding(innerPadding))
            }
        }
    }
}

enum class AppDestinations(
    val label: String,
    val icon: ImageVector,
) {
    HOME("Главная", Icons.Default.Home),
    Favorites("Избранное", Icons.Default.Star),
    Reminder("Задачи", Icons.Default.CheckCircle),
    Notes("Записи", Icons.AutoMirrored.Filled.List)
}
