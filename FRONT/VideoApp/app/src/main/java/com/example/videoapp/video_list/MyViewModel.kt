package com.example.videoapp.video_list

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

data class Item(val name: String, val name2: String)
enum class ItemNotify {
    ADD, UPDATE, DELETE
}

class MyViewModel : ViewModel() {
    // 변화를 감지하기 위해서
    val itemsLiveData = MutableLiveData<ArrayList<Item>>()

    private val items = ArrayList<Item>()
    var longClickItem: Int = -1

    var itemNotified: Int = -1
    // add, update, delete 행동 구분을 위해서 사용
    var itemNotifiedType: ItemNotify = ItemNotify.ADD

    init {
        addItem(Item("john", "test"))
        addItem(Item("james", "test2"))
    }

    fun getItem(pos: Int) = items[pos]

    val itemsSize get() = items.size

    fun addItem(item: Item) {
        itemNotifiedType = ItemNotify.ADD
        // items 의 사이즈가 새로 추가된 데이터의 위치가 된다.
        itemNotified = itemsSize

        items.add(item)
        itemsLiveData.value = items
    }

    fun updateItem(item: Item, pos: Int) {
        itemNotifiedType = ItemNotify.UPDATE
        itemNotified = pos

        items[pos] = item
        itemsLiveData.value = items
    }

    fun deleteItem(pos: Int) {
        itemNotifiedType = ItemNotify.DELETE
        itemNotified = pos

        items.removeAt(pos)
        itemsLiveData.value = items
    }
}