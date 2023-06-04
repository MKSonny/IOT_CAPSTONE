import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../video_controller/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<ListResult> futureDownloadFiles;
  late Future<List<String>> futureFiles;
  late Future<String> downloadURL;
  Map<int, double> downloadProgress = {};

  @override
  void initState() {
    super.initState();
    List<String> urls = [];
    futureDownloadFiles = FirebaseStorage.instance.ref('/uploads').listAll();
    futureFiles = getFileUrls();
  }

  Future<List<String>> getFileUrls() async {
  List<String> urls = [];

  // Get a reference to the Firebase Storage instance
  FirebaseStorage storage = FirebaseStorage.instance;

  // Get a reference to the "uploads" folder
  Reference folderRef = storage.ref('/uploads');

  // List all the items (files and folders) in the folder
  ListResult result = await folderRef.listAll();

  // Loop through each item
  for (final item in result.items) {
    // Get the download URL for the file
    String url = await item.getDownloadURL();
    urls.add(url);
  }

  return urls;
}

@override
Widget build(BuildContext context) {
  return RefreshIndicator(
    onRefresh: _refresh,
    child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/login_screen0.jpeg'),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(children: [
            SizedBox(width: 4),
            Icon(Icons.connected_tv),
            SizedBox(width: 10),
            Text('감지된 영상 목록'),
          ],),
        ),
        backgroundColor: Colors.transparent, // 배경 색상 투명으로 설정
        body: FutureBuilder<List<String>>(
          future: futureFiles,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final files = snapshot.data!;
              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 2 / 1.6,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  print('file: ' + file);
                  double? progress = downloadProgress[index];
                  var downloadURL;

                  return Card(
                    color: Colors.white.withOpacity(0.8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: VideoPlayerView(
                            url: file,
                            dataSourceType: DataSourceType.network,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Error'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    ),
  );
}

  Future downloadFile(int index, Reference ref) async {
    final url = await ref.getDownloadURL();

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${ref.name}';
      await Dio().download(
        url, 
        path,
        onReceiveProgress: (received, total) {
          double progress = received / total;

          setState(() {
            downloadProgress[index] = progress;
          });
        } ,
        );

      if (url.contains('.mp4')) {
        await GallerySaver.saveVideo(path, toDcim: true);
      } else if (url.contains('.png')){
        await GallerySaver.saveImage(path, toDcim: true);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded ${ref.name}')),
      );
    }
    
      

  Future<void> _refresh() async {
    setState(() {
      futureFiles = getFileUrls();
    });
  }
}
