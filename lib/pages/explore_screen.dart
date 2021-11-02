import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wally_app/pages/loading.dart';
import 'package:wally_app/pages/wallpaper_view_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 20.0),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(top: 5.0, left: 13.0, bottom: 20.0),
              child: Text(
                'Explore',
                textAlign: TextAlign.start,
                style: GoogleFonts.getFont(
                  'Merriweather',
                  fontSize: 40.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  letterSpacing: 2.5,
                ),
              ),
            ),
            StreamBuilder(
              stream: _firebaseFirestore
                  .collection('wallpapers')
                  .orderBy(
                    'date',
                    descending: true,
                  )
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return StaggeredGridView.countBuilder(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
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
                                data: snapshot.data!.docs[index] as dynamic,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: snapshot.data!.docs[index]['url'] as dynamic,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              placeholder: (ctx, url) => Image(
                                image:
                                    AssetImage('assets/images/placeholder.jpg'),
                              ),
                              imageUrl:
                                  snapshot.data!.docs[index]['url'] as dynamic,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return Loading();
              },
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
