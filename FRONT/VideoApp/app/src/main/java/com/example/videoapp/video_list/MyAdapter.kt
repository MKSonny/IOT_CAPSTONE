package com.example.videoapp.video_list

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.videoapp.databinding.ItemLayoutBinding

// 데이터를 넘겨주는 가장 좋은 방법은 MyAdapter 를 만들 때 데이터를 넘겨주는 것이다.
// 여기서는 뷰모델을 사용한다.
class MyAdapter(private val viewModel: MyViewModel) : RecyclerView.Adapter<MyAdapter.ViewHolder>() {
    /**
     * MyAdapter가 해줘야 되는 일은 이 ViewHolder 를 만들어주는 것과
     * ViewHolder에 데이터를 넣어주는 것, 현재 가지고 있는 아이템의 총 개수를 리턴해줘야 된다.
     */
    inner class ViewHolder(private val binding : ItemLayoutBinding) : RecyclerView.ViewHolder(binding.root) {
        fun setContents(pos : Int) {
            val item = viewModel.getItem(pos)
            binding.textView.text = item.name
            binding.textView2.text = item.name2
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val binding = ItemLayoutBinding.inflate(layoutInflater, parent, false)
        // 그냥 아래 처럼 하면 ViewHolder 와 binding 이 아무런 관계가 없다.
//        val viewHolder = ViewHolder()
        val viewHolder = ViewHolder(binding)

        // long click 시
        binding.root.setOnLongClickListener {
            // 현재 롱클릭 당한 아이템의 위치를 알 수 있다.
            viewModel.longClickItem = viewHolder.adapterPosition
            false
        }

        return viewHolder
    }

    // position 에 해당되는 데이터를 ViewHolder 에다가 집어 넣는다.
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.setContents(position)
    }

    override fun getItemCount() = viewModel.itemsSize
}