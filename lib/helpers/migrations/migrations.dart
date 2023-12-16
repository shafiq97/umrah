import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

double safeDouble(dynamic value) {
  try {
    return double.parse(value);
  } catch (err) {
    return 0;
  }
}

void v1(Database database) async {
  debugPrint("Running first migration....");
  await database.execute("CREATE TABLE payments ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
      "title TEXT NULL, "
      "description TEXT NULL, "
      "account INTEGER,"
      "category INTEGER,"
      "amount REAL,"
      "type TEXT,"
      "datetime DATETIME"
      ")");

  await database.execute("CREATE TABLE categories ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
      "name TEXT,"
      "icon INTEGER,"
      "color INTEGER,"
      "budget REAL NULL, "
      "type TEXT"
      ")");

  await database.execute("CREATE TABLE accounts ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
      "name TEXT,"
      "holderName TEXT NULL, "
      "accountNumber TEXT NULL, "
      "icon INTEGER,"
      "color INTEGER,"
      "isDefault INTEGER"
      ")");
}

void v2(Database database) async {
  await database.execute('ALTER TABLE accounts ADD COLUMN income REAL');
}

void v3(Database database) async {
  await database.execute('ALTER TABLE accounts ADD COLUMN expense REAL');
}

void v4(Database database) async {
  await database.execute('ALTER TABLE accounts ADD COLUMN balance REAL');
  await database.execute('ALTER TABLE accounts ADD COLUMN amount REAL');
  await database.execute('ALTER TABLE accounts ADD COLUMN category String');
}

void v5(Database database) async {
  await database.execute('ALTER TABLE accounts ADD COLUMN description STRING');
}

void v6(Database database) async {
  await database.execute('ALTER TABLE accounts ADD COLUMN date STRING');
  await database.execute('ALTER TABLE accounts ADD COLUMN time STRING');
  await database.execute('ALTER TABLE accounts ADD COLUMN type STRING');
}

void v7(Database database) async {
  await database.execute('ALTER TABLE accounts ADD COLUMN goal REAL');
}
