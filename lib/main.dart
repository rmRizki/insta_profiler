import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_insta/flutter_insta.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  FlutterInsta flutterInsta = FlutterInsta();
  TextEditingController usernameController = TextEditingController();
  TextEditingController reelController = TextEditingController();
  TabController tabController;

  String username, followers, following, bio, website, profileImage;
  bool pressed = false;
  bool downloading = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, initialIndex: 1, length: 2);
    _initializeDownloader();
    _downloadReels();
  }

  _initializeDownloader() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(debug: true);
  }

  _downloadReels() async {
    var s = await flutterInsta
        .downloadReels("https://www.instagram.com/p/CDlGkdZgB2y");
    print(s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Instagram Profiler'),
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(
              text: "Home",
            ),
            Tab(
              text: "Reels",
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [_buildHomePage(), _buildReelPage()],
      ),
    );
  }

  Future _fetchUserDetails(String username) async {
    await flutterInsta.getProfileData(username);
    setState(() {
      this.username = flutterInsta.username;
      this.followers = flutterInsta.followers;
      this.following = flutterInsta.following;
      this.website = flutterInsta.website;
      this.bio = flutterInsta.bio;
      this.profileImage = flutterInsta.imgurl;
    });
  }

  Widget _buildHomePage() {
    return Center(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(contentPadding: EdgeInsets.all(10)),
            controller: usernameController,
          ),
          ElevatedButton(
            child: Text("Print Details"),
            onPressed: () async {
              setState(() => pressed = true);

              _fetchUserDetails(usernameController.text);
            },
          ),
          pressed
              ? SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Card(
                      child: Container(
                        margin: EdgeInsets.all(15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network("$profileImage", width: 120),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                            ),
                            Text(
                              "$username",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "$followers\nFollowers",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "$following\nFollowing",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                            ),
                            Text(
                              "$bio",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 10)),
                            Text(
                              "$website",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildReelPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextField(
          controller: reelController,
        ),
        ElevatedButton(
          onPressed: () {
            setState(() => downloading = true);
            _download();
          },
          child: Text("Download"),
        ),
        downloading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container()
      ],
    );
  }

  _download() async {
    var myVideoUrl = await flutterInsta.downloadReels(reelController.text);
    await FlutterDownloader.enqueue(
      url: '$myVideoUrl',
      savedDir: '/sdcard/Download',
      showNotification: true,
      openFileFromNotification: true,
    ).whenComplete(() => setState(() => downloading = false));
  }
}
