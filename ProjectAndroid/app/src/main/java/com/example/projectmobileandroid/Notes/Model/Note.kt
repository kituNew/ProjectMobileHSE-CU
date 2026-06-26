package com.example.projectmobileandroid.Notes.Model

import kotlinx.serialization.Serializable

@Serializable
data class Note(
    val id: Long,
    val title: String,
    val text: String,
    val updatedAt: Long
)