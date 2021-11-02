import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_wallpaper_screen.dart';
import 'loading.dart';
import 'wallpaper_view_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  User? _user;

  @override
  void initState() {
    // TODO: implement initState
    fetchUserData();
    super.initState();
  }

  void fetchUserData() async {
    User? firebaseUser = await _firebaseAuth.currentUser;
    setState(() {
      _user = firebaseUser;
    });
    print('Current User: ${firebaseUser!.uid}');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: _user != null
            ? Column(
                children: [
                  SizedBox(height: 20.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: FadeInImage(
                      width: 200.0,
                      height: 200.0,
                      image: NetworkImage('${_user!.photoURL}'),
                      placeholder: AssetImage('assets/images/placeholder.jpg'),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text('${_user!.displayName}'),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    onPressed: () async {
                      _firebaseAuth.signOut();
                    },
                    child: Text('Logout'),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    margin: EdgeInsets.only(left: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Wallpapers',
                          style: GoogleFonts.getFont(
                            'Merriweather',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddWallpaperScreen(),
                                fullscreenDialog: true,
                              ),
                            );
                          },
                          icon: Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: _firebaseFirestore
                        .collection('wallpapers')
                        .where('uploaded_by', isEqualTo: _user!.uid)
                        .snapshots(),
                    builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.isNotEmpty) {
                          return StaggeredGridView.countBuilder(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            staggeredTileBuilder: (int index) =>
                                StaggeredTile.fit(1),
                            itemCount: snapshot.data!.docs.length,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            itemBuilder: (ctx, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => WallpaperViewScreen(
                                        data: snapshot.data!.docs[index]
                                            as dynamic,
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Hero(
                                      tag: snapshot.data!.docs[index]['url']
                                          as dynamic,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: CachedNetworkImage(
                                          placeholder: (ctx, url) => Image(
                                            image: AssetImage(
                                                'assets/images/placeholder.jpg'),
                                          ),
                                          imageUrl: snapshot.data!.docs[index]
                                              ['url'] as dynamic,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        showDialog<void>(
                                          context: context,
                                          builder:
                                              (BuildContext dialogContext) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              title: Text('Delete Wallpaper'),
                                              titleTextStyle:
                                                  GoogleFonts.getFont(
                                                'Merriweather',
                                                fontSize: 20.0,
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              content: Text(
                                                  'Do you want to delete this wallpaper?'),
                                              contentTextStyle:
                                                  GoogleFonts.getFont(
                                                'Merriweather',
                                                fontWeight: FontWeight.w500,
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                    'Okay',
                                                    style: GoogleFonts.getFont(
                                                      'Merriweather',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(dialogContext)
                                                        .pop();
                                                    _firebaseFirestore
                                                        .collection(
                                                            'wallpapers')
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .delete();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(
                                                    'No',
                                                    style: GoogleFonts.getFont(
                                                      'Merriweather',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(dialogContext)
                                                        .pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.delete_forever_rounded,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          return Text(
                            'Upload Wallpaper to see here',
                            style: GoogleFonts.getFont(
                              'Merriweather',
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        }
                      }
                      return Loading();
                    },
                  ),
                  SizedBox(height: 20.0),
                ],
              )
            : LinearProgressIndicator(),
      ),
    );
  }
}
