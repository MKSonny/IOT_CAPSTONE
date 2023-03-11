package com.example.videoapp

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.ContextMenu
import android.view.MenuItem
import android.view.View
import androidx.activity.viewModels
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.videoapp.databinding.ActivityMainBinding
import com.example.videoapp.video_list.ItemNotify
import com.example.videoapp.video_list.MyAdapter
import com.example.videoapp.video_list.MyViewModel

class MainActivity : AppCompatActivity() {
    private val viewModel: MyViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.floatingActionButton.setOnClickListener {
//            viewModel.addItem(Item("new", "data"))
        }

        val adapter = MyAdapter(viewModel)
        // 여기다가 우리가 만든 어댑터를 지정해준다.
        binding.recyclerView.adapter = adapter
        binding.recyclerView.layoutManager = LinearLayoutManager(this)
        // 각 아이템마다 높이를 똑같이 맞추겠다.
        binding.recyclerView.setHasFixedSize(true)

        viewModel.itemsLiveData.observe(this) {
//            adapter.notifyDataSetChanged() -> 전체를 새로 고침 : 비효율적
            when (viewModel.itemNotifiedType) {
                ItemNotify.ADD -> adapter.notifyItemInserted(viewModel.itemNotified)
                ItemNotify.UPDATE -> adapter.notifyItemChanged(viewModel.itemNotified)
                ItemNotify.DELETE -> adapter.notifyItemRemoved(viewModel.itemNotified)
            }
        }

        registerForContextMenu(binding.recyclerView)
    }
}