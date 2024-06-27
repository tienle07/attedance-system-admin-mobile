// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/view/Authentication/sign_in_hr.dart';
import 'package:staras_manager/view/Authentication/sign_in_store_manager.dart';

class SelectType extends StatefulWidget {
  const SelectType({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SelectTypeState createState() => _SelectTypeState();
}

class _SelectTypeState extends State<SelectType> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                const Image(
                  image: AssetImage("images/logo.png"),
                  width: 130,
                  height: 130,
                ),
                const SizedBox(
                  height: 80.0,
                ),
                const Image(image: AssetImage("images/people.png")),
                Text(
                  'Select Your Role',
                  style: kTextStyle.copyWith(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: kMainColor),
                      color: Colors.white,
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInHr(),
                          ),
                        );
                      },
                      leading: const Image(
                        image: AssetImage('images/owner.png'),
                      ),
                      title: Text(
                        'Business Owner HR',
                        style: kTextStyle.copyWith(fontSize: 14.0),
                      ),
                      subtitle: Text(
                        'Register your company & start attendance ',
                        style: kTextStyle.copyWith(
                            color: kGreyTextColor, fontSize: 12.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: kGreyTextColor),
                      color: Colors.white,
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInStoreManager(),
                          ),
                        );
                      },
                      leading: const Image(
                        image: AssetImage('images/employee.png'),
                      ),
                      title: Text(
                        'Store Manager',
                        style: kTextStyle.copyWith(fontSize: 14.0),
                      ),
                      subtitle: Text(
                        'Register and start marking attendance',
                        style: kTextStyle.copyWith(
                            color: kGreyTextColor, fontSize: 12.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
