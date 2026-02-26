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

  // Door Tag options (reason codes: 1=Delivery, 2=Friend, 3=Security, 4=Neighbor, 5=Someone)
  static final List<ContactReason> doorReasons = [
    ContactReason(
      icon: Icons.local_shipping_outlined,
      text: 'I am here for delivery.',
      value: '1', // Delivery
    ),
    ContactReason(
      icon: Icons.people_outline,
      text: 'I am a friend visiting.',
      value: '2', // Friend
    ),
    ContactReason(
      icon: Icons.security_outlined,
      text: 'Security or building maintenance.',
      value: '3', // Security
    ),
    ContactReason(
      icon: Icons.home_outlined,
      text: 'I am a neighbor.',
      value: '4', // Neighbor
    ),
    ContactReason(
      icon: Icons.person_outline,
      text: 'Someone else.',
      value: '5', // Someone
    ),
  ];

  // Menu Tag (MT) options
  static final List<ContactReason> menuReasons = [
    ContactReason(
      icon: Icons.phone_outlined,
      text: 'I am lost',
      value: 'I am lost',
    ),
   
  ];

  // Business Tag (BS) options
  static final List<ContactReason> businessReasons = [
    ContactReason(
      icon: Icons.phone_outlined,
      text: 'Need to reach out',
      value: 'need_to_reach',
    ),
    ContactReason(
      icon: Icons.message_outlined,
      text: 'Want to send message',
      value: 'send_message',
    ),
    ContactReason(
      icon: Icons.info_outline,
      text: 'Need more information',
      value: 'need_info',
    ),
    ContactReason(
      icon: Icons.warning_amber_outlined,
      text: 'Other reason',
      value: 'other_reason',
    ),
  ];

  // Get reasons by tag type
  static List<ContactReason> getReasonsByTagType(String tagTypeCode) {
    print("tagTypeCode: $tagTypeCode");
    switch (tagTypeCode.toUpperCase()) {
      case 'C':
        return carReasons;
      case 'B':
        return bikeReasons;
      case 'DR':
        return doorReasons;
      case 'MT':
        return menuReasons;
      case 'BS':
        return businessReasons;
      default:
        return menuReasons;  // Default to generic reasons for unknown types
    }
  }

  // Check if tag type is a vehicle (car, bike, door)
  static bool isVehicleTag(String tagTypeCode) {
    return ['C', 'B', 'DR'].contains(tagTypeCode.toUpperCase());
  }
}
