package com.example.projectmobileandroid.Home.ViewModel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.projectmobileandroid.Home.Domain.GetNewsUseCase
import com.example.projectmobileandroid.Home.Model.FallbackNews
import com.example.projectmobileandroid.Home.Model.HomeUiState
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Job
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeout

class HomeViewModel(
    private val getNewsUseCase: GetNewsUseCase
) : ViewModel() {

    private var currentQuery = "beer"

    private val _uiState = MutableStateFlow(HomeUiState(query = currentQuery))
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    private var autoRefreshJob: Job? = null
    private var loadJob: Job? = null
    private var searchJob: Job? = null

    init {
        loadNews()
    }

    fun loadNews(
        query: String = currentQuery
    ) {
        val normalizedQuery = query.trim()
        if (normalizedQuery.isEmpty()) return

        loadJob?.cancel()
        currentQuery = normalizedQuery

        loadJob = viewModelScope.launch {
            _uiState.update {
                it.copy(
                    isLoading = true,
                    errorMessage = null
                )
            }

            runCatching {
                withTimeout(20_000L) {
                    getNewsUseCase(normalizedQuery)
                }
            }.onSuccess { news ->
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        allNews = news,
                        visibleNews = news,
                        isFromCache = false,
                        errorMessage = null
                    )
                }
            }.onFailure { throwable ->
                if (throwable is CancellationException && throwable !is TimeoutCancellationException) {
                    return@launch
                }

                _uiState.update {
                    val fallbackNews = FallbackNews.items
                    it.copy(
                        isLoading = false,
                        allNews = fallbackNews,
                        visibleNews = fallbackNews,
                        isFromCache = true,
                        errorMessage = when (throwable) {
                            is TimeoutCancellationException -> "Запрос занял слишком много времени"
                            else -> throwable.message ?: "Не удалось загрузить новости"
                        }
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
                loadNews(currentQuery)
            }
        }
    }

    fun stopAutoRefresh() {
        autoRefreshJob?.cancel()
        autoRefreshJob = null
    }

    fun onQueryChange(query: String) {
        _uiState.update { it.copy(query = query) }

        searchJob?.cancel()
        if (query.isBlank()) {
            return
        }

        searchJob = viewModelScope.launch {
            delay(500)
            loadNews(query)
        }
    }

    fun retry() {
        loadNews(currentQuery)
    }

    class Factory(
        private val getNewsUseCase: GetNewsUseCase
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(HomeViewModel::class.java)) {
                return HomeViewModel(getNewsUseCase) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
    }
}
