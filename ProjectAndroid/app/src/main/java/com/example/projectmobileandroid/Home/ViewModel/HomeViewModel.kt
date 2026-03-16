package com.example.projectmobileandroid.Home.ViewModel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.projectmobileandroid.Home.Model.HomeUiState
import com.example.projectmobileandroid.Home.Model.News
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.util.Locale

class HomeViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = NewsRepository(application.applicationContext)

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    private var currentSource = "nyt"
    private var currentSection = "business"

    private var autoRefreshJob: Job? = null
    private var loadJob: Job? = null

    init {
        loadNews()
    }

    fun loadNews(
        source: String = currentSource,
        section: String = currentSection
    ) {
        if (loadJob?.isActive == true) return

        currentSource = source
        currentSection = section

        loadJob = viewModelScope.launch {
            _uiState.update {
                it.copy(
                    isLoading = true,
                    errorMessage = null
                )
            }

            runCatching {
                repository.getNews(source, section)
            }.onSuccess { news ->
                val filtered = filterNews(_uiState.value.query, news)

                _uiState.update {
                    it.copy(
                        isLoading = false,
                        allNews = news,
                        visibleNews = filtered,
                        errorMessage = null
                    )
                }
            }.onFailure { throwable ->
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        errorMessage = throwable.message ?: "Не удалось загрузить новости"
                    )
                }
            }
        }
    }

    fun startAutoRefresh() {
        if (autoRefreshJob?.isActive == true) return

        autoRefreshJob = viewModelScope.launch {
            while (isActive) {
                delay(2 * 60 * 1000L)
                loadNews(currentSource, currentSection)
            }
        }
    }

    fun stopAutoRefresh() {
        autoRefreshJob?.cancel()
        autoRefreshJob = null
    }

    fun onQueryChange(query: String) {
        _uiState.update { current ->
            current.copy(
                query = query,
                visibleNews = filterNews(query, current.allNews)
            )
        }
    }

    fun retry() {
        loadNews(currentSource, currentSection)
    }

    private fun filterNews(
        query: String,
        items: List<News>
    ): List<News> {
        if (query.isBlank()) return items

        val normalizedQuery = query.trim().lowercase(Locale.getDefault())

        return items.filter { article ->
            article.title.lowercase(Locale.getDefault()).contains(normalizedQuery) ||
                    article.abstractText.lowercase(Locale.getDefault()).contains(normalizedQuery) ||
                    article.byline.lowercase(Locale.getDefault()).contains(normalizedQuery) ||
                    article.section.lowercase(Locale.getDefault()).contains(normalizedQuery) ||
                    article.subsection.lowercase(Locale.getDefault()).contains(normalizedQuery)
        }
    }
}