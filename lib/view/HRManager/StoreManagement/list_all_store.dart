// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, sized_box_for_whitespace, unnecessary_null_comparison

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:http/http.dart' as http;
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/store/store.model.dart';
import 'package:staras_manager/view/HRManager/StoreManagement/add_new_store.dart';
import 'package:staras_manager/view/HRManager/StoreManagement/detail_store.dart';

class GetAllStore extends StatefulWidget {
  const GetAllStore({Key? key}) : super(key: key);

  @override
  _GetAllStoreState createState() => _GetAllStoreState();
}

class _GetAllStoreState extends State<GetAllStore> {
  final TextEditingController _searchController = TextEditingController();
  List<StoreModel> stores = [];

  int selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    selectedFilterIndex = 1;
    fetchStoreData(active: true);
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
      fetchStoreData(searchText: _searchController.text, active: true);
    }
  }

  Future<void> fetchStoreData({String? searchText, bool? active}) async {
    final String? accessToken = await readAccessToken();

    var apiUrl = '$BASE_URL/api/store/hr-get-store-list';
    var apiUrlWithParams =
        searchText != null ? '$apiUrl?StoreName=$searchText' : apiUrl;

    if (active != null) {
      apiUrlWithParams += apiUrlWithParams.contains('?') ? '&' : '?';
      apiUrlWithParams += 'Active=$active';
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrlWithParams),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print(apiUrlWithParams);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('data')) {
          final List<dynamic> storeData = responseData['data'];

          final List<StoreModel> storeList =
              storeData.map((json) => StoreModel.fromJson(json)).toList();

          setState(() {
            stores = storeList;
          });
        } else {
          print(
              'API Error: Response does not contain the expected data structure.');
          setState(() {
            stores = [];
          });
        }
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
        setState(() {
          stores = [];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      setState(() {
        stores = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Store List',
            maxLines: 2,
            style: kTextStyle.copyWith(
              color: kDarkWhite,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => const AddNewStore(),
                    //   ),
                    // );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddNewStore(
                          onAddStoreSuccess: () {
                            fetchStoreData(active: true);
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    side: BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // <-- Radius
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        size: 20,
                        color: white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Add',
                        style: kTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: context.width(),
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        child: TextFormField(
                          readOnly: true,
                          style: kTextStyle.copyWith(
                              fontSize: 15, color: Colors.black),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: 'Total',
                            hintText: stores.length.toString(),
                            labelStyle: kTextStyle.copyWith(
                                color: kMainColor, fontWeight: FontWeight.bold),
                            hintStyle: kTextStyle.copyWith(
                              fontSize: 15,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 230,
                        height: 60,
                        child: TextFormField(
                          controller: _searchController,
                          style: kTextStyle.copyWith(
                              fontSize: 15, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Search Store',
                            hintStyle: kTextStyle.copyWith(fontSize: 14),
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onChanged: (text) {
                            fetchStoreData(searchText: text);
                          },
                        ),
                      ),
                      PopupMenuButton(
                        offset: const Offset(0, 40),
                        elevation: 1,
                        iconSize: 30,
                        icon: Icon(
                          selectedFilterIndex == 0
                              ? Icons.filter_alt_outlined
                              : Icons.filter_alt_off_outlined,
                          color: kGreenColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                        constraints: const BoxConstraints.expand(
                            width: 150, height: 160),
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: 0,
                              child: Row(
                                children: [
                                  Text(
                                    "All",
                                    style: selectedFilterIndex == 0
                                        ? kTextStyle.copyWith(
                                            fontSize: 15, color: Colors.green)
                                        : kTextStyle.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(width: 15),
                                  selectedFilterIndex == 0
                                      ? Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: Colors.green,
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 1,
                              child: Row(
                                children: [
                                  Text(
                                    "Active",
                                    style: selectedFilterIndex == 1
                                        ? kTextStyle.copyWith(
                                            fontSize: 15, color: Colors.green)
                                        : kTextStyle.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(width: 15),
                                  selectedFilterIndex == 1
                                      ? Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: Colors.green,
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 2,
                              child: Row(
                                children: [
                                  Text(
                                    "Not Active",
                                    style: selectedFilterIndex == 2
                                        ? kTextStyle.copyWith(
                                            fontSize: 15, color: Colors.green)
                                        : kTextStyle.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(width: 15),
                                  selectedFilterIndex == 2
                                      ? Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: Colors.green,
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ];
                        },
                        onSelected: (value) {
                          setState(() {
                            selectedFilterIndex = value;
                          });

                          if (selectedFilterIndex == 0) {
                            fetchStoreData(searchText: _searchController.text);
                          } else if (selectedFilterIndex == 1) {
                            fetchStoreData(
                                searchText: _searchController.text,
                                active: true);
                          } else if (selectedFilterIndex == 2) {
                            fetchStoreData(
                                searchText: _searchController.text,
                                active: false);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Expanded(
                    child: stores == null || stores.isEmpty
                        ? Center(
                            child: Text(
                              'No Store',
                              style: kTextStyle.copyWith(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: stores.length,
                            itemBuilder: (context, index) {
                              final store = stores[index];

                              Color? borderColor = store.active == true
                                  ? kMainColor
                                  : Colors.red[200];
                              Color? iconColor = store.active == true
                                  ? kMainColor
                                  : Colors.red[200];
                              Color storeNameColor = store.active == true
                                  ? Colors.black
                                  : Colors.grey;

                              return Column(
                                children: [
                                  Material(
                                    elevation: 2.0,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailsStore(
                                              id: store.id ?? 0,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: context.width(),
                                        height: 78,
                                        padding: const EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: borderColor!,
                                              width: 3.0,
                                            ),
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.store_rounded,
                                            color: iconColor,
                                          ),
                                          title: Text(
                                            store.storeName ?? '',
                                            style: kTextStyle.copyWith(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                              color: storeNameColor,
                                            ),
                                            maxLines: null,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Text(
                                            store.active == true
                                                ? 'Active'
                                                : 'Not Active',
                                            style: kTextStyle.copyWith(
                                              color: store.active == true
                                                  ? Colors.green
                                                  : Colors.red[200],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                          trailing: Icon(
                                            Icons.arrow_forward_ios,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  )
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
