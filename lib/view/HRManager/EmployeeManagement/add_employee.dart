// ignore_for_file: depend_on_referenced_packages, unused_field, use_build_context_synchronously, duplicate_ignore

import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staras_manager/common/toast.dart';
import 'package:staras_manager/components/button_global.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/address/districts.model.dart';
import 'package:staras_manager/model/address/provinces.model.dart';
import 'package:staras_manager/model/address/wards.model.dart';
import 'package:staras_manager/model/employee/employe.request.model.dart';
import 'package:staras_manager/model/employee/employee.profile.model.dart';
import 'package:staras_manager/utils/validator.dart';

class AddNewEmployee extends StatefulWidget {
  final Function()? onAddEmployeeSuccess;
  const AddNewEmployee({Key? key, this.onAddEmployeeSuccess}) : super(key: key);

  @override
  State<AddNewEmployee> createState() => _AddNewEmployeeState();
}

class _AddNewEmployeeState extends State<AddNewEmployee> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  EmployeeProfile? employeeProfile;
  XFile? _imageFile;
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

  EmployeeRequestModel requestModel = EmployeeRequestModel();

  TextEditingController fullName = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController currentAddress = TextEditingController();
  TextEditingController citizenId = TextEditingController();
  TextEditingController dateOfBirth = TextEditingController();
  TextEditingController sex = TextEditingController();
  TextEditingController nationality = TextEditingController();
  TextEditingController placeOfOrigrin = TextEditingController();
  TextEditingController placeOfResidence = TextEditingController();
  TextEditingController dateOfIssue = TextEditingController();
  TextEditingController issuedBy = TextEditingController();

  TextEditingController addressInDialog = TextEditingController();
  TextEditingController addressInPlaceOfOrigin = TextEditingController();
  TextEditingController addressInPlaceOfResidence = TextEditingController();

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
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
    }
  }

  void _saveForm() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
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
          requestModel.profileImage = downloadURL;
        });
      });
    }
  }

  String? _selectedGender;
  final List<String> genderItems = ['Male', 'Female'];

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
              title: Text(
                'Select Address',
                style: kTextStyle.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            'Create New Employee',
            maxLines: 2,
            style: kTextStyle.copyWith(
              color: kDarkWhite,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
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

                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: _imageFile == null
                        ? const CircleAvatar(
                            radius:
                                65, // Set the radius as per your requirements
                            backgroundImage:
                                AssetImage('images/employeeaddimage.png'),
                          )
                        : CircleAvatar(
                            radius: 70,
                            backgroundImage: FileImage(File(_imageFile!.path)),
                          ),
                  ),
                ),

                const SizedBox(
                  height: 40.0,
                ),
                //Text FOrm Fields
                TextFormField(
                  controller: fullName,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                    labelText: 'Employee Name',
                    hintText: 'Enter Employee Name',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (fullName) {
                    if (fullName == null || fullName.isEmpty) {
                      return 'Please Enter Employee Name';
                    } else if (fullName.length <= 2) {
                      return 'Please Enter Employee Name';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: phone,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                    labelText: 'Phone',
                    hintText: ' Enter Phone Number ',
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
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: email,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                    labelText: 'Email',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: 'Enter Email',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
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
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                    labelText: 'Address',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: 'Enter Employee Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onTap: () {
                    _selectedCurrentAddress();
                  },
                  validator: (address) {
                    if (address == null || address.isEmpty) {
                      return 'Enter Employee Address';
                    } else if (address.length <= 9) {
                      return 'Address must be 10 characters long';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: citizenId,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                    labelText: 'ID CCCD',
                    hintText: 'Enter ID CCCD',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (cccdId) {
                    if (cccdId == null || cccdId.isEmpty) {
                      return 'Enter ID CCCD';
                    } else if (cccdId.length != 12) {
                      return 'ID CCCD must be 12 characters long';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  readOnly: true,
                  onTap: () async {
                    var date = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2100));
                    if (date != null) {
                      dateOfBirth.text = date.toString().substring(0, 10);
                    }
                  },
                  controller: dateOfBirth,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Icon(
                      Icons.date_range_rounded,
                      color: kGreyTextColor,
                    ),
                    labelText: 'Date Of Birth',
                    hintText: 'Choose Date Of Birth',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                  ),
                  validator: validateDate,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20.0,
                ),

                DropdownButtonFormField2<String>(
                  isExpanded: true,
                  value: _selectedGender,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a gender';
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
                TextFormField(
                  controller: nationality,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                    labelText: 'Nationality',
                    hintText: 'Enter Nationality',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (cccdNationality) {
                    if (cccdNationality == null || cccdNationality.isEmpty) {
                      return 'Please Enter  Nationality';
                    } else if (cccdNationality.length <= 3) {
                      return 'Nationality must have more than 3 characters';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: placeOfOrigrin,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                    labelText: 'PlaceOfOrigin',
                    hintText: 'Enter PlaceOfOrigin',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onTap: () {
                    _selectedPlaceOfOrigin();
                  },
                  validator: (cccdPlaceOfOrigrin) {
                    if (cccdPlaceOfOrigrin == null ||
                        cccdPlaceOfOrigrin.isEmpty) {
                      return 'Please Enter PlaceOfOrigrin';
                    } else if (cccdPlaceOfOrigrin.length <= 3) {
                      return 'PlaceOfOrigrin must have more than 4 characters';
                    }
                    return null;
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
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                    labelText: 'PlaceOfResidence',
                    hintText: 'Enter PlaceOfResidence',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onTap: () {
                    _selectedPlaceOfResidence();
                  },
                  validator: (cccdPlaceOfResidence) {
                    if (cccdPlaceOfResidence == null ||
                        cccdPlaceOfResidence.isEmpty) {
                      return 'Please Enter PlaceOfResidence';
                    } else if (cccdPlaceOfResidence.length <= 3) {
                      return 'PlaceOfResidence must have more than 4 characters';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  readOnly: true,
                  onTap: () async {
                    var date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      dateOfIssue.text = date.toString().substring(0, 10);
                    }
                  },
                  controller: dateOfIssue,
                  style: kTextStyle.copyWith(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Icon(
                      Icons.date_range_rounded,
                      color: kGreyTextColor,
                    ),
                    labelText: 'Date Of Issue',
                    hintText: 'Choose Date Of Issue',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
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
                    contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                    labelText: 'Issued By',
                    hintText: 'Issued By',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (cccdIsuedBy) {
                    if (cccdIsuedBy == null || cccdIsuedBy.isEmpty) {
                      return 'Enter Issued By';
                    } else if (cccdIsuedBy.length <= 3) {
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
                  buttontext: 'Add Employee',
                  buttonDecoration:
                      kButtonDecoration.copyWith(color: kMainColor),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      requestModel = EmployeeRequestModel(
                        fullName: fullName.text,
                        phone: phone.text,
                        email: email.text,
                        currentAddress: buildAddress(),
                        profileImage: requestModel.profileImage,
                        level: 0,
                        citizenId: citizenId.text,
                        dateOfBirth: dateOfBirth.text,
                        sex: _selectedGender,
                        nationality: nationality.text,
                        placeOfOrigrin: buildOrigin(),
                        placeOfResidence: buildResidence(),
                        dateOfIssue: dateOfIssue.text,
                        issuedBy: issuedBy.text,
                      );

                      print(requestModel.toJson());
                      var response = await httpPost(
                          "/api/employee/hr-add-new-employee",
                          requestModel.toJson());

                      print(response);
                      var bodyResponse = jsonDecode(response['body']);

                      if (bodyResponse['code'] == 201) {
                        showToast(
                          context: context,
                          msg: "Add Employee Successfully",
                          color: Color.fromARGB(255, 128, 249, 16),
                          icon: const Icon(Icons.done),
                        );

                        widget.onAddEmployeeSuccess?.call();

                        Navigator.of(context).pop();
                      } else {
                        showToast(
                          context: context,
                          msg: "Add not success",
                          color: Colors.yellow,
                          icon: const Icon(Icons.warning),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
