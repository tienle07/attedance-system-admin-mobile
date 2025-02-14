import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/lms_model.dart';
import 'package:staras_manager/provider/data_provider.dart';

class NNotificationHrScreen extends StatefulWidget {
  const NNotificationHrScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NNotificationHrScreenState createState() => _NNotificationHrScreenState();
}

class _NNotificationHrScreenState extends State<NNotificationHrScreen> {
  // ignore: non_constant_identifier_names
  List<LMSModel> list_data = maanGetChatList();

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: kMainColor,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Notification',
            style: kTextStyle.copyWith(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Container(
                width: context.width(),
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0)),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Today',
                        style: kTextStyle.copyWith(
                            color: kTitleColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: list_data.map(
                        (data) {
                          return SettingItemWidget(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: data.title.validate(),
                            subTitle: '5 min ago',
                            leading: Image.network(data.image.validate(),
                                    height: 50, width: 50, fit: BoxFit.cover)
                                .cornerRadiusWithClipRRect(25),
                            trailing: Container(
                              height: 10.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                color: kMainColor,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            onTap: () {},
                          );
                        },
                      ).toList(),
                    ),
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
