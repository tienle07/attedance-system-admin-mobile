// import 'package:flutter/material.dart';
// import 'package:staras_manager/model/employee/employee.profile.model.dart';
// import 'package:staras_manager/model/employee_model.dart';
// import 'package:staras_manager/view/Authentication/forgot_password.dart';
// import 'package:staras_manager/view/Authentication/phone_verification.dart';
// import 'package:staras_manager/view/Authentication/select_type.dart';
// import 'package:staras_manager/view/Authentication/sign_in_hr.dart';
// import 'package:staras_manager/view/HRManager/EmployeeManagement/add_employee.dart';
// import 'package:staras_manager/view/HRManager/EmployeeManagement/add_employee_success.dart';

// import 'package:staras_manager/view/HRManager/EmployeeManagement/employee_list.dart';
// import 'package:staras_manager/view/HRManager/EmployeeManagement/employee_management.dart';

// import 'package:staras_manager/view/HRManager/EmployeeManagement/send_account.dart';
// import 'package:staras_manager/view/HRManager/Home/home_screen_hr.dart';
// import 'package:staras_manager/view/HRManager/LeaveManagement/approve_leave_application.dart';
// import 'package:staras_manager/view/HRManager/LeaveManagement/leave_list_request.dart';
// import 'package:staras_manager/view/HRManager/LeaveManagement/leave_management.dart';
// import 'package:staras_manager/view/HRManager/NotiBoard/notice_details.dart';
// import 'package:staras_manager/view/HRManager/NotiBoard/notice_list.dart';
// import 'package:staras_manager/view/HRManager/Notification/notification_of_hr.dart';
// import 'package:staras_manager/view/HRManager/ProfileScreen/edit_profile_screen.dart';
// import 'package:staras_manager/view/HRManager/ProfileScreen/profile_hr_screen.dart';

// import 'package:staras_manager/view/HRManager/StoreManagement/list_all_store.dart';
// import 'package:staras_manager/view/HRManager/StoreManagement/store_management.dart';
// import 'package:staras_manager/view/HRManager/WorkScheduleOfEmployee/work_schedule.dart';
// import 'package:staras_manager/view/SplashScreen/on_board.dart';
// import 'package:staras_manager/view/SplashScreen/splash_screen.dart';

// List<Employee> employees = [];
// EmployeeProfile? employeeProfile;

// class AppRoutes {
//   static const String splashScreen = '/splash_screen';

//   static const String onboardingScreen = '/onboarding_screen';

//   static const String selectType = 'select_type';

//   static const String loginScreen = '/login_screen';

//   static const String forgotPasswordScreen = '/forgot_password_screen';

//   static const String phoneVerification = '/phone_verification_screen';

//   static const String homePage = '/home_page';

//   static const String employeeManagement = '/employee_management';

//   static const String employeeList = '/employee_list';

//   static const String employeeDetails = '/employee_details';

//   static const String editEmployee = '/edit_employee';

//   static const String addEmployee = '/add_employee';

//   static const String addEmployeeSuccess = '/add_employee_success';

//   static const String sendAccount = '/send_account';

//   static const String storeManagement = '/store_management';

//   static const String storeList = '/store_list';

//   static const String storeDetails = '/store_details';

//   static const String workSchedule = '/work_schedule_management';

//   static const String workScheduleOfEmployee = '/work_schedule_list_employee';

//   static const String leaveManagement = '/leave_management';

//   static const String leaveList = '/leave_list';

//   static const String leaveDetails = '/leave_details';

//   static const String approveApplication = '/approve_application';

//   static const String rejectApplication = '/reject_application';

//   static const String noticeBoard = '/notice_board';

//   static const String noticeList = '/notice_list';

//   static const String noticeDetails = '/notice_details';

//   static const String profileHrScreen = '/profile_Hr_screen';

//   static const String editProfileHr = '/edit_profile_Hr';

//   static const String changePassword = '/change_password';

//   static const String notificationOfHr = '/notification_of_Hr';

//   static Map<String, WidgetBuilder> routes = {
//     splashScreen: (context) => const SplashScreen(),
//     onboardingScreen: (context) => const OnBoard(),
//     selectType: (context) => const SelectType(),
//     loginScreen: (context) => const SignInHr(),
//     forgotPasswordScreen: (context) => const ForgotPassword(),
//     phoneVerification: (context) => const PhoneVerification(),
//     homePage: (context) => const HomeHrScreen(),
//     employeeManagement: (context) => const EmployeeManagement(),
//     employeeList: (context) => const EmployeeList(),
//     // employeeDetails: (context) => ProfileEmployeeScreen(
//     //       id: id,
//     //     ),
//     // editEmployee: (context) => const EditProfileEmployee(),
//     addEmployee: (context) => const AddNewEmployee(),
//     addEmployeeSuccess: (context) => const AddEmployeeSuccess(),
//     sendAccount: (context) => const SendAccount(),
//     storeManagement: (context) => const StoreManagement(),
//     storeList: (context) => const GetAllStore(),
//     // storeDetails: (context) => const DetailsStore(id: null),
//     workSchedule: (context) => const WorkSchedule(),
//     // workScheduleOfEmployee: (context) => const WorkScheduleOfEmployee(),
//     leaveManagement: (context) => const LeaveManagement(),
//     leaveList: (context) => const LeaveListRequest(),
//     // leaveDetails: (context) => const LeaveDetails(),
//     approveApplication: (context) => const ApproveLeaveApplication(),
//     // rejectApplication: (context) => const RejectApplication(),

//     noticeList: (context) => const NoticeList(),
//     noticeDetails: (context) => const NoticeDetails(),
//     profileHrScreen: (context) => const ProfileHrScreen(),
//     editProfileHr: (context) => const EditProfileHrScreen(),
//     // changePassword: (context) => const ChangePassword(),
//     notificationOfHr: (context) => const NNotificationHrScreen(),
//   };
// }
