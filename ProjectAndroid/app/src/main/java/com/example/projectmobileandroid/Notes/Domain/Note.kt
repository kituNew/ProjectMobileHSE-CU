package com.example.projectmobileandroid.Notes.Domain

data class Note(
    val id: Long,
    val title: String,
    val text: String,
    val updatedAt: Long
)
