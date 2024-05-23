import 'package:flutter/material.dart';
import 'package:novo/API/APICall.dart';
import 'package:novo/LoadingPage/historyPageLoading.dart';
import 'package:novo/LoadingPage/ipoPageLoading.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/model/sgbModels/sgbdetailsmodel.dart';
import 'package:novo/model/sgbModels/sgbhistorymodel.dart';
import 'package:novo/screens/SGBscreens/sgbActivePage.dart';
import 'package:novo/screens/SGBscreens/sgbHistoryPage.dart';
import 'package:novo/utils/colors.dart';
import 'package:provider/provider.dart';

import '../../Provider/change_index.dart';
import '../../widgets/NOVO Widgets/customLoadingAni.dart';
import '../../widgets/NOVO Widgets/netWorkConnectionALertBox.dart';
import '../../widgets/NOVO Widgets/tabCountContainer.dart';

class Sgbpage extends StatefulWidget {
  const Sgbpage({super.key});

  @override
  State<Sgbpage> createState() => _SgbpageState();
}

class _SgbpageState extends State<Sgbpage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SgbMasterDetail? sgbMasterDataApi;
  SgbHistory? sgbHistoryDataApi;
  bool sgbPageLoading = true;

  @override
  void initState() {
    fetchSbgDetailsInAPI(context);
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  fetchSbgDetailsInAPI(context) async {
    if (await isInternetConnected()) {
      sgbMasterDataApi = await fetchSGBDetails(context: context);
      sgbHistoryDataApi = await fetchSgbHistory(context: context);
      if (mounted) {
        setState(() {
          sgbPageLoading = false;
        });
      }
    } else {
      noInternetConnectAlertDialog(
          context, () => fetchSbgDetailsInAPI(context));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  Provider.of<NavigationProvider>(context).themeMode ==
                          ThemeMode.dark
                      ? "assets/SGB WNovo Icon.png"
                      : "assets/SGB BNovo Icon.png",
                  width: 34.0,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                const Text(
                  'Sovereign Gold Bond',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kiro',
                      height: 0.5),
                ),
              ],
            ),
            const SizedBox(
              height: 12.0,
            ),
            Container(
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(
                  15.0,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    15.0,
                  ),
                  color: appPrimeColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                labelStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'inter'),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Invest'),
                        // const SizedBox(
                        //   width: 5.0,
                        // ),
                        // sgbPageLoading
                        //     ? const SizedBox()
                        //     : sgbMasterDataApi == null ||
                        //             sgbMasterDataApi!.sgbDetail == null ||
                        //             sgbMasterDataApi!.investCount
                        //                 .toString()
                        //                 .isEmpty ||
                        //             sgbMasterDataApi!.investCount < 0 ||
                        //             sgbMasterDataApi!.investCount == 0 ||
                        //             sgbMasterDataApi!.masterFound != 'Y'
                        //         ? const SizedBox()
                        //         : TabinfoContainer(
                        //             tabCount:
                        //                 '${sgbMasterDataApi!.investCount}',
                        //           )
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order'),
                        // const SizedBox(
                        //   width: 5.0,
                        // ),
                        // sgbPageLoading
                        //     ? const SizedBox()
                        //     : sgbHistoryDataApi == null ||
                        //             sgbHistoryDataApi!.sgbOrderHistoryArr ==
                        //                 null ||
                        //             sgbHistoryDataApi!.orderCount
                        //                 .toString()
                        //                 .isEmpty ||
                        //             sgbHistoryDataApi!.orderCount < 0 ||
                        //             sgbHistoryDataApi!.orderCount == 0 ||
                        //             sgbHistoryDataApi!.historyFound != 'Y'
                        //         ? const SizedBox()
                        //         : TabinfoContainer(
                        //             tabCount:
                        //                 '${sgbHistoryDataApi?.orderCount}',
                        //           )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  sgbPageLoading
                      ? const Center(
                          child: loadingProgress(),
                        )
                      : sgbMasterDataApi == null ||
                              sgbMasterDataApi!.masterFound.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                    'Something went wrong, Please Retry...'),
                                IconButton(
                                    iconSize: 30,
                                    splashColor: appPrimeColor,
                                    splashRadius: 20,
                                    onPressed: () async {
                                      await fetchSbgDetailsInAPI(context);
                                    },
                                    icon: const Icon(Icons.refresh_outlined))
                              ],
                            )
                          :
                          // first tab bar view widget
                          !(sgbMasterDataApi!.masterFound == 'Y' ||
                                  sgbMasterDataApi!.masterFound == 'N')
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                        'Something went wrong, Please Retry...'),
                                    IconButton(
                                        iconSize: 30,
                                        splashColor: appPrimeColor,
                                        splashRadius: 20,
                                        onPressed: () async {
                                          await fetchSbgDetailsInAPI(context);
                                        },
                                        icon:
                                            const Icon(Icons.refresh_outlined))
                                  ],
                                )
                              : SgbActiveScreen(
                                  sgbMasterData: sgbMasterDataApi,
                                ),

                  //History tab
                  sgbPageLoading
                      ? const Center(
                          child: loadingProgress(),
                        )
                      : sgbHistoryDataApi == null ||
                              sgbHistoryDataApi!.historyFound.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                    'Something went wrong, Please Retry...'),
                                IconButton(
                                    iconSize: 30,
                                    splashColor: appPrimeColor,
                                    splashRadius: 20,
                                    onPressed: () async {
                                      await fetchSbgDetailsInAPI(context);
                                    },
                                    icon: const Icon(Icons.refresh_outlined))
                              ],
                            )
                          : !(sgbHistoryDataApi!.historyFound == 'Y' ||
                                  sgbHistoryDataApi!.historyFound == 'N')
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                        'Something went wrong, Please Retry...'),
                                    IconButton(
                                        iconSize: 30,
                                        splashColor: appPrimeColor,
                                        splashRadius: 20,
                                        onPressed: () async {
                                          await fetchSbgDetailsInAPI(context);
                                        },
                                        icon:
                                            const Icon(Icons.refresh_outlined))
                                  ],
                                )
                              : SgbappliedPage(
                                  sgbHistoryData: sgbHistoryDataApi,
                                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
