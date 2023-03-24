
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({
    super.key,
    required this.url,
    required this.dataSourceType
    });

    final String url;
    final DataSourceType dataSourceType;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    switch (widget.dataSourceType) {
      case DataSourceType.asset:
      _videoPlayerController = VideoPlayerController.asset(widget.url);
      break;
      case DataSourceType.network:
      _videoPlayerController = VideoPlayerController.network(widget.url);
      break;
      case DataSourceType.file:
      _videoPlayerController = VideoPlayerController.file(File(widget.url));
      break;
      case DataSourceType.contentUri:
      _videoPlayerController = VideoPlayerController.contentUri(Uri.parse(widget.url));
      break;
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16/ 9,
      autoInitialize: true,
      );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    print('&&&&&&&&&&&&&&&&&&' + widget.url);

    String dateTimeString = widget.url.split('_')[1].replaceAll('%3A', ':').replaceAll('%2D', '-');
    dateTimeString = dateTimeString.split('&token=')[0];
    // 시간 정보와 토큰 정보 분리
    String timeString = dateTimeString.split('fb')[0];
    // 토큰 정보 제거
    String dateTimeWithoutToken = timeString.replaceAll('.mp4?alt=media', '');
    // DateTime 객체로 변환
    DateTime dateTime = DateTime.parse(dateTimeWithoutToken);

    // 원하는 형식으로 문자열 생성
    String formattedDateTime = DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(dateTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10,),
        const Divider(),
        Text(
          // widget.dataSourceType.name.toUpperCase(),
          // widget.url,
          formattedDateTime,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10,),
        const Divider(),
        AspectRatio(
          aspectRatio: 16/9,
          child: Chewie(controller: _chewieController),
          )
      ],
    );
  }
}

