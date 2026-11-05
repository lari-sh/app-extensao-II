/// Canonical server-generated code; never derive one from a UUID.
bool isAnimalCode(String? value) =>
    value != null &&
    value.trim() == value &&
    value != 'A0000' &&
    RegExp(r'^A(?:[0-9]{4}|[1-9][0-9]{4,18})$').hasMatch(value);
