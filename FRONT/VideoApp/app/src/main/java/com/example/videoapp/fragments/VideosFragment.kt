package com.example.videoapp.fragments

import android.Manifest
import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.annotation.RequiresApi
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.videoapp.App
import com.example.videoapp.R
import com.example.videoapp.databinding.AskLayoutBinding
import com.example.videoapp.databinding.RecyclerLayoutBinding
import com.example.videoapp.video_list.ItemNotify
import com.example.videoapp.video_list.MyAdapter
import com.example.videoapp.video_list.MyViewModel
import com.google.firebase.firestore.DocumentChange
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.storage.FirebaseStorage
import com.google.firebase.storage.ktx.storage

internal class VideosFragment : Fragment(R.layout.recycler_layout) {
    val viewModel: MyViewModel by activityViewModels()

    lateinit var storage: FirebaseStorage

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val binding = RecyclerLayoutBinding.bind(view)

        /**
         * flask 와 연동위한 FirebaseMessaging token 얻기
         */
        FirebaseMessaging.getInstance().token.addOnSuccessListener {
            Log.d(ContentValues.TAG, "FirebaseMessaging: $it")
        }

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
                    Log.d(ContentValues.TAG, "unsortedVideos.add(uri.result): ${uri.result}")
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

        // 새로운 영상 추가되면 리사이클러뷰에 알림
        val db = Firebase.firestore
        val postsCollectionRef = db.collection("refresh")
        val batch = db.batch()
        val snapshotListener = postsCollectionRef.addSnapshotListener { snapshot, e ->
            if (e != null) {
                println("Error getting posts: ${e.message}")
                return@addSnapshotListener
            }
            if (snapshot != null) {
                for (change in snapshot.documentChanges) {
                    if (change.type == DocumentChange.Type.ADDED) {
                        val addedStringVideoUri: String? = change.document["file_uri"] as? String
                        val addedMetadata: String? = change.document["metadata"] as? String
                        if (addedStringVideoUri != null) {
//                            val replaced = addedStringVideoUri.replace("storage", "firebasestorage")
                            Log.d(ContentValues.TAG, "addedStringVideoUri file_uri: $addedStringVideoUri")

                            val metadataAddedUri =
                                "$addedStringVideoUri?alt=media&token=$addedMetadata"

                            val addedVideoUri = Uri.parse(addedStringVideoUri)
                            Log.d(ContentValues.TAG, "addedVideoUri: $addedVideoUri")

                            viewModel.addItem(addedVideoUri)
                            Log.d(ContentValues.TAG, "change.document.id: ${change.document.id}")
                            postsCollectionRef.document(change.document.id).delete()

//                            Log.d(TAG, "change.document.getDocumentReference(\"file_uri\") ${change.document.getDocumentReference()}")
//                            change.document.getDocumentReference("file_uri")
                        } else {
                            // handle null value case
                        }

                    }
                }
            }
        }
        //

        // floatingActionButton 을 누를 경우 실시간 스트리밍 cctv를 볼 수 있도록 설정?
        binding.floatingActionButton.setOnClickListener {
//            viewModel.addItem(Item("new", "data"))
        }

        val adapter = MyAdapter(findNavController(), viewModel)
        // 여기다가 우리가 만든 어댑터를 지정해준다.
        binding.recyclerView.adapter = adapter
        binding.recyclerView.layoutManager = LinearLayoutManager(App.instance)
        // 각 아이템마다 높이를 똑같이 맞추겠다.
        binding.recyclerView.setHasFixedSize(true)

        viewModel.itemsLiveData.observe(viewLifecycleOwner) {
//            adapter.notifyDataSetChanged() -> 전체를 새로 고침 : 비효율적
            when (viewModel.itemNotifiedType) {
                ItemNotify.ADD -> adapter.notifyItemInserted(viewModel.itemNotified)
                ItemNotify.UPDATE -> adapter.notifyItemChanged(viewModel.itemNotified)
                ItemNotify.DELETE -> adapter.notifyItemRemoved(viewModel.itemNotified)
            }
        }
    }
}