import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class WallpaperViewScreen extends StatefulWidget {
  final DocumentSnapshot data;
  const WallpaperViewScreen({Key? key, required this.data}) : super(key: key);

  @override
  _WallpaperViewScreenState createState() => _WallpaperViewScreenState();
}

class _WallpaperViewScreenState extends State<WallpaperViewScreen> {
  void launchUrl() async {
    try {
      await launch(
        widget.data['url'],
        customTabsOption: CustomTabsOption(
          toolbarColor: Colors.redAccent.shade100,
        ),
      );
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    List tags = widget.data['tags'].toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Hero(
                  tag: widget.data['url'],
                  child: CachedNetworkImage(
                    placeholder: (ctx, url) => Image(
                      image: AssetImage("assets/images/placeholder.jpg"),
                    ),
                    imageUrl: widget.data['url'],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: Wrap(
                  runSpacing: 10.0,
                  spacing: 10.0,
                  children: tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                    );
                  }).toList(),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: Wrap(
                  runSpacing: 10.0,
                  spacing: 10.0,
                  children: [
                    RaisedButton.icon(
                      onPressed: launchUrl,
                      icon: Icon(Icons.file_download_rounded),
                      label: Text('Get wallpaper'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
