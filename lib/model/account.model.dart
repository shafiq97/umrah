import 'package:flutter/material.dart';

class Account {
  int? id;
  String name;
  String holderName;
  String accountNumber;
  IconData icon;
  Color color;
  bool? isDefault;
  double? balance;
  double? income;
  double? expense;
  double? amount; // New field for amount
  String? category; // New field for category
  String? description; // New field for description
  DateTime? date; // Existing field for date
  TimeOfDay? time; // Existing field for time
  String? type; // Existing field for time
  double? goal;

  Account(
      {this.id,
      required this.name,
      required this.holderName,
      required this.accountNumber,
      required this.icon,
      required this.color,
      this.isDefault,
      this.income,
      this.expense,
      this.balance,
      this.amount, // Initialize amount
      this.category, // Initialize category
      this.description, // Initialize description
      this.date, // Initialize date
      this.time, // Initialize time
      this.type,
      this.goal});

  factory Account.fromJson(Map<String, dynamic> data) => Account(
      id: data["id"],
      name: data["name"],
      holderName: data["holderName"] ?? "",
      accountNumber: data["accountNumber"] ?? "",
      icon: IconData(data["icon"], fontFamily: 'MaterialIcons'),
      color: Color(data["color"]),
      isDefault: data["isDefault"] == 1,
      income: data["income"],
      expense: data["expense"],
      balance: data["balance"],
      amount: data["amount"], // Parse amount
      category: data["category"], // Parse category
      description: data["description"], // Parse description
      date: data["date"] != null
          ? DateTime.parse(data["date"])
          : null, // Parse date
      time: data["time"] != null
          ? TimeOfDay(
              hour: int.parse(data["time"].split(":")[0]),
              minute: int.parse(data["time"].split(":")[1]))
          : null, // Parse time
      type: data["type"],
      goal: data["goal"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "holderName": holderName,
        "accountNumber": accountNumber,
        "icon": icon.codePoint,
        "color": color.value,
        "isDefault": isDefault ?? false ? 1 : 0,
        "income": income,
        "expense": expense,
        "balance": balance,
        "amount": amount, // Convert amount to JSON
        "category": category, // Convert category to JSON
        "description": description, // Convert description to JSON
        "date": date?.toIso8601String(), // Convert date to string
        "time": time != null
            ? "${time!.hour}:${time!.minute}"
            : null, // Convert time to string
        "type": type,
        "goal": goal
      };
}
