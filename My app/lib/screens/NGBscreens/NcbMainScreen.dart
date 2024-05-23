// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:novo/API/APICall.dart';
import 'package:novo/model/ncbModels/ncbHistoryModel.dart';
import 'package:novo/model/ncbModels/ncbmasterModel.dart';

import 'package:novo/screens/NGBscreens/NcbActiveScreen.dart';
import 'package:novo/screens/NGBscreens/NcbHistoryScreen.dart';

import 'package:novo/utils/colors.dart';

// import '/Roating/route.dart' as route;

class NcbMainScreen extends StatefulWidget {
  NcbMainScreen(
      {super.key,
      required this.ncbMasterDetails,
      required this.ncbMasterList,
      required this.ncbMasterFound,
      required this.ncbNoDataText,
      required this.ncbHistoryDetails,
      required this.ncbHistoryList,
      required this.ncbHistoryFound,
      required this.ncbHistoryNoDataText,
      required this.ncbDisclimer,
      required this.index});
  NcbMasterDetails ncbMasterDetails;
  List<Detail> ncbMasterList;
  String ncbMasterFound;
  String ncbNoDataText;
  NcbHistoryModel ncbHistoryDetails;
  List<OrderHistoryArr> ncbHistoryList;
  String ncbHistoryFound;
  String ncbHistoryNoDataText;
  String ncbDisclimer;
  int index;

  @override
  State<NcbMainScreen> createState() => _NcbMainScreenState();
}

class _NcbMainScreenState extends State<NcbMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // SgbMasterDetail? sgbMasterDataApi;
  // SgbHistory? sgbHistoryDataApi;
  // bool sgbPageLoading = true;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    //////////print(widget.ncbMasterDetails);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // SgbTabCount sgbTabCount = SgbTabCount();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.min,
          children: [
            // give the tab bar a height [can change hheight to preferred height]

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
                // give the indicator a decoration (color and border radius)
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
                tabs: const [
                  // first tab [you can add an icon using the icon property]
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invest'),
                        SizedBox(
                          width: 5.0,
                        ),
                      ],
                    ),
                  ),

                  // second tab [you can add an icon using the icon property]
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order'),
                        SizedBox(
                          width: 5.0,
                        ),
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
                  widget.ncbMasterList == [] &&
                          !(widget.ncbMasterFound == 'Y' ||
                              widget.ncbMasterFound == 'N')
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Something went wrong, Please Retry...'),
                            IconButton(
                                onPressed: () async {
                                  await fetchNcbDetails(context: context);
                                },
                                icon: const Icon(Icons.refresh_outlined))
                          ],
                        )
                      : NcbActivScreen(
                          ncbMasterDetailData: widget.ncbMasterDetails,
                          ncbMasterList: widget.ncbMasterList,
                          ncbMasterFound: widget.ncbMasterFound,
                          ncbNoDataText: widget.ncbNoDataText,
                          ncbDisclaimer: widget.ncbDisclimer,
                          index: widget.index),
                  widget.ncbHistoryList == [] &&
                          !(widget.ncbHistoryFound == 'Y' ||
                              widget.ncbHistoryFound == 'N')
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Something went wrong, Please Retry...'),
                            IconButton(
                                onPressed: () async {
                                  await fetchNcbHistory(context: context);
                                },
                                icon: const Icon(Icons.refresh_outlined))
                          ],
                        )
                      : NcbHistoryScreen(
                          ncbHistoryDetails: widget.ncbHistoryDetails,
                          ncbHistoryList: widget.ncbHistoryList,
                          ncbHistoryFound: widget.ncbHistoryFound,
                          ncbHistoryNoDataText: widget.ncbHistoryNoDataText,
                          ncbDisclimer: widget.ncbDisclimer)
                ],
              ),
            ),
            // FooterSbgWidget(disclimerText: sgbMasterDataApi!.disclaimer),
          ],
        ),
      ),
    );
  }
}
