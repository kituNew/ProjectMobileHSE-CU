package com.example.projectmobileandroid.Support

import android.content.Context
import android.content.ContextWrapper
import android.content.SharedPreferences
import java.io.File
import java.nio.file.Files

class InMemoryContext : ContextWrapper(null) {
    private val preferences = mutableMapOf<String, InMemorySharedPreferences>()
    private val cacheDirectory = Files.createTempDirectory("project-mobile-test-cache").toFile()

    override fun getApplicationContext(): Context = this

    override fun getCacheDir(): File = cacheDirectory

    override fun getSharedPreferences(
        name: String?,
        mode: Int
    ): SharedPreferences {
        return preferences.getOrPut(name.orEmpty()) {
            InMemorySharedPreferences()
        }
    }
}

private class InMemorySharedPreferences : SharedPreferences {
    private val values = linkedMapOf<String, Any?>()
    private val listeners = mutableSetOf<SharedPreferences.OnSharedPreferenceChangeListener>()

    override fun getAll(): Map<String, *> = values.toMap()

    override fun getString(key: String?, defValue: String?): String? {
        return values[key] as? String ?: defValue
    }

    @Suppress("UNCHECKED_CAST")
    override fun getStringSet(
        key: String?,
        defValues: MutableSet<String>?
    ): MutableSet<String>? {
        return (values[key] as? Set<String>)?.toMutableSet() ?: defValues
    }

    override fun getInt(key: String?, defValue: Int): Int {
        return values[key] as? Int ?: defValue
    }

    override fun getLong(key: String?, defValue: Long): Long {
        return values[key] as? Long ?: defValue
    }

    override fun getFloat(key: String?, defValue: Float): Float {
        return values[key] as? Float ?: defValue
    }

    override fun getBoolean(key: String?, defValue: Boolean): Boolean {
        return values[key] as? Boolean ?: defValue
    }

    override fun contains(key: String?): Boolean {
        return values.containsKey(key)
    }

    override fun edit(): SharedPreferences.Editor {
        return Editor()
    }

    override fun registerOnSharedPreferenceChangeListener(
        listener: SharedPreferences.OnSharedPreferenceChangeListener?
    ) {
        listener?.let(listeners::add)
    }

    override fun unregisterOnSharedPreferenceChangeListener(
        listener: SharedPreferences.OnSharedPreferenceChangeListener?
    ) {
        listener?.let(listeners::remove)
    }

    private inner class Editor : SharedPreferences.Editor {
        private val updates = linkedMapOf<String, Any?>()
        private val removals = mutableSetOf<String>()
        private var shouldClear = false

        override fun putString(key: String?, value: String?): SharedPreferences.Editor {
            return putValue(key, value)
        }

        override fun putStringSet(
            key: String?,
            values: MutableSet<String>?
        ): SharedPreferences.Editor {
            return putValue(key, values?.toSet())
        }

        override fun putInt(key: String?, value: Int): SharedPreferences.Editor {
            return putValue(key, value)
        }

        override fun putLong(key: String?, value: Long): SharedPreferences.Editor {
            return putValue(key, value)
        }

        override fun putFloat(key: String?, value: Float): SharedPreferences.Editor {
            return putValue(key, value)
        }

        override fun putBoolean(key: String?, value: Boolean): SharedPreferences.Editor {
            return putValue(key, value)
        }

        override fun remove(key: String?): SharedPreferences.Editor {
            key?.let {
                removals.add(it)
                updates.remove(it)
            }
            return this
        }

        override fun clear(): SharedPreferences.Editor {
            shouldClear = true
            updates.clear()
            removals.clear()
            return this
        }

        override fun commit(): Boolean {
            applyChanges()
            return true
        }

        override fun apply() {
            applyChanges()
        }

        private fun putValue(
            key: String?,
            value: Any?
        ): SharedPreferences.Editor {
            key?.let {
                updates[it] = value
                removals.remove(it)
            }
            return this
        }

        private fun applyChanges() {
            val changedKeys = linkedSetOf<String>()

            if (shouldClear) {
                changedKeys.addAll(values.keys)
                values.clear()
            }

            removals.forEach { key ->
                if (values.remove(key) != null) {
                    changedKeys.add(key)
                }
            }

            updates.forEach { (key, value) ->
                values[key] = value
                changedKeys.add(key)
            }

            changedKeys.forEach { key ->
                listeners.forEach { listener ->
                    listener.onSharedPreferenceChanged(this@InMemorySharedPreferences, key)
                }
            }
        }
    }
}
