// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:staras_manager/Controllers/api.dart';
import 'package:staras_manager/components/button_global.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/address/districts.model.dart';
import 'package:staras_manager/model/address/provinces.model.dart';
import 'package:staras_manager/model/address/wards.model.dart';
import 'package:staras_manager/model/employee/employee.profile.model.dart';
import 'package:staras_manager/utils/validator.dart';
import 'package:staras_manager/common/toast.dart';

// ignore: must_be_immutable
class EditProfileEmployee extends StatefulWidget {
  EmployeeProfile? employeeProfile;
  final Function callBack;
  final int id;
  EditProfileEmployee(
      {Key? key,
      required this.employeeProfile,
      required this.id,
      required this.callBack})
      : super(key: key);

  @override
  State<EditProfileEmployee> createState() => _EditProfileEmployeeState();
}

class _EditProfileEmployeeState extends State<EditProfileEmployee> {
  void _onProfileEdited(EmployeeProfile editedProfile) {
    if (mounted) {
      widget.callBack(editedProfile);
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<ProvincesModel> provinces = [];
  List<DistrictsModel> districts = [];
  List<WardsModel> wards = [];

  List<ProvincesModel> originProvinces = [];
  List<DistrictsModel> originDistricts = [];
  List<WardsModel> originWards = [];

  List<ProvincesModel> residenceProvinces = [];
  List<DistrictsModel> residenceDistricts = [];
  List<WardsModel> residenceWards = [];

  // Selected values
  ProvincesModel? selectedProvince;
  DistrictsModel? selectedDistrict;
  WardsModel? selectedWard;

  ProvincesModel? selectedOriginProvince;
  DistrictsModel? selectedOriginDistrict;
  WardsModel? selectedOriginWard;

  ProvincesModel? selectedResidenceProvince;
  DistrictsModel? selectedResidenceDistrict;
  WardsModel? selectedResidenceWard;

  EmployeeProfile employeeProfile = EmployeeProfile();
  TextEditingController code = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController currentAddress = TextEditingController();
  TextEditingController level = TextEditingController();
  TextEditingController profileImage = TextEditingController();
  TextEditingController citizenId = TextEditingController();
  TextEditingController fullName = TextEditingController();
  TextEditingController dateOfBirth = TextEditingController();
  TextEditingController enrollmentDate = TextEditingController();
  TextEditingController sex = TextEditingController();
  TextEditingController nationality = TextEditingController();
  TextEditingController placeOfOrigrin = TextEditingController();
  TextEditingController placeOfResidence = TextEditingController();
  TextEditingController dateOfIssue = TextEditingController();
  TextEditingController issuedBy = TextEditingController();

  TextEditingController addressInDialog = TextEditingController();
  TextEditingController addressInPlaceOfOrigin = TextEditingController();
  TextEditingController addressInPlaceOfResidence = TextEditingController();

  void _saveForm() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
  }

  String? _selectedGender;
  final List<String> genderItems = [
    'Male',
    'Female',
  ];

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _imageFile; // Sử dụng XFile để lưu trữ hình ảnh đã chọn

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    fetchData().then((value) {
      provinces = value;
      setState(() {});
    });
    fetchData().then((value) {
      originProvinces = value;
      setState(() {});
    });
    fetchData().then((value) {
      residenceProvinces = value;
      setState(() {});
    });

    employeeProfile = widget.employeeProfile ?? EmployeeProfile();
    super.initState();
    code.text = widget.employeeProfile?.employeeResponse?.code ?? '';
    name.text = widget.employeeProfile?.employeeResponse?.name ?? '';
    email.text = widget.employeeProfile?.employeeResponse?.email ?? '';
    phone.text = widget.employeeProfile?.employeeResponse?.phone ?? '';
    currentAddress.text =
        widget.employeeProfile?.employeeResponse?.currentAddress ?? '';
    level.text =
        widget.employeeProfile?.employeeResponse?.level.toString() ?? '';
    profileImage.text =
        widget.employeeProfile?.employeeResponse?.profileImage ?? '';

    citizenId.text = widget.employeeProfile?.employeeResponse?.citizenId ?? '';
    dateOfBirth.text = DateFormat('yyyy-MM-dd').format(
        widget.employeeProfile?.employeeResponse?.dateOfBirth ??
            DateTime.now());
    enrollmentDate.text = DateFormat('yyyy-MM-dd').format(
        widget.employeeProfile?.employeeResponse?.enrollmentDate ??
            DateTime.now());
    _selectedGender = widget.employeeProfile?.employeeResponse?.sex ?? '';
    nationality.text =
        widget.employeeProfile?.employeeResponse?.nationality ?? '';

    placeOfOrigrin.text =
        widget.employeeProfile?.employeeResponse?.placeOfOrigrin ?? '';
    placeOfResidence.text =
        widget.employeeProfile?.employeeResponse?.placeOfResidence ?? '';
    dateOfIssue.text = DateFormat('yyyy-MM-dd').format(
        widget.employeeProfile?.employeeResponse?.dateOfIssue ??
            DateTime.now());
    issuedBy.text = widget.employeeProfile?.employeeResponse?.issuedBy ?? '';
  }

  @override
  void dispose() {
    code.dispose();
    name.dispose();
    email.dispose();
    phone.dispose();
    currentAddress.dispose();
    level.dispose();
    profileImage.dispose();
    citizenId.dispose();
    dateOfBirth.dispose();
    sex.dispose();
    nationality.dispose();
    placeOfOrigrin.dispose();
    placeOfResidence.dispose();
    dateOfIssue.dispose();
    issuedBy.dispose();
    super.dispose();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
    }
  }

  void _pickImage() async {
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });

      Reference ref =
          FirebaseStorage.instance.ref().child('avatar/${DateTime.now()}.png');
      final UploadTask uploadTask = ref.putFile(File(pickedFile.path));

      // Get the download URL when the upload is complete
      uploadTask.then((res) async {
        String downloadURL = await res.ref.getDownloadURL();
        print('Download URL: $downloadURL');

        setState(() {
          employeeProfile.employeeResponse?.profileImage = downloadURL;
        });
      });
    }
  }

  Future<List<ProvincesModel>> fetchData() async {
    final String apiUrl = '$BASE_URL/api/address/provinces';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      // Check the API response structure
      if (data.containsKey("data")) {
        final List<dynamic> dataList = data["data"];

        // Parse data into model instances
        return dataList.map((item) => ProvincesModel.fromJson(item)).toList();
      } else {
        throw Exception('Invalid API response structure');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<DistrictsModel>> fetchDistricts(int? provinceCode) async {
    final String apiUrl = '$BASE_URL/api/address/districts/$provinceCode';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      // Check the API response structure
      if (data.containsKey("data")) {
        final List<dynamic> dataList = data["data"];

        // Parse data into model instances
        return dataList.map((item) => DistrictsModel.fromJson(item)).toList();
      } else {
        throw Exception('Invalid API response structure');
      }
    } else {
      throw Exception('Failed to load districts');
    }
  }

  Future<List<WardsModel>> fetchWards(int? districtCode) async {
    final String apiUrl = '$BASE_URL/api/address/wards/$districtCode';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      // Check the API response structure
      if (data.containsKey("data")) {
        final List<dynamic> dataList = data["data"];

        // Parse data into model instances
        return dataList.map((item) => WardsModel.fromJson(item)).toList();
      } else {
        throw Exception('Invalid API response structure');
      }
    } else {
      throw Exception('Failed to load wards');
    }
  }

  Future<void> _selectedCurrentAddress() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Address'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField2<ProvincesModel>(
                      isExpanded: true,
                      value: selectedProvince,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      hint: Text(
                        'Select Province',
                        style: kTextStyle.copyWith(fontSize: 15),
                      ),
                      items: provinces
                          .map(
                            (province) => DropdownMenuItem<ProvincesModel>(
                              value: province,
                              child: Text(
                                '${province.provinceType} ${province.provinceName}',
                                style: kTextStyle.copyWith(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProvince = value;
                          selectedDistrict = null;
                          selectedWard = null;
                        });
                        fetchDistricts(value?.provinceCode).then(
                          (value) {
                            districts = value;
                            setState(() {});
                          },
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    // Dropdown for selecting district
                    DropdownButtonFormField2<DistrictsModel>(
                      isExpanded: true,
                      value: selectedDistrict,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      hint: Text(
                        'Select District',
                        style: kTextStyle.copyWith(fontSize: 15),
                      ),
                      items: districts
                          .map(
                            (district) => DropdownMenuItem<DistrictsModel>(
                              value: district,
                              child: Text(
                                '${district.districtType} ${district.districtName}',
                                style: kTextStyle.copyWith(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDistrict = value;
                          selectedWard = null;
                        });
                        fetchWards(value?.districtCode).then((value) {
                          wards = value;
                          setState(() {});
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    // Dropdown for selecting ward
                    DropdownButtonFormField2<WardsModel>(
                      isExpanded: true,
                      value: selectedWard,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      hint: Text(
                        'Select Ward',
                        style: kTextStyle.copyWith(fontSize: 15),
                      ),
                      items: wards
                          .map(
                            (ward) => DropdownMenuItem<WardsModel>(
                              value: ward,
                              child: Text(
                                '${ward.wardType} ${ward.wardName}',
                                style: kTextStyle.copyWith(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedWard = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),

                    TextFormField(
                      controller: addressInDialog,
                      style: kTextStyle.copyWith(
                          fontSize: 15, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Address',
                        labelStyle: kTextStyle,
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: 'Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Use the selected values to update your address or perform other actions
                    String completeAddress = buildAddress();
                    print('Complete Address: $completeAddress');
                    currentAddress.text = completeAddress;

                    // Close the dialog
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String buildAddress() {
    String selectedProvinces =
        '${selectedProvince?.provinceType ?? ''} ${selectedProvince?.provinceName ?? ''}';
    String selectedDistricts =
        '${selectedDistrict?.districtType ?? ''} ${selectedDistrict?.districtName ?? ''}';
    String selectedWards =
        '${selectedWard?.wardType ?? ''} ${selectedWard?.wardName ?? ''}';
    String addressText = addressInDialog.text;

    String completeAddress =
        '$addressText, $selectedWards, $selectedDistricts, $selectedProvinces';

    return completeAddress;
  }

  // void printCompleteAddress() {
  //   String completeAddress = buildAddress();
  //   print('Complete Address: $completeAddress');
  // }

  Future<void> _selectedPlaceOfOrigin() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Address'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField2<ProvincesModel>(
                      isExpanded: true,
                      value: selectedOriginProvince,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      hint: Text(
                        'Select Province',
                        style: kTextStyle.copyWith(fontSize: 15),
                      ),
                      items: originProvinces
                          .map(
                            (originProvinces) =>
                                DropdownMenuItem<ProvincesModel>(
                              value: originProvinces,
                              child: Text(
                                '${originProvinces.provinceType} ${originProvinces.provinceName}',
                                style: kTextStyle.copyWith(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedOriginProvince = value;
                          selectedOriginDistrict = null;
                          selectedOriginWard = null;
                        });
                        fetchDistricts(value?.provinceCode).then(
                          (value) {
                            originDistricts = value;
                            setState(() {});
                          },
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    // Dropdown for selecting district
                    DropdownButtonFormField2<DistrictsModel>(
                      isExpanded: true,
                      value: selectedOriginDistrict,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      hint: Text(
                        'Select District',
                        style: kTextStyle.copyWith(fontSize: 15),
                      ),
                      items: originDistricts
                          .map(
                            (originDistricts) =>
                                DropdownMenuItem<DistrictsModel>(
                              value: originDistricts,
                              child: Text(
                                '${originDistricts.districtType} ${originDistricts.districtName}',
                                style: kTextStyle.copyWith(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedOriginDistrict = value;
                          selectedOriginWard = null;
                        });
                        fetchWards(value?.districtCode).then((value) {
                          originWards = value;
                          setState(() {});
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    // Dropdown for selecting ward
                    DropdownButtonFormField2<WardsModel>(
                      isExpanded: true,
                      value: selectedOriginWard,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      hint: Text(
                        'Select Ward',
                        style: kTextStyle.copyWith(fontSize: 15),
                      ),
                      items: originWards
                          .map(
                            (originWards) => DropdownMenuItem<WardsModel>(
                              value: originWards,
                              child: Text(
                                '${originWards.wardType} ${originWards.wardName}',
                                style: kTextStyle.copyWith(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedOriginWard = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),

                    TextFormField(
                      controller: addressInPlaceOfOrigin,
                      style: kTextStyle.copyWith(
                          fontSize: 15, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Address',
                        labelStyle: kTextStyle,
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: 'Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Use the selected values to update your address or perform other actions
                    String completeAddress = buildOrigin();
                    print('Complete Address: $completeAddress');
                    placeOfOrigrin.text = completeAddress;

                    // Close the dialog
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String buildOrigin() {
    String selectedOriginProvinces =
        '${selectedOriginProvince?.provinceType ?? ''} ${selectedOriginProvince?.provinceName ?? ''}';
    String selectedOriginDistricts =
        '${selectedOriginDistrict?.districtType ?? ''} ${selectedOriginDistrict?.districtName ?? ''}';
    String selectedOriginWards =
        '${selectedOriginWard?.wardType ?? ''} ${selectedOriginWard?.wardName ?? ''}';
    String addressOriginText = addressInPlaceOfOrigin.text;

    String completeAddress =
        '$addressOriginText, $selectedOriginWards, $selectedOriginDistricts, $selectedOriginProvinces';

    return completeAddress;
  }

  Future<void> _selectedPlaceOfResidence() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Address'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField2<ProvincesModel>(
                      isExpanded: true,
                      value: selectedResidenceProvince,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      hint: Text(
                        'Select Province',
                        style: kTextStyle.copyWith(fontSize: 15),
                      ),
                      items: residenceProvinces
                          .map(
                            (residenceProvinces) =>
                                DropdownMenuItem<ProvincesModel>(
                              value: residenceProvinces,
                              child: Text(
                                '${residenceProvinces.provinceType} ${residenceProvinces.provinceName}',
                                style: kTextStyle.copyWith(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedResidenceProvince = value;
                          selectedResidenceDistrict = null;
                          selectedResidenceWard = null;
                        });
                        fetchDistricts(value?.provinceCode).then(
                          (value) {
                            residenceDistricts = value;
                            setState(() {});
                          },
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    // Dropdown for selecting district
                    DropdownButtonFormField2<DistrictsModel>(
                      isExpanded: true,
                      value: selectedResidenceDistrict,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      hint: Text(
                        'Select District',
                        style: kTextStyle.copyWith(fontSize: 15),
                      ),
                      items: residenceDistricts
                          .map(
                            (residenceDistricts) =>
                                DropdownMenuItem<DistrictsModel>(
                              value: residenceDistricts,
                              child: Text(
                                '${residenceDistricts.districtType} ${residenceDistricts.districtName}',
                                style: kTextStyle.copyWith(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedResidenceDistrict = value;
                          selectedResidenceWard = null;
                        });
                        fetchWards(value?.districtCode).then((value) {
                          residenceWards = value;
                          setState(() {});
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    // Dropdown for selecting ward
                    DropdownButtonFormField2<WardsModel>(
                      isExpanded: true,
                      value: selectedResidenceWard,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      hint: Text(
                        'Select Ward',
                        style: kTextStyle.copyWith(fontSize: 15),
                      ),
                      items: residenceWards
                          .map(
                            (residenceWards) => DropdownMenuItem<WardsModel>(
                              value: residenceWards,
                              child: Text(
                                '${residenceWards.wardType} ${residenceWards.wardName}',
                                style: kTextStyle.copyWith(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedResidenceWard = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),

                    TextFormField(
                      controller: addressInPlaceOfResidence,
                      style: kTextStyle.copyWith(
                          fontSize: 15, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Address',
                        labelStyle: kTextStyle,
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: 'Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Use the selected values to update your address or perform other actions
                    String completeAddress = buildResidence();
                    print('Complete Address: $completeAddress');
                    placeOfResidence.text = completeAddress;

                    // Close the dialog
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String buildResidence() {
    String selectedResidenceProvinces =
        '${selectedResidenceProvince?.provinceType ?? ''} ${selectedResidenceProvince?.provinceName ?? ''}';
    String selectedResidenceDistricts =
        '${selectedResidenceDistrict?.districtType ?? ''} ${selectedResidenceDistrict?.districtName ?? ''}';
    String selectedResidenceWards =
        '${selectedResidenceWard?.wardType ?? ''} ${selectedResidenceWard?.wardName ?? ''}';
    String addressResidenceText = addressInPlaceOfResidence.text;

    String completeAddress =
        '$addressResidenceText, $selectedResidenceProvinces, $selectedResidenceDistricts, $selectedResidenceWards';

    return completeAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Edit Profile Employee',
          maxLines: 2,
          style: kTextStyle.copyWith(
            color: kDarkWhite,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        // leading: IconButton(
        //   onPressed: () {
        //     widget.callBack(widget.employeeProfile);
        //   },
        //   icon: const Icon(Icons.arrow_back),
        // ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0)),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _pickImage();
                        },
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(widget.employeeProfile
                                  ?.employeeResponse?.profileImage ??
                              ''),
                          child: const Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomRight,
                                child: CircleAvatar(
                                  radius: 17,
                                  backgroundColor: kMainColor,
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: code,
                            style: kTextStyle.copyWith(
                                fontSize: 15, color: Colors.black),
                            readOnly: true,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 16, 10, 15),
                              labelText: 'Code',
                              labelStyle: kTextStyle,
                              hintStyle: kTextStyle.copyWith(fontSize: 15),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: (code) {
                              if (code == null || code.isEmpty) {
                                return 'Please Enter Code';
                              } else if (code.length <= 2 &&
                                  code.length >= 10) {
                                return 'Code must be 3 characters long';
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            readOnly: true,
                            controller: enrollmentDate,
                            style: kTextStyle.copyWith(
                                fontSize: 15, color: Colors.black),
                            // onTap: () async {
                            //   var date = await showDatePicker(
                            //       context: context,
                            //       initialDate: DateTime(2000),
                            //       firstDate: DateTime(1900),
                            //       lastDate: DateTime(2100));
                            //   if (date != null) {
                            //     dateOfBirth.text =
                            //         date.toString().substring(0, 10);
                            //   }
                            // },
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 16, 10, 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              suffixIcon: Icon(
                                Icons.date_range_rounded,
                                color: kGreyTextColor,
                              ),
                              labelText: 'EnrollmentDate',
                              labelStyle: kTextStyle,
                              hintStyle: kTextStyle.copyWith(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: name,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                    labelText: 'FullName',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (name) {
                    if (name == null || name.isEmpty) {
                      return 'Please Enter Employee Name';
                    } else if (name.length <= 2) {
                      return 'Name must be 3 characters long';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: phone,
                        style: kTextStyle.copyWith(
                            fontSize: 15, color: Colors.black),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                          labelText: 'Phone Number',
                          labelStyle: kTextStyle,
                          hintStyle: kTextStyle.copyWith(fontSize: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        validator: validateMobile,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: level,
                        style: kTextStyle.copyWith(
                            fontSize: 15, color: Colors.black),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                          labelText: 'Level',
                          labelStyle: kTextStyle,
                          hintStyle: kTextStyle.copyWith(fontSize: 15),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a level';
                          }

                          // Parse the input value as an integer
                          int? levelValue = int.tryParse(value);

                          // Check if the parsed value is less than 5
                          if (levelValue != null && levelValue <= 5) {
                            return null; // Validation passed
                          } else {
                            return 'Level must be a number less than or equal to 5';
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: email,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                    labelText: 'Email Address',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: validateEmail,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: currentAddress,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                    labelText: 'Address',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (address) {
                    if (address == null || address.isEmpty) {
                      return 'Enter Employee Address';
                    } else if (address.length <= 9) {
                      return 'Address must be 10 characters long';
                    }
                    return null;
                  },
                  onTap: () {
                    _selectedCurrentAddress();
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: citizenId,
                        style: kTextStyle.copyWith(
                            fontSize: 15, color: Colors.black),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                          labelText: 'CitizenId',
                          labelStyle: kTextStyle,
                          hintStyle: kTextStyle.copyWith(fontSize: 15),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (citizenId) {
                          if (citizenId == null || citizenId.isEmpty) {
                            return 'Enter ID CCDD';
                          } else if (citizenId.length <= 11) {
                            return 'ID CCDD must be 12 characters long';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: dateOfBirth,
                        style: kTextStyle.copyWith(
                            fontSize: 15, color: Colors.black),
                        onTap: () async {
                          var date = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100));
                          if (date != null) {
                            dateOfBirth.text = date.toString().substring(0, 10);
                          }
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: Icon(
                            Icons.date_range_rounded,
                            color: kGreyTextColor,
                          ),
                          labelText: 'Date Of Birth',
                          labelStyle: kTextStyle,
                          hintStyle: kTextStyle.copyWith(fontSize: 15),
                        ),
                        validator: validateDate,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: kTextStyle.copyWith(
                            fontSize: 15, color: Colors.black),
                        controller: nationality,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                          labelText: 'Nationality',
                          labelStyle: kTextStyle,
                          hintStyle: kTextStyle.copyWith(fontSize: 15),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (nationality) {
                          if (nationality == null || nationality.isEmpty) {
                            return 'Please Enter  Nationality';
                          } else if (nationality.length <= 3) {
                            return 'Nationality must have more than 3 characters';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Expanded(
                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        value: _selectedGender,
                        style: kTextStyle.copyWith(
                            fontSize: 15, color: Colors.black),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          labelText: 'Sex',
                        ),
                        hint: Text(
                          'Select Gender',
                          style: kTextStyle.copyWith(fontSize: 15),
                        ),
                        items: genderItems
                            .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
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
                    )
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: placeOfOrigrin,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                    labelText: 'PlaceOfOrigrin',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (placeOfOrigrin) {
                    if (placeOfOrigrin == null || placeOfOrigrin.isEmpty) {
                      return 'Please Enter PlaceOfOrigrin';
                    } else if (placeOfOrigrin.length <= 3) {
                      return 'PlaceOfOrigrin must have more than 4 characters';
                    }
                    return null;
                  },
                  onTap: () {
                    _selectedPlaceOfOrigin();
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: placeOfResidence,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                    labelText: 'PlaceOfResidence',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (placeOfResidence) {
                    if (placeOfResidence == null || placeOfResidence.isEmpty) {
                      return 'Please Enter PlaceOfResidence';
                    } else if (placeOfResidence.length <= 3) {
                      return 'PlaceOfResidence must have more than 4 characters';
                    }
                    return null;
                  },
                  onTap: () {
                    _selectedPlaceOfResidence();
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: dateOfIssue,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  onTap: () async {
                    var date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100));
                    if (date != null) {
                      dateOfIssue.text = date.toString().substring(0, 10);
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: const Icon(
                      Icons.date_range_rounded,
                      color: kGreyTextColor,
                    ),
                    labelText: 'Date Of Issue',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    // hintText: dateOfIssue.text,
                  ),
                  validator: (value) =>
                      validateDateIssue(value, dateOfBirth.text),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: issuedBy,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                    labelText: 'Issued By',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (issuedBy) {
                    if (issuedBy == null || issuedBy.isEmpty) {
                      return 'Enter Issued By';
                    } else if (issuedBy.length <= 3) {
                      return 'Issued By must have more than 3 characters';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ButtonGlobal(
                  buttontext: 'Update',
                  buttonDecoration:
                      kButtonDecoration.copyWith(color: kMainColor),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (code.text.isNotEmpty &&
                          name.text.isNotEmpty &&
                          phone.text.isNotEmpty &&
                          email.text.isNotEmpty &&
                          currentAddress.text.isNotEmpty &&
                          citizenId.text.isNotEmpty &&
                          dateOfBirth.text.isNotEmpty &&
                          nationality.text.isNotEmpty &&
                          placeOfOrigrin.text.isNotEmpty &&
                          placeOfResidence.text.isNotEmpty &&
                          dateOfIssue.text.isNotEmpty &&
                          issuedBy.text.isNotEmpty) {
                        var requestBodyEdit = {
                          "fullName": name.text,
                          "phone": phone.text,
                          "email": email.text,
                          "currentAddress": currentAddress.text,
                          "level": level.text,
                          "profileImage":
                              employeeProfile.employeeResponse?.profileImage,
                          "citizenId": citizenId.text,
                          "dateOfBirth": dateOfBirth.text,
                          "sex": _selectedGender,
                          "nationality": nationality.text,
                          "placeOfOrigrin": placeOfOrigrin.text,
                          "placeOfResidence": placeOfResidence.text,
                          "dateOfIssue": dateOfIssue.text,
                          "issuedBy": issuedBy.text,
                        };
                        employeeProfile.employeeResponse?.code = code.text;
                        employeeProfile.employeeResponse?.name = name.text;
                        employeeProfile.employeeResponse?.phone = phone.text;
                        employeeProfile.employeeResponse?.email = email.text;
                        employeeProfile.employeeResponse?.currentAddress =
                            currentAddress.text;
                        employeeProfile.employeeResponse?.level =
                            int.tryParse(level.text) ?? 0;

                        employeeProfile.employeeResponse?.profileImage =
                            employeeProfile.employeeResponse?.profileImage;
                        employeeProfile.employeeResponse?.citizenId =
                            citizenId.text;

                        employeeProfile.employeeResponse?.dateOfBirth =
                            DateTime.parse(dateOfBirth.text);
                        employeeProfile.employeeResponse?.sex = _selectedGender;
                        employeeProfile.employeeResponse?.nationality =
                            nationality.text;
                        employeeProfile.employeeResponse?.placeOfOrigrin =
                            placeOfOrigrin.text;
                        employeeProfile.employeeResponse?.placeOfResidence =
                            placeOfResidence.text;
                        employeeProfile.employeeResponse?.dateOfIssue =
                            DateTime.parse(dateOfIssue.text);
                        employeeProfile.employeeResponse?.issuedBy =
                            issuedBy.text;

                        try {
                          var response = await httpPut(
                              "/api/employee/hr-update-employee-information/${widget.id}",
                              requestBodyEdit);

                          print(response);
                          print(requestBodyEdit);

                          // ignore: use_build_context_synchronously
                          showToast(
                            context: context,
                            msg: "Update Successfully",
                            color: Color.fromARGB(255, 128, 249, 16),
                            icon: const Icon(Icons.done),
                          );

                          widget.callBack(widget.employeeProfile);
                          Navigator.pop(context);
                        } catch (e) {
                          print("Erorr update employee: $e");
                          // ignore: use_build_context_synchronously
                          showToast(
                            context: context,
                            msg: "Update Not Successfully :$e",
                            color: Colors.red,
                            icon: const Icon(Icons.error),
                          );
                          // widget.callBack(employeeProfile);
                        }
                      } else {
                        showToast(
                          context: context,
                          msg: "Need fill all blank",
                          color: Color.fromARGB(255, 255, 213, 149),
                          icon: const Icon(Icons.warning),
                        );
                      }
                    }
                  }, // thêm sự kiện cho button
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
