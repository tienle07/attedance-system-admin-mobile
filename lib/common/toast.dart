import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:staras_manager/constants/constant.dart';

class ToastWidget extends StatelessWidget {
  final Color color;
  final Icon icon;
  final String msg;

  const ToastWidget({
    Key? key,
    required this.msg,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      constraints: BoxConstraints(
        maxWidth: screenWidth - 32.0, // Adjust the margin as needed
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: const Color.fromRGBO(255, 129, 130, 0.4)),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(
            width: 12.0,
          ),
          Flexible(
            child: Text(
              msg,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

void onLoading(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Processing...",
                style: kTextStyle.copyWith(color: Colors.black, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showToast(
    {required BuildContext context,
    required String msg,
    required Color color,
    required Icon icon,
    int? timeHint}) {
  FToast fToast = FToast();
  fToast.init(context);
  return fToast.showToast(
    //Đang m ắc
    child: ToastWidget(msg: msg, color: color, icon: icon),
    gravity: ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: timeHint ?? 4),
    positionedToastBuilder: (context, child) {
      return Positioned(
        child: child,
        top: 50.0,
        right: 20.0,
      );
    },
  );
}
