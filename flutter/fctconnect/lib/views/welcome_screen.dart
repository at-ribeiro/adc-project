import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:go_router/go_router.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_login_ui/constants.dart';
import 'package:responsive_login_ui/models/NewsData.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Themes/theme_manager.dart';
import '../models/paths.dart';
import '../services/base_client.dart';
import '../widgets/error_dialog.dart';
import '../widgets/theme_switch.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoadingNews = true;

  late List<NewsData> _news;

  int currentNewsIndex = 0;

  final LatLng _initialPosition = LatLng(38.661003, -9.204440);

  Future<List<NewsData>> _loadNews() async {
    setState(() {
      _news = [];
    });
    List<NewsData> news = await BaseClient().fetchNewsFCT(0);

    return news;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ThemeManager themeManager = context.watch<ThemeManager>();
    var screenSize = MediaQuery.of(context).size;

    if (_isLoadingNews) {
      return FutureBuilder(
          future: _loadNews(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return ErrorDialog('Algo não correu bem!', 'Voltar', context);
              } else {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  setState(() {
                    _news = snapshot.data;
                    _isLoadingNews = false;
                  });
                });
                return Container();
              }
            } else {
              return Container(
                  child: const Center(child: CircularProgressIndicator()));
            }
          });
    } else {
      return Container(
        child: Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              // SliverAppBar
              SliverAppBar(
                floating: false,
                pinned: true,
                snap: false,
                expandedHeight: 500.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    'assets/welcome.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                // Set the background color of the SliverAppBar
                title: Text(
                  'Bem vindo à FCTConnect',
                  style: textTheme.headline6!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: Container(
                  width: 30.0,
                  height: 30.0,
                  margin: EdgeInsets.all(8.0),
                  child: Image.asset(
                    'icon-nbg.png',
                    fit: BoxFit.contain,
                  ),
                ),
                actions: [
                  Row(
                    children: [
                      ThemeSwitch(themeManager: themeManager),
                      SizedBox(width: 16.0),
                      Container(
                        width: 80.0,
                        height: 40.0,
                        child: ElevatedButton(
                          onPressed: () {
                            context.go(Paths.signUp);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(18.0),
                              ),
                            ), // Set the desired radius value

                            primary: Theme.of(context).indicatorColor,
                          ),
                          child: Text(
                            'Registar',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 80.0,
                        height: 40.0,
                        child: ElevatedButton(
                          onPressed: () {
                            context.go(Paths.login);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(18.0),
                              ),
                            ),
                          ),
                          child: Text(
                            'Entrar',
                            style: TextStyle(
                              color: Style.kAccentColor0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16.0),
                ],
              ),
              // Rest of the content
              SliverList(
                  delegate: SliverChildListDelegate(
                [
                  Column(
                    children: [
                      SizedBox(height: 40.0),
                      GestureDetector(
                        onTap: () {
                          _launchInstagramURL('https://www.fct.unl.pt/' +
                              _news[currentNewsIndex].newsUrl);
                        },
                        child: Container(
                          height: screenSize.height * 0.4,
                          child: Stack(
                            children: [
                              PageView.builder(
                                itemCount: _news.length,
                                controller: PageController(
                                    initialPage: currentNewsIndex),
                                onPageChanged: (index) {
                                  setState(() {
                                    currentNewsIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final newsItem = _news[currentNewsIndex];
                                  return Container(
                                    width:
                                        MediaQuery.of(context).size.width - 20,
                                    color: Style.kPrimaryColor.withOpacity(0.5),
                                    child: Stack(
                                      children: [
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            return Row(
                                              children: [
                                                ClipRRect(
                                                  child: AspectRatio(
                                                    aspectRatio: 16 / 9,
                                                    child: Image.network(
                                                      newsItem.imageUrl,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10.0),
                                                if (constraints.maxWidth >
                                                    600) // Set the breakpoint
                                                  Flexible(
                                                    // Use Flexible instead of Expanded to avoid forcing the widgets to take up all available space
                                                    child: Column(
                                                      children: [
                                                        SizedBox(height: 10.0),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                            newsItem.text,
                                                            style: TextStyle(
                                                              fontSize: 24.0,
                                                              color: Style
                                                                  .kAccentColor0,
                                                            ),
                                                            maxLines:
                                                                null, // Remove the limitation of 2 lines
                                                            overflow: TextOverflow
                                                                .visible, // Set overflow to visible
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 8.0),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.7),
                                                  Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.1),
                                                ],
                                              ),
                                            ),
                                            child: Text(newsItem.title,
                                                style: textTheme.headline6!
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                left: 16.0,
                                top: screenSize.height * 0.4 / 2 -
                                    20.0, // Adjust the position of the buttons
                                child: IconButton(
                                  onPressed: () {
                                    if (currentNewsIndex > 0) {
                                      setState(() {
                                        currentNewsIndex--;
                                      });
                                    } else if (currentNewsIndex == 0) {
                                      setState(() {
                                        currentNewsIndex = _news.length - 1;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.arrow_back),
                                  color: Theme.of(context).iconTheme.color,
                                  iconSize: 40.0,
                                ),
                              ),
                              Positioned(
                                right: 16.0,
                                top: screenSize.height * 0.4 / 2 -
                                    20.0, // Adjust the position of the buttons
                                child: IconButton(
                                  onPressed: () {
                                    if (currentNewsIndex < _news.length - 1) {
                                      setState(() {
                                        currentNewsIndex++;
                                      });
                                    } else if (currentNewsIndex ==
                                        _news.length - 1) {
                                      setState(() {
                                        currentNewsIndex = 0;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.arrow_forward),
                                  color: Theme.of(context).iconTheme.color,
                                  iconSize: 40.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 20.0,
                        child: Center(
                          child: Text(
                            '${currentNewsIndex + 1} / ${_news.length}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 50.0),
                      Container(
                        height: screenSize.height *
                            0.4, // Set height for the map container
                        width: 800.0, // Set width for the map container
                        child: ClipRRect(
                          borderRadius: Style.kBorderRadius,
                          child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _initialPosition,
                                zoom: 16.0,
                              ),
                              zoomGesturesEnabled: false,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              markers: {
                                Marker(
                                  markerId: MarkerId('fct'),
                                  position: _initialPosition,
                                  infoWindow: InfoWindow(
                                    title: 'FCT',
                                    snippet:
                                        'Faculdade de Ciências e Tecnologia',
                                  ),
                                ),
                              }),
                        ),
                      ),
                      Container(
                        color: const Color.fromARGB(71, 0, 0, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          _launchInstagramURL(
                                              'https://www.instagram.com/estudasses.fct/');
                                        },
                                        child: Icon(FontAwesomeIcons.instagram,
                                            color: Style.kAccentColor0,
                                            size: 50.0)),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 30.0),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              )),
            ],
          ),
        ),
      );
    }
  }

  void _launchInstagramURL(String url) async {
    Uri instagramURL = Uri.parse(url);
    if (await canLaunchUrl(instagramURL)) {
      await launchUrl(instagramURL);
    } else {
      throw 'Could not launch $instagramURL';
    }
  }
}
