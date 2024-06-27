// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/application/store.id.application.model.dart';
import 'package:staras_manager/model/machine/machine.model.dart';
import 'package:staras_manager/view/StoreManager/Device%20Management/add_new_machine.dart';
import 'package:staras_manager/view/StoreManager/Device%20Management/details_machine.dart';

class ListMachine extends StatefulWidget {
  const ListMachine({Key? key}) : super(key: key);

  @override
  _ListMachineState createState() => _ListMachineState();
}

class _ListMachineState extends State<ListMachine> {
  MainStoreIdModel? mainStoreId;
  List<MachineModel>? machines;
  List<MachineModel>? filteredMachines = [];
  final TextEditingController _searchController = TextEditingController();
  int selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    fetchDataStoreIdAPI();
    fetchMachinesForStore();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
      fetchDataStoreIdAPI();
      fetchMachinesForStore();
    }
  }

  Future<void> fetchDataStoreIdAPI() async {
    try {
      final String? accessToken = await readAccessToken();
      final response = await https.get(
        Uri.parse('$BASE_URL/api/employeeinstore/manager-get-main-storeid'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final mainStoreIdModel = MainStoreIdModel.fromJson(jsonData);
        setState(() {
          mainStoreId = mainStoreIdModel;
        });

        fetchMachinesForStore();
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      print('Error fetching mainStoreId: $e');
    }
  }

  Future<void> fetchMachinesForStore({String? searchText, int? mode}) async {
    final String? accessToken = await readAccessToken();
    var apiUrl = '$BASE_URL/api/attendancemachine?StoreId=${mainStoreId?.data}';

    var apiUrlWithParams =
        searchText != null ? '$apiUrl&Name=$searchText' : apiUrl;

    if (mode != null) {
      apiUrlWithParams += apiUrlWithParams.contains('?') ? '&' : '?';
      apiUrlWithParams += 'Mode=$mode';
    }
    print(apiUrlWithParams);

    final response = await https.get(
      Uri.parse(apiUrlWithParams),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        machines = [];
      });
      print('No machines data found (Status Code 204)');
    } else if (response.statusCode == 200) {
      final Map<String, dynamic> machineData = json.decode(response.body);

      if (machineData.containsKey('data') && machineData['data'] is List) {
        List<dynamic> machinesData = machineData['data'];

        List<MachineModel> machinesList = machinesData
            .map((machineJson) => MachineModel.fromJson(machineJson))
            .toList();

        setState(() {
          machines = machinesList;
          print('Machines List: $machinesList');
        });
      } else {
        print('No machines data found in the response');
      }
    } else {
      print('Failed to load machines');
      print(response.body);
      print(response.statusCode);
      setState(() {
        machines = [];
      });
    }
  }

  String getStatusText(int? mode) {
    if (mode == -1) {
      return 'Not Working';
    } else if (mode == 0) {
      return 'Maintenance';
    } else if (mode == 1) {
      return 'Working';
    } else {
      return 'Unknown';
    }
  }

  Color getStatusColor(int? mode) {
    if (mode == -1) {
      return Colors.red;
    } else if (mode == 0) {
      return Colors.orange;
    } else if (mode == 1) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNewMachine(),
            ),
          );
          if (result == true) {
            fetchDataStoreIdAPI();
          }
        },
        backgroundColor: kMainColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
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
            'List Machine',
            maxLines: 2,
            style: kTextStyle.copyWith(
              color: kDarkWhite,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
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
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 20, 10, 15),
                              hintText: 'Search Machine',
                              hintStyle: kTextStyle.copyWith(fontSize: 14),
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onChanged: (text) {
                              fetchMachinesForStore(searchText: text);
                            },
                          ),
                        ),
                      ),
                      PopupMenuButton(
                        offset: const Offset(0, 60),
                        elevation: 1,
                        iconSize: 25,
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
                            width: 180, height: 200),
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
                                    "Working",
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
                                    "Maintenance",
                                    style: selectedFilterIndex == 2
                                        ? kTextStyle.copyWith(
                                            fontSize: 15,
                                            color: Colors.yellow[700])
                                        : kTextStyle.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(width: 15),
                                  selectedFilterIndex == 2
                                      ? Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: Colors.yellow,
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 3,
                              child: Row(
                                children: [
                                  Text(
                                    "Not Working",
                                    style: selectedFilterIndex == 3
                                        ? kTextStyle.copyWith(
                                            fontSize: 15, color: Colors.red)
                                        : kTextStyle.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(width: 15),
                                  selectedFilterIndex == 3
                                      ? Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: Colors.red,
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
                            fetchMachinesForStore(
                                searchText: _searchController.text);
                          } else if (selectedFilterIndex == 1) {
                            fetchMachinesForStore(
                                searchText: _searchController.text, mode: 1);
                          } else if (selectedFilterIndex == 2) {
                            fetchMachinesForStore(
                                searchText: _searchController.text, mode: 0);
                          } else if (selectedFilterIndex == 3) {
                            fetchMachinesForStore(
                                searchText: _searchController.text, mode: -1);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Expanded(
                    child: machines == null || machines!.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            child: Text(
                              'No Machine',
                              style: kTextStyle.copyWith(
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: machines?.length,
                            itemBuilder: (context, index) {
                              final machine = machines?[index];
                              return Column(
                                children: [
                                  Container(
                                    width: context.width(),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          stops: [0.010, 0.010],
                                          colors: [kMainColor, Colors.white]),
                                      borderRadius: BorderRadius.circular(
                                          15.0), // Adjust the radius as needed
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 3,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DetailsMachine(
                                              id: machine?.id ?? 0,
                                            ),
                                          ),
                                        );
                                      },
                                      leading:
                                          Icon(Icons.phone_android_rounded),
                                      title: Text(
                                        machine?.name ?? '',
                                        maxLines: 2,
                                        style: kTextStyle.copyWith(
                                          color: kTitleColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Code: ${machine?.machineCode ?? ''}',
                                        maxLines: 2,
                                        style: kTextStyle.copyWith(
                                          color: kBlackTextColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                      trailing: Text(
                                        getStatusText(machine?.mode),
                                        style: kTextStyle.copyWith(
                                          color: getStatusColor(machine?.mode),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
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
