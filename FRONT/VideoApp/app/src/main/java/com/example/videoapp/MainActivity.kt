package com.example.videoapp

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.ContextMenu
import android.view.MenuItem
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AlertDialog
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.videoapp.databinding.ActivityMainBinding
import com.example.videoapp.video_list.ItemNotify
import com.example.videoapp.video_list.MyAdapter
import com.example.videoapp.video_list.MyViewModel
import com.google.firebase.ktx.Firebase
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.storage.FirebaseStorage
import com.google.firebase.storage.ktx.storage
import java.time.LocalDateTime

class MainActivity : AppCompatActivity() {
    private val viewModel: MyViewModel by viewModels()
    lateinit var storage: FirebaseStorage

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        /**
         * flask 와 연동위한 FirebaseMessaging token 얻기
         */
        FirebaseMessaging.getInstance().token.addOnSuccessListener {
            Log.d(ContentValues.TAG, "FirebaseMessaging: $it")
        }

        // 알림을 얻기 위한 권한 물어보기
        requestSinglePermission(Manifest.permission.POST_NOTIFICATIONS)


        // 파이어베이스 스토리지 연동 설정 =============================
        storage = Firebase.storage
        val uploads = storage.getReference("uploads/")

        val unsortedVideos = ArrayList<Uri>()

        uploads.listAll().addOnSuccessListener { listResult ->
            val totalItems = listResult.items.size
            var count = 0
            for (item in listResult.items) {
                item.downloadUrl.addOnCompleteListener { uri ->
                    unsortedVideos.add(uri.result)
                    count++
                    if (count == totalItems) {
                        // All items have been added to the list
                        // Do something with the videos ArrayList
                        viewModel.sortVideos(unsortedVideos)
                    }
                }
            }
        }.addOnFailureListener {exception ->
            Log.d(ContentValues.TAG, "오류 발생 원인: $exception")
        }
        //  ==========================================================

        // floatingActionButton 을 누를 경우 실시간 스트리밍 cctv를 볼 수 있도록 설정?
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

//        registerForContextMenu(binding.recyclerView)
    }

    private fun requestSinglePermission(permission: String) {
        if (checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED)
            return

        val requestPermLauncher = registerForActivityResult(ActivityResultContracts.RequestPermission()) {
            if (it == false) { // permission is not granted!
                AlertDialog.Builder(this).apply {
                    setTitle("Warning")
//                        setMessage(getString(R.string.no_permission, permission))
                }.show()
            }
        }

        if (shouldShowRequestPermissionRationale(permission)) {
            // you should explain the reason why this app needs the permission.
            AlertDialog.Builder(this).apply {
                setTitle("Reason")
//                    setMessage(getString(R.string.req_permission_reason, permission))
                setPositiveButton("Allow") { _, _ -> requestPermLauncher.launch(permission) }
                setNegativeButton("Deny") { _, _ -> }
            }.show()
        } else {
            // should be called in onCreate()
            requestPermLauncher.launch(permission)
        }
    }
}