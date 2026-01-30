package com.example.projectmobileandroid.Home.ViewModel


import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

// --- Model ---
data class UserTest(val id: Long, val name: String)

// --- UI State ---
sealed interface SearchUiStateTest {
    data object Idle : SearchUiStateTest
    data class Loading(val query: String) : SearchUiStateTest
    data class Data(val query: String, val items: List<UserTest>) : SearchUiStateTest
    data class Error(val query: String, val message: String) : SearchUiStateTest
}

// --- Fake data source ---
// TODO: Реализовать simulateNetworkSearch(query): suspend fun
// Требования:
// - delay 400..900ms
// - иногда бросает исключение (например, если query содержит "!" или random)
// - возвращает список users на основе query
class FakeUsersDataSource {
    suspend fun simulateNetworkSearch(query: String): List<UserTest> {
        // TODO: implement
        delay(200)
        if (query == "!") {
            throw RuntimeException("Error")
        }
        delay(400)
        return List<UserTest>(8) { i ->
            UserTest(i.toLong(), query + i.toString())
        }
    }
}

class HomeViewModelTest(
    private val ds: FakeUsersDataSource = FakeUsersDataSource()
) : ViewModel() {

    // Ввод пользователя
    private val _query = MutableStateFlow("")
    val query: StateFlow<String> = _query.asStateFlow()

    // UI state
    private val _uiState = MutableStateFlow<SearchUiStateTest>(SearchUiStateTest.Idle)
    val uiState: StateFlow<SearchUiStateTest> = _uiState.asStateFlow()


    init {
        query
            .debounce(300)
            .distinctUntilChanged()
            .mapLatest { text ->
                if (text == "") {
                    _uiState.value = SearchUiStateTest.Idle
                } else {
                    _uiState.value = SearchUiStateTest.Loading(text)
                    try {
                        val users: List<UserTest> = withContext(Dispatchers.IO) {
                            ds.simulateNetworkSearch(text)
                        }
                        _uiState.value = SearchUiStateTest.Data(text, users)
                    } catch (error: Throwable) {
                        _uiState.value = SearchUiStateTest.Error(text, error.message ?: "idk")
                    }
                }
            }
            .launchIn(viewModelScope)

        // TODO: реализовать pipeline:
        // - слушаем query
        // - debounce(300)
        // - игнорим пустые строки (или переводим в Idle)
        // - latest wins (отмена предыдущего поиска)
        // - перед запросом ставим Loading(query)
        // - успех -> Data(query, items)
        // - ошибка -> Error(query, message)
        //
        // Подсказка: лучше сделать через:
        // query
        //   .debounce(...)
        //   .distinctUntilChanged()
        //   .flatMapLatest { ... }
        //   .onEach { ... }
        //   .launchIn(viewModelScope)
    }


    fun onQueryChanged(newQuery: String) {
        _query.value = newQuery
    }
}
