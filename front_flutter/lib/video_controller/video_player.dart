import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:front_flutter/page/message_page.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({
    Key? key,
    required this.url,
    required this.dataSourceType,
  }) : super(key: key);

  final String url;
  final DataSourceType dataSourceType;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool isLooked = true;

  @override
  void initState() {
    super.initState();
    checkLookedStatus();
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
        _videoPlayerController =
            VideoPlayerController.contentUri(Uri.parse(widget.url));
        break;
    }
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
      autoInitialize: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  Future<void> checkLookedStatus() async {
    final docRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.url.split('&token=')[1]);

    docRef.snapshots().listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        final fieldValue = data?['looked'] as bool?;

        setState(() {
          isLooked = fieldValue ?? true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String dateTimeString = widget.url
        .split('_')[1]
        .replaceAll('%3A', ':')
        .replaceAll('%2D', '-');
    dateTimeString = dateTimeString.split('&token=')[0];

    String timeString = dateTimeString.split('fb')[0];
    String dateTimeWithoutToken =
        timeString.replaceAll('.mp4?alt=media', '');
    DateTime dateTime = DateTime.parse(dateTimeWithoutToken);

    String token = widget.url.split('&token=')[1];

    String formattedDateTime =
        DateFormat('yyyy년 MM월 dd일 \nHH시 mm분').format(dateTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  DateFormat('yyyy년 MM월 dd일').format(dateTime),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('HH시 mm분').format(dateTime),
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            Container(
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return MessagePage(
                      token,
                      formattedDateTime,
                    );
                  }),
                ),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeInBack,
                  switchOutCurve: Curves.easeOutBack,
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: animation,
                      child: child,
                    );
                  },
                  child: isLooked
                      ? const Icon(
                          Icons.chat_bubble,
                          color: Colors.black,
                        )
                      : const Icon(
                          Icons.mark_chat_unread_rounded,
                          color: Colors.blue,
                        ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => showDownloadConfirmationDialog(widget.url, formattedDateTime),
              icon: const Icon(
                Icons.download,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Chewie(controller: _chewieController),
        )
      ],
    );
  }

  Future<void> showDownloadConfirmationDialog(String downloadURL, String formattedDateTime) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고'),
          content: SingleChildScrollView(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: '법적 경고: 이 영상은 저작권과 관련된 법적 보호를 받고 있으며, 무단 배포 시 법적 처벌을 받을 수 있습니다. 이 경고 문구를 통해 저작권 침해에 대한 심각성을 인식하시기 바랍니다.\n\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '본 영상은 저작권자에게 소유권이 있으며, 무단 배포, 복제, 수정, 재배포 등은 저작권 침해로 간주됩니다. 이를 포함하여 저작권 침해를 한다면 법적 제재를 받을 수 있으며, 이는 심각한 결과를 초래할 수 있습니다.\n\n',
                ),
                TextSpan(
                  text: '반드시 저작권법을 준수하고, 저작권자의 명시적인 동의를 얻은 후에만 영상을 사용하십시오. 어떤 목적이든 영상을 무단으로 사용하거나 배포하는 것은 적법하지 않으며, 이는 저작권자와의 계약 또는 법적 조항에 따라 처벌을 받을 수 있습니다.\n\n',
                ),
                TextSpan(
                  text: '저작권 침해로 인한 소송, 손해 배상 청구, 벌금, 형사 처벌 등의 결과를 피하기 위해서는 저작권자의 사전 동의를 받아야 합니다. 저작권 보호를 존중하고, 법적 규정을 준수하는 것은 개인 및 기업의 책임입니다.\n\n',
                ),
                TextSpan(
                  text: '어떠한 경우에도 저작권에 대한 경시, 침해, 비밀스럽게 사용하는 등의 행위는 잘못된 것입니다. 저작권자의 권리를 존중하고 법적 제재로부터 자신을 보호하기 위해 저작권법을 엄격히 준수하시기 바랍니다.\n\n',
                ),
                TextSpan(
                  text: '위의 내용은 법적 조언을 대체하지 않으며, 법적 문제가 있을 경우에는 전문적인 법률 자문을 받아야 합니다.',
                ),
              ],
            ),
          ),
        ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                downloadFile(downloadURL, formattedDateTime);
              },
              child: const Text('동의 - 다운로드'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  Future<void> downloadFile(String downloadURL, String formattedDateTime) async {
    final url = downloadURL;

    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/$formattedDateTime.mp4';
    await Dio().download(
      url,
      path,
      onReceiveProgress: (received, total) {
        double progress = received / total;
      },
    );

    if (url.contains('.mp4')) {
      await GallerySaver.saveVideo(path, toDcim: true);
    } else if (url.contains('.png')) {
      await GallerySaver.saveImage(path, toDcim: true);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloaded $formattedDateTime')),
    );
  }
}
