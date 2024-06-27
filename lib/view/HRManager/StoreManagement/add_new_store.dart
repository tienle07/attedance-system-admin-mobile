// ignore_for_file: depend_on_referenced_packages, unused_field, use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/common/toast.dart';
import 'package:staras_manager/components/button_global.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/api_address.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/address/districts.model.dart';
import 'package:staras_manager/model/address/provinces.model.dart';
import 'package:staras_manager/model/address/wards.model.dart';
import 'package:staras_manager/model/employee/dropdown.promote.employee.dart';
import 'package:staras_manager/model/store/store.request.model.dart';

class AddNewStore extends StatefulWidget {
  final Function()? onAddStoreSuccess;
  const AddNewStore({Key? key, this.onAddStoreSuccess}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddNewStoreState createState() => _AddNewStoreState();
}

class _AddNewStoreState extends State<AddNewStore> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiAddress apiAddress = ApiAddress();
  List<ProvincesModel>? _dropdownProvinces;
  ProvincesModel? _selectedProvince;
  List<DistrictsModel>? _dropdownDistricts;
  DistrictsModel? _selectedDistrict;
  List<WardsModel>? _dropdownWards;
  WardsModel? _selectedWard;
  List<PromoteEmployeeModel>? _dropdownPromoteEmployees;
  PromoteEmployeeModel? _selectedPromoteEmployee;
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  TextEditingController textEditingController = TextEditingController();
  TextEditingController storeName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController openTime = TextEditingController();
  TextEditingController closeTime = TextEditingController();
  TextEditingController latitude = TextEditingController();
  TextEditingController longitude = TextEditingController();
  TextEditingController bssid = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getDropDownProvincesItems();
    _getDropDownPromoteEmployee();
    checkTokenExpiration();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
    }
  }

  Future<void> _selectTime(BuildContext context, String field) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (field == 'opening') {
          openingTime = pickedTime;
          openTime.text = openingTime!.format(context);
          print('Selected Opening Time: ${openingTime!.format(context)}');
        } else if (field == 'closing') {
          closingTime = pickedTime;
          closeTime.text = closingTime!.format(context);
          print('Selected Closing Time: ${closingTime!.format(context)}');
        }
      });
    }
  }

  void _getDropDownProvincesItems() async {
    try {
      final String? accessToken = await readAccessToken();
      final provinces = await apiAddress.getProvinces(accessToken!);
      setState(() {
        _dropdownProvinces = provinces;
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  void _getDropDownDistrictsItems(int? selectedProvinceCode) async {
    try {
      final String? accessToken = await readAccessToken();
      final districts =
          await apiAddress.getDistricts(accessToken!, selectedProvinceCode);
      setState(() {
        _dropdownDistricts = districts;
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  void _getDropDownWardsItems(int? selectedDistrictCode) async {
    try {
      final String? accessToken = await readAccessToken();
      final wards =
          await apiAddress.getWards(accessToken!, selectedDistrictCode);
      setState(() {
        _dropdownWards = wards;
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  void _getDropDownPromoteEmployee() async {
    try {
      final String? accessToken = await readAccessToken();
      final promoteEmployees =
          await apiAddress.getPromoteEmployees(accessToken!);
      setState(() {
        _dropdownPromoteEmployees = promoteEmployees;
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> createNewStore() async {
    if (_formKey.currentState!.validate()) {
      try {
        final String? accessToken = await readAccessToken();
        var apiUrl = '$BASE_URL/api/store/hr-add-new-store';

        final StoreRequestModel newStore = StoreRequestModel(
          storeName: storeName.text,
          storeManagerId: _selectedPromoteEmployee?.id,
          address: buildAddress(),
          openTime: "${openTime.text}:00",
          closeTime: "${closeTime.text}:00",
          latitude: latitude.text,
          longitude: longitude.text,
          bssid: bssid.text,
        );

        final Map<String, dynamic> jsonData = newStore.toJson();
        print(jsonData.toString());
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode(jsonData),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          showToast(
            context: context,
            msg: "Add Store Successfully",
            color: Color.fromARGB(255, 128, 249, 16),
            icon: const Icon(Icons.done),
          );
          widget.onAddStoreSuccess?.call();

          Navigator.of(context).pop();
        } else if (response.statusCode >= 400 && response.statusCode <= 500) {
          final Map<String, dynamic> errorResponse = json.decode(response.body);
          final String errorMessage =
              errorResponse['message'] ?? 'Can not add store =';
          print(
              'Failed to create machine. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          showToast(
            context: context,
            msg: errorMessage,
            color: Colors.red,
            icon: const Icon(Icons.error),
          );
        }
      } catch (error) {
        print('Error: $error');
      }
    }
  }

  String buildAddress() {
    String selectedProvince =
        '${_selectedProvince?.provinceType ?? ''} ${_selectedProvince?.provinceName ?? ''}';
    String selectedDistrict =
        '${_selectedDistrict?.districtType ?? ''} ${_selectedDistrict?.districtName ?? ''}';
    String selectedWard =
        '${_selectedWard?.wardType ?? ''} ${_selectedWard?.wardName ?? ''}';
    String addressText = address.text;

    String completeAddress =
        '$addressText, $selectedWard, $selectedDistrict, $selectedProvince';

    return completeAddress;
  }

  void printCompleteAddress() {
    String completeAddress = buildAddress();
    print('Complete Address: $completeAddress');
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
        title: Text(
          'Create New Store',
          maxLines: 2,
          style: kTextStyle.copyWith(
            color: kDarkWhite,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: context.width(),
                height: 1400,
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
                      height: 20.0,
                    ),
                    const Row(
                      children: [
                        Icon(Icons.store),
                        SizedBox(width: 10.0),
                        Text(
                          "Create New Store",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    TextFormField(
                      controller: storeName,
                      style: kTextStyle.copyWith(
                          fontSize: 15, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Name Store ',
                        labelStyle: kTextStyle,
                        hintText: "Enter Name Store",
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                        contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 16),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (storeName) {
                        if (storeName == null || storeName.isEmpty) {
                          return 'Please enter store name';
                        } else if (storeName.length <= 4) {
                          return 'Store Name must be at least 5 characters';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField2<PromoteEmployeeModel>(
                        isExpanded: true,
                        value: _selectedPromoteEmployee,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        hint: Text(
                          'Select Manager',
                          style: kTextStyle.copyWith(fontSize: 15),
                        ),
                        items: _dropdownPromoteEmployees
                            ?.map(
                              (item) => DropdownMenuItem<PromoteEmployeeModel>(
                                value: item,
                                child: Text(
                                  item.name ?? '',
                                  style: kTextStyle.copyWith(fontSize: 14),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPromoteEmployee = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select manager';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.only(right: 8),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                          iconSize: 24,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField2<ProvincesModel>(
                        isExpanded: true,
                        value: _selectedProvince,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        hint: Text(
                          'Select Province',
                          style: kTextStyle.copyWith(fontSize: 15),
                        ),
                        items: _dropdownProvinces
                            ?.map(
                              (item) => DropdownMenuItem<ProvincesModel>(
                                value: item,
                                child: Text(
                                  '${item.provinceType} ${item.provinceName}',
                                  style: kTextStyle.copyWith(fontSize: 14),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProvince = value;
                            _selectedDistrict = null;
                            _selectedWard = null;
                            _getDropDownDistrictsItems(value?.provinceCode);
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select province';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.only(right: 8),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                          iconSize: 24,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    DropdownButtonFormField2<DistrictsModel>(
                      isExpanded: true,
                      value: _selectedDistrict,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      hint: Text(
                        'Select District',
                        style: kTextStyle.copyWith(fontSize: 15),
                      ),
                      items: _dropdownDistricts
                          ?.map(
                            (item) => DropdownMenuItem<DistrictsModel>(
                              value: item,
                              child: Text(
                                '${item.districtType} ${item.districtName}',
                                style: kTextStyle.copyWith(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDistrict = value;
                          _selectedWard = null; // Clear the selected district
                          _getDropDownWardsItems(value?.districtCode);
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select district';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.only(right: 8),
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black45,
                        ),
                        iconSize: 24,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    DropdownButtonFormField2<WardsModel>(
                      isExpanded: true,
                      value: _selectedWard,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      hint: Text(
                        'Select Ward',
                        style: kTextStyle.copyWith(fontSize: 15),
                      ),
                      items: _dropdownWards
                          ?.map(
                            (item) => DropdownMenuItem<WardsModel>(
                              value: item,
                              child: Text(
                                '${item.wardType} ${item.wardName}',
                                style: kTextStyle.copyWith(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedWard = value;
                        });
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null) {
                          return 'Please select ward';
                        }
                        return null;
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.only(right: 8),
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black45,
                        ),
                        iconSize: 24,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: address,
                      style: kTextStyle.copyWith(
                          fontSize: 15, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Address ',
                        labelStyle: kTextStyle,
                        hintText: "Enter Address Store",
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                        contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 16),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (address) {
                        if (address == null || address.isEmpty) {
                          return 'Please enter store address';
                        } else if (address.length <= 4) {
                          return 'Address at least  5 characters';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: openTime,
                      style: kTextStyle.copyWith(
                          fontSize: 15, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Open Time',
                        labelStyle: kTextStyle,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 16),
                        hintText: openingTime != null
                            ? openingTime?.format(context)
                            : 'Open Time',
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        suffixIcon: const Icon(
                          Icons.access_time,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        _selectTime(context, 'opening');
                      },
                      validator: (openTime) {
                        if (openTime == null || openTime.isEmpty) {
                          return 'Select open time';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ), // Khoảng cách giữa hai ô nhập
                    TextFormField(
                      controller: closeTime,
                      style: kTextStyle.copyWith(
                          fontSize: 15, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Close Time',
                        labelStyle: kTextStyle,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 16),
                        hintText: closingTime != null
                            ? closingTime?.format(context)
                            : 'Close Time',
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        suffixIcon: const Icon(
                          Icons.access_time,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        _selectTime(context, 'closing');
                      },
                      validator: (closeTime) {
                        if (closeTime == null || closeTime.isEmpty) {
                          return 'Select close time';
                        }
                        TimeOfDay selectedOpenTime = openingTime!;
                        TimeOfDay selectedCloseTime = closingTime!;

                        // Compare the two times
                        if (selectedCloseTime.hour < selectedOpenTime.hour ||
                            (selectedCloseTime.hour == selectedOpenTime.hour &&
                                selectedCloseTime.minute <=
                                    selectedOpenTime.minute)) {
                          return 'Close time must be after open time';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: longitude,
                      style: kTextStyle.copyWith(
                          fontSize: 15, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        labelStyle: kTextStyle,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 16),
                        hintText: 'Enter The Longitude',
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (longitude) {
                        if (longitude == null || longitude.isEmpty) {
                          return 'Please enter the longitude';
                        }

                        // Regex pattern for longitude between -180 and 180
                        RegExp regex = RegExp(
                            r'^-?((1[0-7][0-9])|([0-9]{1,2}))(\.[0-9]+)?$|^-?180(\.0+)?$');

                        if (!regex.hasMatch(longitude)) {
                          return 'Enter valid longitude';
                        }

                        if (longitude.length > 10) {
                          return 'Longitude not more than 10 characters';
                        }

                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: latitude,
                      style: kTextStyle.copyWith(
                          fontSize: 15, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        labelStyle: kTextStyle,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 16),
                        hintText: 'Enter The Latitude',
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (latitude) {
                        if (latitude == null || latitude.isEmpty) {
                          return 'Please enter the latitude';
                        }

                        // Regex pattern for latitude between -90 and 90
                        RegExp regex = RegExp(
                            r'^-?((1[0-8][0-9])|([0-9]{1,2}))(\.[0-9]+)?$|^-?90(\.0+)?$');

                        if (!regex.hasMatch(latitude)) {
                          return 'Enter valid latitude';
                        }

                        if (latitude.length > 10) {
                          return 'Latitude not more than 10 characters';
                        }

                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: bssid,
                      style: kTextStyle.copyWith(
                          fontSize: 15, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Bssid',
                        labelStyle: kTextStyle,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: 'Enter The Bssid',
                        contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 16),
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (bssid) {
                        if (bssid == null || bssid.isEmpty) {
                          return 'Please enter the BSSID';
                        }

                        // Regex pattern for XX:XX:XX:XX:XX:XX format
                        RegExp regex =
                            RegExp(r'^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$');

                        if (!regex.hasMatch(bssid)) {
                          return 'Please enter in XX:XX:XX:XX:XX:XX format';
                        }

                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    ButtonGlobal(
                        buttontext: 'Add Store',
                        buttonDecoration:
                            kButtonDecoration.copyWith(color: kMainColor),
                        onPressed: () async {
                          printCompleteAddress();

                          await createNewStore();
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
