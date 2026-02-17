import 'package:flutter/material.dart';

class ContactReason {
  final IconData icon;
  final String text;
  final String value;

  ContactReason({
    required this.icon,
    required this.text,
    required this.value,
  });
}

class ContactReasons {
  // Car options
  static final List<ContactReason> carReasons = [
    ContactReason(
      icon: Icons.lightbulb_outline,
      text: 'The lights of this car is on.',
      value: 'lights_on',
    ),
    ContactReason(
      icon: Icons.no_crash_outlined,
      text: 'The car is in no parking.',
      value: 'no_parking',
    ),
    ContactReason(
      icon: Icons.local_shipping_outlined,
      text: 'The car is getting towed.',
      value: 'getting_towed',
    ),
    ContactReason(
      icon: Icons.window_outlined,
      text: 'The window or car is open.',
      value: 'window_open',
    ),
    ContactReason(
      icon: Icons.warning_amber_outlined,
      text: 'Something wrong with this car.',
      value: 'something_wrong',
    ),
  ];

  // Bike options
  static final List<ContactReason> bikeReasons = [
    ContactReason(
      icon: Icons.lightbulb_outline,
      text: 'Forgotten Lights / Keys in Bike.',
      value: 'lights_on',
    ),
    ContactReason(
      icon: Icons.no_crash_outlined,
      text: 'The motorcycle is in no parking.',
      value: 'no_parking',
    ),
    ContactReason(
      icon: Icons.local_shipping_outlined,
      text: 'The motorcycle is getting towed.',
      value: 'getting_towed',
    ),
    ContactReason(
      icon: Icons.warning_amber_outlined,
      text: 'Something wrong with motorcycle',
      value: 'something_wrong',
    ),
  ];

  // Door Tag options
  static final List<ContactReason> doorReasons = [
    ContactReason(
      icon: Icons.lightbulb_outline,
      text: 'Forgotten Lights / Keys in Bike.',
      value: 'lights_on',
    ),
    ContactReason(
      icon: Icons.no_crash_outlined,
      text: 'The motorcycle is in no parking.',
      value: 'no_parking',
    ),
    ContactReason(
      icon: Icons.local_shipping_outlined,
      text: 'The motorcycle is getting towed.',
      value: 'getting_towed',
    ),
    ContactReason(
      icon: Icons.warning_amber_outlined,
      text: 'Something wrong with motorcycle',
      value: 'something_wrong',
    ),
  ];

  // Get reasons by tag type
  static List<ContactReason> getReasonsByTagType(String tagTypeCode) {
    print("tagTypeCode: $tagTypeCode");
    switch (tagTypeCode.toLowerCase()) {
      case 'c':
        return carReasons;
      case 'b':
        return bikeReasons;
      case 'dr':
        return doorReasons;
      default:
        return carReasons;
    }
  }
}
