package com.example.videoapp.video_list

import android.net.Uri
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

data class VideoUri(val videoUri: Uri)
enum class ItemNotify {
    ADD, UPDATE, DELETE
}

class MyViewModel : ViewModel() {
    // 변화를 감지하기 위해서
    val itemsLiveData = MutableLiveData<ArrayList<VideoUri>>()

    private val items = ArrayList<VideoUri>()
    var longClickItem: Int = -1

    var itemNotified: Int = -1
    // add, update, delete 행동 구분을 위해서 사용
    var itemNotifiedType: ItemNotify = ItemNotify.ADD

    init {
        addItem(VideoUri(Uri.parse("https://firebasestorage.googleapis.com/v0/b/videotest-ffe11.appspot.com/o/uploads%2Fcctv_2023-03-09T13%3A49%3A42.mp4?alt=media&token=89fb33b2-3096-4f2b-a0fe-254bb8d01b51")))
        addItem(VideoUri(Uri.parse("https://firebasestorage.googleapis.com/v0/b/videotest-ffe11.appspot.com/o/uploads%2Fcctv_2023-03-09T13%3A49%3A42.mp4?alt=media&token=89fb33b2-3096-4f2b-a0fe-254bb8d01b51")))
        addItem(VideoUri(Uri.parse("https://firebasestorage.googleapis.com/v0/b/videotest-ffe11.appspot.com/o/uploads%2Fcctv_2023-03-09T13%3A49%3A42.mp4?alt=media&token=89fb33b2-3096-4f2b-a0fe-254bb8d01b51")))
//        addItem(VideoUri("james", "test2"))
    }

    fun getItem(pos: Int) = items[pos]

    val itemsSize get() = items.size

    fun addItem(videoUri: VideoUri) {
        itemNotifiedType = ItemNotify.ADD
        // items 의 사이즈가 새로 추가된 데이터의 위치가 된다.
        itemNotified = itemsSize

        items.add(videoUri)
        itemsLiveData.value = items
    }

    fun updateItem(videoUri: VideoUri, pos: Int) {
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