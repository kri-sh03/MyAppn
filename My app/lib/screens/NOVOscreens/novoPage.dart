// // ignore_for_file: prefer_const_constructors, use_build_context_synchronously, file_names

// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, file_names

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novo/API/APICall.dart';
import 'package:novo/Provider/change_index.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/model/novoModels/dashboardmodel.dart';
import 'package:novo/screens/IPOscreens/Ipopage.dart';
import 'package:novo/screens/NGBscreens/NcbTabPage.dart';
import 'package:novo/screens/SGBscreens/sgbpage.dart';
import 'package:novo/screens/notification.dart';
import 'package:novo/utils/colors.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/NOVO Widgets/LoadingALertBox.dart';
import '../../widgets/NOVO Widgets/customLoadingAni.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionALertBox.dart';
import '../../widgets/NOVO Widgets/snackbar.dart';
import 'novoDashboard.dart';

class NovoPage extends StatefulWidget {
  const NovoPage({super.key});
  @override
  State<NovoPage> createState() => _NovoPageState();
}

final changeindex = ChangeIndex();

class _NovoPageState extends State<NovoPage> {
  String clientId = '';
  String clientName = '';
  bool isDialogShown = false;
  bool drawerisOpen = false;
  bool endDrawerisOpen = false;
  DateTime goBackApp = DateTime.now();
  double screenHeight = 0;
  List<Widget>? pagePropagation;
  // List<Widget> pagePropagation = [
  //   NovoHome(dashboardDetails: novoDashBoardDataList),
  //   Ipopage(),
  //   Sgbpage(),
  //   NcbTabPage(),
  // ];
  NovoDashBoardDetails? novoDashBoardData;
  List<SegmentArr> novoDashBoardDataList = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getClientDetails();
    getDashBoardData();

    Provider.of<NavigationProvider>(context, listen: false).themeModel();
    setState(() {});
  }

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  getDashBoardData() async {
    print('ID');
    print(await analytics.getSessionId());
    novoDashBoardData = await fetchNovoDashBoardDetails(context: context);

    if (novoDashBoardData != null && novoDashBoardData!.segmentArr != null) {
      novoDashBoardDataList = novoDashBoardData!.segmentArr!
          .where(
              (e) => e.status!.toUpperCase() == 'Y' && getPage(e.path) != null)
          .toList();
    } else {
      novoDashBoardDataList = [];
    }
    pagePropagation = [
      NovoHome(dashboardDetails: novoDashBoardDataList),
      // Ipopage(),
      // Sgbpage(),
      // NcbTabPage(),
      ...novoDashBoardDataList
          .map((e) => getPage(e.path))
          .where((element) => element != null)
    ];

    setState(() {});

    isLoading = false;
  }

  getPage(value) {
    switch (value) {
      case "/ipo":
        return Ipopage();
      case "/sgb":
        return Sgbpage();
      case "/gsec":
        return NcbTabPage();
      default:
        return null;
    }
  }

  getClientDetails() async {
    try {
      if (await isInternetConnected()) {
        clientId = await validateToken(context);
        SharedPreferences sref = await SharedPreferences.getInstance();
        sref.setString("clientId", clientId);
        clientName = await getClientName(context);
      } else {
        noInternetConnectAlertDialog(context, () => getClientDetails());
      }
      setState(() {});
    } catch (e) {
      showSnackbar(context, somethingError, Colors.red);
    }
    return null;
  }

  closeLogoutLoadingAlertBox() async {
    if (!await logout(context)) {
      // await FirebaseMessaging.instance.unsubscribeFromTopic(clientId);
      Navigator.of(context).pop();
    }
  }

  willPopScopeFunc() async {
    if (drawerisOpen) {
      Navigator.of(context).pop();
      return false;
    }
    if (endDrawerisOpen) {
      Navigator.of(context).pop();
      return false;
    }

    if (isDialogShown) {
      return true; // Allow the back button to exit
    }
    if (DateTime.now().isBefore(goBackApp)) {
      SystemNavigator.pop();
      return true;
    }

    if (changeindex.value != 0) {
      changeindex.value = 0;
      return false;
    }

    goBackApp = DateTime.now().add(Duration(seconds: 2));
    appExit(context);

    return false;
  }

  @override
  Widget build(BuildContext context) {
    var dartThemeMode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    getVersion(context, snapshot) {
      if (snapshot.hasData) {
        return Text(
          'Version: ${snapshot.data!.version}',
          style: TextStyle(
              color: themeBasedColor,
              fontSize: subTitleFontSize,
              fontFamily: 'inter'),
        );
      } else {
        return Text(
            'Version'); // You can display a loading indicator here if needed.
      }
    }

    return WillPopScope(
        onWillPop: () => willPopScopeFunc(),
        child: ValueListenableBuilder(
          valueListenable: changeindex,
          builder: (context, value, child) {
            var darkThemeMode =
                Provider.of<NavigationProvider>(context).themeMode ==
                    ThemeMode.dark;
            return Scaffold(
              onDrawerChanged: (isOpened) => drawerisOpen = isOpened,
              onEndDrawerChanged: (isOpened) => endDrawerisOpen = isOpened,
              drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.10,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarDividerColor: Colors.transparent,
                    statusBarIconBrightness:
                        darkThemeMode ? Brightness.light : Brightness.dark),
                elevation: 0,
                title: GestureDetector(
                  onTap: () {
                    changeindex.value = 0;
                  },
                  child: Image.asset(
                    Provider.of<NavigationProvider>(context).themeMode ==
                            ThemeMode.dark
                        ? 'assets/novoLogoBlack.png'
                        : 'assets/Novo Transp.png',
                    width: 100.0,
                    height: 100.0,
                  ),
                ),
                centerTitle: true,
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                        icon: Icon(
                          CupertinoIcons.line_horizontal_3,
                          color: themeBasedColor,
                          size: 25,
                        ), // Use the menu icon for the drawer
                        onPressed: () {
                          Scaffold.of(context).openDrawer(); // Open the drawer
                        },
                        color: themeBasedColor);
                  },
                ),
                actions: [
                  Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                          icon: Icon(
                            Icons.notifications,
                            color: themeBasedColor,
                            size: 25,
                          ), // Use the menu icon for the drawer
                          onPressed: () {
                            Scaffold.of(context)
                                .openEndDrawer(); // Open the drawer
                          },
                          color: themeBasedColor);
                    },
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
              bottomNavigationBar: changeindex.value == 0 ||
                      isLoading ||
                      novoDashBoardDataList.isEmpty
                  ? SizedBox()
                  : CurvedNavigationBar(
                      height: 60,
                      backgroundColor: Colors.transparent,
                      color: appPrimeColor,
                      animationDuration: Duration(milliseconds: 500),
                      index:
                          changeindex.value - 1 < 0 ? 0 : changeindex.value - 1,
                      onTap: (newValue) {
                        changeindex.value = newValue + 1;
                        ChangeNCBIndex().changeNCBIndex(0);
                      },
                      items: <Widget>[
                          ...novoDashBoardDataList.map(
                            (e) => Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // dartThemeMode
                                  //     ?
                                  Image.network(e.darkThemeImage!,
                                      width: e.path == '/ipo'
                                          ? 27
                                          : e.path == '/sgb'
                                              ? 34
                                              : e.path == '/gsec'
                                                  ? 30
                                                  : 30, errorBuilder:
                                          (context, error, stackTrace) {
                                    return e.path == '/ipo'
                                        ? Image.asset(
                                            'assets/IPO WNovo Icon.png',
                                            width: 27,
                                          )
                                        : e.path == '/sgb'
                                            ? Image.asset(
                                                'assets/SGB WNovo Icon.png',
                                                width: 34,
                                              )
                                            : e.path == '/gsec'
                                                ? Image.asset(
                                                    'assets/NCB W.png',
                                                    width: 30,
                                                  )
                                                : SizedBox();
                                    // SizedBox();
                                  }
                                      // SizedBox(),
                                      ),
                                  // : Image.network(
                                  //     e.image!,
                                  //     width: 30,
                                  //     errorBuilder:
                                  //         (context, error, stackTrace) =>
                                  //             SizedBox(),
                                  //   ),
                                  SizedBox(
                                    height: 3.0,
                                  ),
                                  Text(
                                    e.name!,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontFamily: 'Kiro'),
                                  )
                                ],
                              ),
                            ),
                          )
                        ]),
              drawer: Drawer(
                child: Column(
                  children: <Widget>[
                    DrawerHeader(
                        decoration: BoxDecoration(
                            color: Provider.of<NavigationProvider>(context)
                                        .themeMode ==
                                    ThemeMode.dark
                                ? titleTextColorLight
                                : appPrimeColor),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: Provider.of<NavigationProvider>(
                                                      context)
                                                  .themeMode ==
                                              ThemeMode.dark
                                          ? appPrimeColor
                                          : Color.fromRGBO(187, 222, 251, 1),
                                      borderRadius:
                                          BorderRadius.circular(50.0)),
                                  child: FittedBox(
                                    child: Text(
                                      clientName,
                                      style: TextStyle(
                                          color:
                                              Provider.of<NavigationProvider>(
                                                              context)
                                                          .themeMode ==
                                                      ThemeMode.dark
                                                  ? Color.fromRGBO(
                                                      187, 222, 251, 1)
                                                  : appPrimeColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Kiro'),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Provider.of<NavigationProvider>(context,
                                            listen: false)
                                        .toggleTheme(context);
                                  },
                                  icon: Provider.of<NavigationProvider>(context)
                                              .themeMode ==
                                          ThemeMode.dark
                                      ? Icon(
                                          CupertinoIcons.moon_stars_fill,
                                          color: Colors.white,
                                          size: 25.0,
                                        )
                                      : Icon(
                                          CupertinoIcons.brightness_solid,
                                          color: Colors.white,
                                          size: 25.0,
                                        ),
                                )
                              ],
                            ),
                            Text(
                              clientId.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Kiro'),
                            ),
                          ],
                        )),
                    ListTile(
                      dense: true,
                      leading: Image.asset(
                        "assets/layout.png",
                        width: 20.0,
                        color: Provider.of<NavigationProvider>(context)
                                    .themeMode ==
                                ThemeMode.dark
                            ? titleTextColorDark
                            : titleTextColorLight,
                      ),
                      title: Text(
                        "NOVO",
                        style: TextStyle(
                            fontFamily: 'Kiro',
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: changeindex.value == 0
                                ? Provider.of<NavigationProvider>(context)
                                            .themeMode ==
                                        ThemeMode.dark
                                    ? Colors.blue.shade400
                                    : appPrimeColor
                                : Provider.of<NavigationProvider>(context)
                                            .themeMode ==
                                        ThemeMode.dark
                                    ? titleTextColorDark
                                    : titleTextColorLight),
                      ),
                      onTap: () {
                        changeindex.value = 0;

                        Navigator.pop(context);
                      },
                    ),
                    ...novoDashBoardDataList.map(
                      (e) => ListTile(
                        dense: true,
                        leading: Provider.of<NavigationProvider>(context)
                                    .themeMode ==
                                ThemeMode.dark
                            ? Image.network(
                                "${e.darkThemeImage}",
                                width: 20.0,
                              )
                            : Image.network(
                                "${e.image}",
                                width: 20.0,
                              ),
                        title: Text(
                          '${e.name}',
                          style: TextStyle(
                              fontFamily: 'Kiro',
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: changeindex.value ==
                                      novoDashBoardDataList.indexOf(e) + 1
                                  ? Provider.of<NavigationProvider>(context)
                                              .themeMode ==
                                          ThemeMode.dark
                                      ? Colors.blue.shade400
                                      : appPrimeColor
                                  : Provider.of<NavigationProvider>(context)
                                              .themeMode ==
                                          ThemeMode.dark
                                      ? titleTextColorDark
                                      : titleTextColorLight),
                        ),
                        onTap: () {
                          changeindex.value =
                              novoDashBoardDataList.indexOf(e) + 1;

                          Navigator.pop(context);
                        },
                      ),
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(
                        CupertinoIcons.power,
                        size: 17,
                        color: themeBasedColor,
                      ),
                      title: Text(
                        "Logout",
                        style: TextStyle(
                          fontFamily: 'Kiro',
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: themeBasedColor,
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text(
                                'Do you want to Logout ?',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    color: themeBasedColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              actions: [
                                SizedBox(
                                  height: 25.0,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          shape: MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius
                                                      .circular(18.0))),
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Provider.of<NavigationProvider>(
                                                                  context)
                                                              .themeMode ==
                                                          ThemeMode.dark
                                                      ? Colors.white
                                                      : appPrimeColor)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        loadingAlertBox(
                                            context, 'Logging Out...');
                                        closeLogoutLoadingAlertBox();
                                      },
                                      child: Text(
                                        'Yes',
                                        style: TextStyle(
                                            fontFamily: 'inter',
                                            fontSize: 12.0,
                                            color:
                                                Provider.of<NavigationProvider>(
                                                                context)
                                                            .themeMode ==
                                                        ThemeMode.dark
                                                    ? Colors.black
                                                    : Colors.white),
                                      )),
                                ),
                                SizedBox(
                                  height: 25.0,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0))),
                                          backgroundColor: MaterialStatePropertyAll(
                                              Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
                                                  ? Colors.white
                                                  : appPrimeColor)),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text('No',
                                          style: TextStyle(
                                              fontFamily: 'inter',
                                              fontSize: 12.0,
                                              color:
                                                  Provider.of<NavigationProvider>(context).themeMode ==
                                                          ThemeMode.dark
                                                      ? Colors.black
                                                      : Colors.white))),
                                ),
                              ],
                            );
                          },
                        );

                        // Implement logout functionality
                      },
                    ),
                    Spacer(),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) =>
                          getVersion(context, snapshot),
                    ),
                    SizedBox(
                      height: 15.0,
                    )
                  ],
                ),
              ),
              endDrawerEnableOpenDragGesture: false,
              endDrawer: Drawer(
                width: MediaQuery.of(context).size.width,
                child: NotificationScreen(),
              ),
              body: isLoading
                  ? Center(child: loadingProgress())
                  : pagePropagation![changeindex.getIndex],
            );
          },
        ));
  }
}
