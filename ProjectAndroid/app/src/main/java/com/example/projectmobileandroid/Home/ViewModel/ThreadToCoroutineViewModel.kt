package com.example.projectmobileandroid.Home.ViewModel

import android.os.Handler
import android.os.Looper
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlin.coroutines.cancellation.CancellationException

// --- UI state ---
sealed interface CalcUiState {
    data object Idle : CalcUiState
    data class Running(val progress: Int) : CalcUiState // 0..100
    data class Done(val result: Long) : CalcUiState
    data object Canceled : CalcUiState
    data class Error(val message: String) : CalcUiState
}

class ThreadToCoroutineViewModel : ViewModel() {

    private val _state = MutableStateFlow<CalcUiState>(CalcUiState.Idle)
    val state: StateFlow<CalcUiState> = _state.asStateFlow()

    // ПЛОХО: ручное управление thread/cancel
    private var workerThread: Thread? = null

    private var job: Job? = null

    // TODO: переписать на корутин

    fun start() {
        job?.cancel()
        _state.value = CalcUiState.Running(progress = 0)

        job = viewModelScope.launch {
            withContext(Dispatchers.Default) {
                try {
                    var acc = 0L
                    val total = 300_000_000 // "тяжёлая" работа

                    for (i in 1..total) {
                        if (i % 500_000 == 0) {
                            coroutineContext.ensureActive() // или ensureActive()
                        }

                        // имитация тяжёлой CPU-работы
                        acc += (i % 97)

                        // иногда обновляем прогресс
                        if (i % 3_000_000 == 0) {
                            val p = ((i.toDouble() / total) * 100).toInt()
                            withContext(Dispatchers.Main) { _state.value = CalcUiState.Running(p) }
                        }
                    }

                    withContext(Dispatchers.Main) { _state.value = CalcUiState.Done(acc) }
                } catch (ce: CancellationException) {
                    withContext(Dispatchers.Main) { _state.value = CalcUiState.Canceled }
                    return@withContext
                } catch (t: Throwable) {
                    withContext(Dispatchers.Main) { _state.value = CalcUiState.Error(t.message ?: "unknown") }
                }
            }
        }
    }

    fun cancel() {
        job?.cancel()
        _state.value = CalcUiState.Canceled
    }
}
