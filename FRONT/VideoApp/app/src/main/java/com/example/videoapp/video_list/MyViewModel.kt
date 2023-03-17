package com.example.videoapp.video_list

import android.content.ContentValues.TAG
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import java.time.LocalDateTime

//data class VideoUri(val videoUri: Uri)
enum class ItemNotify {
    ADD, UPDATE, DELETE
}

class MyViewModel : ViewModel() {
    // 변화를 감지하기 위해서
    val itemsLiveData = MutableLiveData<ArrayList<Uri>>()

    private val items = ArrayList<Uri>()
    var longClickItem: Int = -1

    var itemNotified: Int = -1
    // add, update, delete 행동 구분을 위해서 사용
    var itemNotifiedType: ItemNotify = ItemNotify.ADD

    @RequiresApi(Build.VERSION_CODES.O)
    fun sortVideos(unsortedVideos : List<Uri>) {
        val sortedVideos = unsortedVideos.sortedBy { uri ->
            val fileName = uri.lastPathSegment ?: ""
            val timeString = fileName.substringAfterLast("v_").substringBefore(".mp4")
            val formattedTimeString = timeString.replace("_", ":")
            LocalDateTime.parse(formattedTimeString)
        }
        for (uri in sortedVideos) {
            addItem(uri)
        }
    }

    fun getItem(pos: Int) = items[pos]

    val itemsSize get() = items.size

    fun addItem(videoUri: Uri) {
        if (!items.contains(videoUri)) {
            Log.d(TAG, "addItem: added")
            itemNotified = 0
            for (item in items) {
                Log.d(TAG, "addItem dafafsdfadf: $item")
            }
            Log.d(TAG, "dfadfadfadfadfafasdf: ${items.size}")
            items.add(0, videoUri)
            itemsLiveData.value = items
            itemNotifiedType = ItemNotify.ADD
        }
    }

    fun updateItem(videoUri: Uri, pos: Int) {
        itemNotifiedType = ItemNotify.UPDATE
        itemNotified = pos

        items[pos] = videoUri
        itemsLiveData.value = items
    }

    fun deleteItem(pos: Int) {
        itemNotifiedType = ItemNotify.DELETE
        itemNotified = pos

        items.removeAt(pos)
        itemsLiveData.value = items
    }
}