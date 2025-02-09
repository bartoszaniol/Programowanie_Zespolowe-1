import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/details_post_screen.dart';

class Post extends StatefulWidget {
  final String id;
  final String url;
  final String tresc;
  final Timestamp data;
  final String user;
  final String urlUser;
  int ocena;
  List<dynamic> like;
  List<dynamic> dislike;
  List<dynamic> komentarze;
  bool darkmode;

  Post({
    this.id,
    this.tresc,
    this.url,
    this.data,
    this.urlUser,
    this.user,
    this.ocena,
    this.like,
    this.dislike,
    this.komentarze,
    this.darkmode,
  });

  @override
  _PostState createState() => _PostState();
}

FirebaseAuth auth = FirebaseAuth.instance;
CollectionReference posts = FirebaseFirestore.instance.collection('posts');

class _PostState extends State<Post> {
  Future<void> updateOcenyLike(int zmienna) async {
    switch (zmienna) {
      case 1: // Nic --> lubisz
        widget.like.add(auth.currentUser.email);
        break;
      case 2: // Nie lubisz --> lubisz
        widget.dislike.removeWhere((email) => email == auth.currentUser.email);
        widget.like.add(auth.currentUser.email);

        await posts.doc(widget.id).update({'dislike': widget.dislike});
        break;
      case -1: // lubisz na nic
        widget.like.removeWhere((email) => email == auth.currentUser.email);
        break;
    }
    await posts.doc(widget.id).update({'like': widget.like});
    await posts.doc(widget.id).update({'ocena': widget.ocena + zmienna});
  }

  Future<void> updateOcenyDislike(int zmienna) async {
    switch (zmienna) {
      case -1: // Nic --> nie lubisz
        widget.dislike.add(auth.currentUser.email);

        break;
      case 1: // nie lubisz na nic
        widget.dislike.removeWhere((email) => email == auth.currentUser.email);

        break;
      case -2: // lubisz na nie lubisz
        widget.like.removeWhere((email) => email == auth.currentUser.email);
        widget.dislike.add(auth.currentUser.email);
        print("KURWA ${widget.dislike}");
        await posts.doc(widget.id).update({'like': widget.like});
        break;
    }
    await posts.doc(widget.id).update({'dislike': widget.dislike});
    await posts.doc(widget.id).update({'ocena': widget.ocena + zmienna});
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.komentarze);
    var czas = widget.data.toDate();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(czas);
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Center(
        child: Card(
          color: widget.darkmode ? Colors.blueGrey[900] : Colors.white,
          // elevation: 20,
          child: Column(
            children: [
              ListTile(
                title: Text(
                  widget.user,
                  style: TextStyle(
                      color: widget.darkmode ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  formattedDate,
                  style: TextStyle(
                      color: widget.darkmode ? Colors.white70 : Colors.black87),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Image.network(widget.url,
                    width: 150, height: 150, fit: BoxFit.fill),
              ),
              ListTile(
                title: Text(
                  widget.tresc,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 15,
                      color: widget.darkmode ? Colors.white : Colors.black87),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
              ),
              Container(
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.message),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPostScreen(
                            id: widget.id,
                            data: widget.data,
                            ocena: widget.ocena,
                            tresc: widget.tresc,
                            url: widget.url,
                            user: widget.user,
                            komentarze: widget.komentarze,
                            darkmode: widget.darkmode,
                            like: widget.like,
                            dislike: widget.dislike,
                            upvote: updateOcenyLike,
                            downvote: updateOcenyDislike,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () async {
                        int zmienna;
                        if (widget.dislike.contains(auth.currentUser.email)) {
                          zmienna = 1; // z nie lubisz na nic
                        } else if (widget.like
                            .contains(auth.currentUser.email)) {
                          zmienna = -2; // z lubisz na nie lubisz
                        } else if ((widget.like
                                    .contains(auth.currentUser.email)) ==
                                false &&
                            (widget.dislike.contains(auth.currentUser.email)) ==
                                false) {
                          zmienna = -1; // z nic na lubisz
                        }
                        await updateOcenyDislike(zmienna);
                        // print("Like ${widget.like}");
                        // print("Disike ${widget.dislike}");
                        // widget.ocena -= 1;
                      },
                    ),
                    IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () async {
                          // print(widget.id);
                          int zmienna;
                          if (widget.like.contains(auth.currentUser.email)) {
                            zmienna = -1; // z lubisz na nic
                          } else if (widget.dislike
                              .contains(auth.currentUser.email)) {
                            zmienna = 2; // z nie lubisz na lubisz
                          } else if ((widget.like
                                      .contains(auth.currentUser.email)) ==
                                  false &&
                              (widget.dislike
                                      .contains(auth.currentUser.email)) ==
                                  false) {
                            zmienna = 1; // z nic na lubisz
                          }
                          await updateOcenyLike(zmienna);
                          print("Like ${widget.like}");
                          print("Disike ${widget.dislike}");

                          // widget.ocena++;
                        }),
                    Text(widget.ocena.toString()),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
