package com.example.videoapp.fragments

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.example.videoapp.R
import com.example.videoapp.databinding.AskLayoutBinding
import com.example.videoapp.video_list.MyViewModel

class AskFragment : Fragment(R.layout.ask_layout) {
    private val viewModel : MyViewModel by activityViewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val binding = AskLayoutBinding.bind(view)
    }
}