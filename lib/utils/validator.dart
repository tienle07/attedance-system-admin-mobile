String? validateEmail(String? email) {
  RegExp emailRegex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  final isEmailValid = emailRegex.hasMatch(email ?? '');

  if (email!.isEmpty) {
    return 'Please enter email address';
  } else if (!isEmailValid) {
    return 'Email must follow type @gmail.com';
  }
  return null;
}

String? validateMobile(String? value) {
  String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
  RegExp regExp = new RegExp(pattern);
  if (value!.isEmpty) {
    return 'Please enter mobile number';
  } else if (!regExp.hasMatch(value)) {
    return 'Please enter a valid 10-digit mobile number';
  }
  return null;
}

String? validateGender(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please select Gender';
  }
}

String? validateDate(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please select Date Of Birth';
  }

  DateTime selectedDate = DateTime.parse(value);

  final now = DateTime.now();
  final age = now.year -
      selectedDate.year -
      ((now.month > selectedDate.month ||
              (now.month == selectedDate.month && now.day >= selectedDate.day))
          ? 0
          : 1);

  if (age < 18) {
    return 'Employee must be 18 years or older.';
  }

  return null;
}

String? validateDateIssue(String? value, String? dateOfBirth) {
  if (value == null || value.isEmpty) {
    return 'Please select date of issue.';
  }

  DateTime selectedDate = DateTime.parse(value);
  DateTime birthDate = DateTime.parse(dateOfBirth!);
  DateTime now = DateTime.now();

  // Calculate age at the time of date of issue
  final ageAtIssue = selectedDate.year -
      birthDate.year -
      ((selectedDate.month > birthDate.month ||
              (selectedDate.month == birthDate.month &&
                  selectedDate.day >= birthDate.day))
          ? 0
          : 1);

  if (selectedDate.isAfter(now)) {
    return 'Date of Issue cannot be greater than the current date.';
  }

  if (ageAtIssue < 18) {
    return 'Value must be 18 years from value date of birth.';
  }

  return null;
}
