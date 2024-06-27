// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/employee/employee.profile.model.dart';
import 'package:staras_manager/model/faceImage/employee.face.image.model.dart';
import 'package:staras_manager/common/toast.dart';

class FaceImageManagement extends StatefulWidget {
  final EmployeeProfile? employeeProfile;
  final int? employeeId;
  final String? code;
  const FaceImageManagement(
      {Key? key, this.employeeProfile, this.employeeId, this.code})
      : super(key: key);

  @override
  State<FaceImageManagement> createState() => _FaceImageManagementState();
}

class _FaceImageManagementState extends State<FaceImageManagement> {
  List<EmployeeFaceImageModel>? images = [];

  List<EmployeeFaceImageModel>? filteredImages;

  final ImagePicker imagePicker = ImagePicker();

  List<XFile> selectedImageFileList = [];

  List<File> _selectedImages = [];

  List<int> selectedImageIndices = [];

  String imageName = '';
  XFile? selectedImageUpdate;

  bool isUploading = false;

  bool isFiltering = false;
  int selectedFilter = -1;

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    fetchImageList();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
      fetchImageList();
    }
  }

  void clearImageList() {
    setState(() {
      selectedImageFileList.clear();
      selectedImageIndices.clear(); // Clear selected indices
    });
  }

  void resetDialogState() {
    setState(() {
      selectedImageUpdate = null;
      imageName = "";
    });
  }

  Future<void> fetchImageList() async {
    onLoading(context);
    var apiUrl = '$BASE_URL_FACE/get-list-employee-faces/${widget.employeeId}';
    print(apiUrl);

    final String? accessToken = await readAccessToken();

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      Navigator.pop(context);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(responseData);
        print(apiUrl);
        if (responseData.containsKey('Data')) {
          final List<dynamic> imageData = responseData['Data'];

          final List<EmployeeFaceImageModel> imagesList = imageData
              .map((json) => EmployeeFaceImageModel.fromJson(json))
              .toList();

          setState(() {
            images = imagesList;
          });
        } else {
          print(
              'API Error: Response does not contain the expected data structure.');
        }
      } else if (response.statusCode == 404) {
        setState(() {
          images = [];
        });
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> deactivateImages() async {
    onLoading(context);
    List<EmployeeFaceImageModel>? displayImages =
        isFiltering ? filteredImages : images;

    if (selectedImageIndices.isEmpty || displayImages == null) {
      return;
    }

    List<int> selectedImageIds = selectedImageIndices
        .map((index) => displayImages[index].employeeFaceId!)
        .toList();

    final String apiUrl = '$BASE_URL_FACE/update-list-employee-face-mode';
    final String? accessToken = await readAccessToken();

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'ListEmployeeFaceId': selectedImageIds,
          'EmployeeId': widget.employeeId,
        }),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        print('Images deactivated successfully');
        showToast(
          context: context,
          msg: "Update Mode Image Successfully ",
          color: Color.fromARGB(255, 128, 249, 16),
          icon: const Icon(Icons.done),
        );
        fetchImageList();
        clearImageList();
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> showDeactivateConfirmationDialog(
      List<int> selectedImageIndices) async {
    List<EmployeeFaceImageModel>? displayImages =
        isFiltering ? filteredImages : images;
    if (selectedImageIndices.isEmpty || displayImages == null) {
      return;
    }

    int numberOfSelectedImages = selectedImageIndices.length;
    String imageNumberText = numberOfSelectedImages == 1 ? 'image' : 'images';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Are you sure?',
            style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Deactivate $numberOfSelectedImages $imageNumberText:',
                  style: kTextStyle.copyWith(fontSize: 15),
                ),
                SizedBox(height: 20),
                Container(
                  height: 300, // Adjust the height as needed
                  child: PhotoViewGallery.builder(
                    itemCount: selectedImageIndices.length,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: MemoryImage(
                          base64.decode(
                              displayImages[selectedImageIndices[index]]
                                  .base64Image!),
                        ),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                      );
                    },
                    scrollPhysics: BouncingScrollPhysics(),
                    backgroundDecoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    pageController: PageController(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAlertColor,
                  ),
                  child: Text(
                    'No',
                    style: kTextStyle.copyWith(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    deactivateImages();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        kMainColor, // Background color for the "Yes" button
                  ),
                  child: Text(
                    'Yes',
                    style: kTextStyle.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Image? decodeBase64ToImage(String base64String) {
    try {
      print('Base64 string length: ${base64String.length}');

      final commaIndex = base64String.indexOf(',');
      if (commaIndex != -1) {
        base64String = base64String.substring(commaIndex + 1);
      }

      Uint8List bytes = base64.decode(base64String);

      return Image.memory(
        bytes,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          print('Error loading image from base64: $error');
          return Container(
            color: Colors.red,
            child: Center(
              child: Text('Failed to load image'),
            ),
          );
        },
      );
    } catch (e) {
      print('Error decoding base64 to image: $e');
      return null;
    }
  }

  Future<void> selectImages() async {
    // Check if the total number of images is 5
    if (images != null && images!.length == 5) {
      // Show an alert if the limit is reached
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cannot Select More Images',
              style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'You cannot select more images when the total number of images is 5. Please deactivate an image to continue selecting images.',
              style: kTextStyle.copyWith(fontSize: 15),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Pick new images
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        selectedImageFileList = [...selectedImageFileList, ...selectedImages];
      });
    }
  }

  Future<void> uploadImagesToFirebase() async {
    if (selectedImageFileList.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(color: kMainColor, width: 2.0),
            ),
            title: Text(
              'No Images Selected',
              style: kTextStyle.copyWith(),
            ),
            content: const Text('Please select images before uploading.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    int totalImageUpload = selectedImageFileList.length + (images?.length ?? 0);

    if (totalImageUpload > 5) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cannot Add Images',
              style: kTextStyle.copyWith(
                  fontWeight: FontWeight.bold, fontSize: 19),
            ),
            content: Text(
              'The maximum number of photos is 5. Please choose a number of photos plus the current number of photos that is not greater than 5.',
              style: kTextStyle.copyWith(fontSize: 15),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final FirebaseStorage storage = FirebaseStorage.instance;
    final String? empCode = widget.employeeProfile?.employeeResponse?.code;
    if (empCode == null || empCode.isEmpty) {
      print('Employee code is missing.');
      return;
    }

    for (int i = 0; i < selectedImageFileList.length; i++) {
      final Reference ref = storage.ref().child('Images/$empCode/$i.jpg');

      final File file = File(selectedImageFileList[i].path);

      try {
        setState(() {
          isUploading = true;
        });
        await ref.putFile(file);
        // Get the download URL
        final String downloadURL = await ref.getDownloadURL();
        print('Image $i uploaded successfully. URL: $downloadURL');
        print('Image $i uploaded successfully');
      } catch (e) {
        print('Error uploading image $i: $e');
      }
    }
    setState(() {
      isUploading = false;
    });
    PostDataFaceImage();
    clearImageList();
    fetchImageList();
  }

  Future<void> PostDataFaceImage() async {
    onLoading(context);
    var apiUrl = '$BASE_URL_FACE/add-face-create';
    final String? accessToken = await readAccessToken();

    final String? employeeCode = widget.employeeProfile?.employeeResponse?.code;

    final Map<String, dynamic> requestBody = {
      'EmployeeId': widget.employeeId,
      'Code': employeeCode,
    };

    print('Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      Navigator.pop(context);
      if (response.statusCode >= 400 && response.statusCode <= 500) {
        print('API Error: ${response.statusCode}, ${response.body}');
        showToast(
          context: context,
          msg: response.body,
          color: Colors.red,
          icon: const Icon(Icons.error),
        );
      } else if (response.statusCode == 201) {
        print('Add Face successfully');
        showToast(
          context: context,
          msg: 'Add  successfully',
          color: Color.fromARGB(255, 128, 249, 16),
          icon: const Icon(Icons.done),
        );
        fetchImageList();
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
        showToast(
          context: context,
          msg: " Not Successfully ",
          color: Colors.red,
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> updateImages(List<int> selectedImageIndices) async {
    if (selectedImageIndices.length > 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cannot Update',
              style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Only 1 photo can be uploaded.',
              style: kTextStyle.copyWith(fontSize: 15),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
  }

  void _showImageDialog(BuildContext context, Image decodedImage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: decodedImage,
              ),
              Positioned(
                top: 12,
                right: 12,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNoImageSelectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'No Image Selected',
            style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Please select images before deactivating.',
            style: kTextStyle,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<EmployeeFaceImageModel>? displayImages =
        isFiltering ? filteredImages : images;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Employee Face',
          maxLines: 2,
          style: kTextStyle.copyWith(
            color: kDarkWhite,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CircleAvatar(
                        radius: 60.0,
                        backgroundImage: NetworkImage(
                          widget.employeeProfile?.employeeResponse
                                  ?.profileImage ??
                              "",
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 16, 10, 15),
                              labelText: 'Code',
                              labelStyle: kTextStyle,
                              hintStyle: kTextStyle.copyWith(fontSize: 15),
                              hintText: widget.employeeProfile?.employeeResponse
                                      ?.code ??
                                  "",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 16, 10, 15),
                              labelText: 'Name',
                              labelStyle: kTextStyle,
                              hintStyle: kTextStyle.copyWith(fontSize: 15),
                              hintText: widget.employeeProfile?.employeeResponse
                                      ?.name ??
                                  "",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                          ),
                          // buildInfoField('Code',
                          //     widget.employeeProfile?.employeeResponse?.code),
                          // const SizedBox(height: 10.0),
                          // buildInfoField('Name',
                          //     widget.employeeProfile?.employeeResponse?.name),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Container(
                      height: 60,
                      width: 170,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            15.0), // Set your desired border-radius
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: kMainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15.0), // Set your desired border-radius
                          ),
                        ),
                        onPressed: () {
                          selectImages();
                        },
                        // splashColor: Colors.redAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image), // Icon "add"
                            SizedBox(width: 8.0),
                            Text(
                              "Select Images",
                              style: kTextStyle.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: kWhiteTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Container(
                      height: 60,
                      width: 170,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: kMainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onPressed:
                            isUploading ? null : () => uploadImagesToFirebase(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons
                                .add_photo_alternate_outlined), // Icon "add"
                            SizedBox(
                                width:
                                    8.0), // Khoảng cách giữa biểu tượng và văn bản
                            Text(
                              "Add Images",
                              style: kTextStyle.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: kWhiteTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                if (selectedImageFileList.isNotEmpty)
                  Container(
                    height: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedImageFileList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(
                                        File(selectedImageFileList[index].path),
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: EdgeInsets.all(5),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          size: 25,
                                          weight: 30.0,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selectedImageFileList
                                                .removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                          child: Text(
                            "Please click button Add Image",
                            style: kTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (displayImages != null && displayImages.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemCount: displayImages.length,
                        itemBuilder: (BuildContext context, int index) {
                          Image? decodedImage = decodeBase64ToImage(
                              displayImages[index].base64Image ?? '');

                          if (decodedImage != null) {
                            bool isMode0 = displayImages[index].mode == 0;

                            return GestureDetector(
                              onTap: () {
                                _showImageDialog(context, decodedImage);
                              },
                              onLongPress: () {
                                setState(() {
                                  if (selectedImageIndices.contains(index)) {
                                    selectedImageIndices.remove(index);
                                  } else {
                                    selectedImageIndices.add(index);
                                  }
                                });
                              },
                              child: Opacity(
                                opacity: isMode0
                                    ? 0.1
                                    : 1.0, // Set opacity based on mode
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          selectedImageIndices.contains(index)
                                              ? Colors.red
                                              : kMainColor,
                                      width:
                                          selectedImageIndices.contains(index)
                                              ? 2.0
                                              : 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: decodedImage,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              color: Colors.red,
                              child: Center(
                                child:
                                    Text('Invalid Image Data at index $index'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: [
                const SizedBox(width: 16.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: kMainColor,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      if (selectedImageIndices.length > 1) {
                        // Show alert for more than one photo selected
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Error',
                                style: kTextStyle.copyWith(
                                    fontWeight: FontWeight.bold),
                              ),
                              content: Text(
                                'Only 1 photo can be uploaded.',
                                style: kTextStyle.copyWith(fontSize: 15),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (selectedImageIndices.isEmpty) {
                        // Show alert for no photo selected
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'No Images Selected.',
                                style: kTextStyle.copyWith(
                                    fontWeight: FontWeight.bold),
                              ),
                              content: Text(
                                'Please select one image before Update.',
                                style: kTextStyle.copyWith(fontSize: 15),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        showUpdateImageDialog(context);
                      }
                    },
                    color: kMainColor,
                    minWidth: 80,
                    height: 50,
                    child: Icon(
                      Icons.create_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: kMainColor,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: MaterialButton(
                      onPressed: () {
                        if (selectedImageIndices.isEmpty) {
                          _showNoImageSelectedDialog();
                        } else {
                          showDeactivateConfirmationDialog(
                              selectedImageIndices);
                        }
                      },
                      color: kMainColor,
                      minWidth: 80,
                      height: 50,
                      child: Icon(Icons.delete, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showUpdateImageDialog(BuildContext context) {
    void resetDialogState() {
      setState(() {
        selectedImageUpdate = null;
        imageName = "";
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                'Update Image',
                style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Text(
                      'Please select one image to Update.',
                      style: kTextStyle.copyWith(fontSize: 15),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        XFile? image = await getImage();
                        if (image != null) {
                          // Extract the file extension
                          String fileExtension = image.path.split('.').last;
                          // Remove the file extension from the image name
                          String imageNameWithoutExtension =
                              image.name!.replaceAll('.$fileExtension', '');

                          setState(() {
                            selectedImageUpdate = image;
                            imageName = imageNameWithoutExtension;
                          });
                        }
                      },
                      child: Text('Select Image'),
                    ),
                    SizedBox(height: 10),
                    if (selectedImageUpdate != null)
                      Image.file(
                        File(selectedImageUpdate!.path),
                        width: 100,
                        height: 130,
                        fit: BoxFit.cover,
                      ),
                    SizedBox(height: 10),
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          imageName = value;
                        });
                      },
                      // Update the TextFormField value with the selected image name
                      controller: TextEditingController(text: imageName),
                      decoration: InputDecoration(
                        labelText: 'Image Name',
                        labelStyle: kTextStyle,
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await uploadImageToFirebase(selectedImageUpdate, imageName);
                    Navigator.of(context).pop();
                  },
                  child: Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<XFile?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<void> UpdateFaceImage() async {
    onLoading(context);
    List<EmployeeFaceImageModel>? displayImages =
        isFiltering ? filteredImages : images;

    if (selectedImageIndices.isEmpty || displayImages == null) {
      return;
    }

    int selectedImageId =
        displayImages[selectedImageIndices.first].employeeFaceId!;

    var apiUrl = '$BASE_URL_FACE/update-employee-face-image';
    final String? employeeCode = widget.employeeProfile?.employeeResponse?.code;
    final String? accessToken = await readAccessToken();

    final Map<String, dynamic> requestBody = {
      "EmployeeFaceId": selectedImageId,
      "Code": employeeCode,
      "EmployeeId": widget.employeeId,
      "imageName": imageName,
    };

    print('Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );
      Navigator.pop(context);
      if (response.statusCode >= 400 && response.statusCode <= 500) {
        String errorMsg = response.body.length > 45
            ? '${response.body.substring(0, 42)}...'
            : response.body;
        // Show toast with request body
        showToast(
          context: context,
          msg: errorMsg,
          color: Colors.red, // You can choose an appropriate color for error
          icon: const Icon(Icons.error),
        );
      }
      if (response.statusCode == 200) {
        print('Update Images successfully');
        showToast(
          context: context,
          msg: "Update Image Successfully ",
          color: Color.fromARGB(255, 128, 249, 16),
          icon: const Icon(Icons.done),
        );
        fetchImageList();
        clearImageList();
        resetDialogState();
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> uploadImageToFirebase(XFile? image, String imageName) async {
    if (image == null) {
      return;
    }

    try {
      await Firebase.initializeApp();

      final String? empCode = widget.employeeProfile?.employeeResponse?.code;

      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('Images/$empCode/$imageName.jpg');

      await storageReference.putFile(File(image.path));

      String downloadURL = await storageReference.getDownloadURL();

      print('Image uploaded. Download URL: $downloadURL');
      UpdateFaceImage();
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Widget buildInfoField(String label, String? value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: kTextStyle.copyWith(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value ?? '',
          style: kTextStyle.copyWith(
            fontSize: 16.0,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
