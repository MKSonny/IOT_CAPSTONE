package com.example.videoapp.fragments

import android.content.ContentValues.TAG
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.example.videoapp.R
import com.example.videoapp.databinding.AskLayoutBinding
import com.example.videoapp.video_list.MyViewModel
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase

class AskFragment : Fragment(R.layout.ask_layout) {
    private val viewModel : MyViewModel by activityViewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val binding = AskLayoutBinding.bind(view)

        val db = Firebase.firestore
        val asksCollectionRef = db.collection("Ask")

        binding.button.setOnClickListener {
            val title = binding.askTitle.text.toString()
            val context = binding.askText.text.toString()

            val askData = hashMapOf(
                "title" to title,
                "context" to context
            )

            asksCollectionRef.add(askData).addOnSuccessListener { documentReference ->
                val documentId = documentReference.id
                Log.d(TAG, "Document added with ID: $documentId")
            }

            findNavController().navigate(R.id.action_askFragment_to_videosFragment)
        }
    }
}