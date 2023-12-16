import 'package:fintracker/dao/account_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/widgets/buttons/button.dart';
import 'package:flutter/material.dart';
import 'package:fintracker/data/icons.dart';
import 'package:intl/intl.dart';

typedef Callback = void Function();

class AccountForm extends StatefulWidget {
  final Account? account;

  final Callback? onSave;

  const AccountForm({super.key, this.account, this.onSave});

  @override
  State<StatefulWidget> createState() => _AccountForm();
}

class _AccountForm extends State<AccountForm> {
  final AccountDao _accountDao = AccountDao();
  Account? _account;
  DateTime selectedDate = DateTime.now();
  String? selectedAccountType; // To store the selected account type
  final List<String> accountTypes = [
    'Maybank',
    'Cimb',
    'Bank Islam',
    'Hong Leong',
    'Cash'
  ];
  @override
  void initState() {
    super.initState();
    selectedAccountType = widget.account?.type ?? accountTypes.first;
    if (widget.account != null) {
      _account = Account(
          id: widget.account!.id,
          name: widget.account!.name,
          holderName: widget.account!.holderName,
          accountNumber: widget.account!.accountNumber,
          icon: widget.account!.icon,
          color: widget.account!.color,
          amount: widget.account!.amount,
          category: widget.account!.category,
          description: widget.account!.description,
          date: widget.account!.date,
          goal: widget.account!.goal);
    } else {
      _account = Account(
          name: "",
          holderName: "",
          accountNumber: "",
          icon: Icons.account_circle,
          color: Colors.grey,
          date: DateTime.now(),
          amount: 0);
    }
  }

  void onSave(context) async {
    _account!.amount = _account!.amount ?? 0.0;
    _account!.category = _account!.category ?? 'Default Category';
    _account!.description = _account!.description ?? 'No Description';
    _account!.date = selectedDate;
    _account!.type = selectedAccountType ?? 'Cash';
    _account!.balance = _account!.amount ?? 0.0;
    _account!.goal = _account!.goal;
    await _accountDao.upsert(_account!);
    if (widget.onSave != null) {
      widget.onSave!();
    }
    Navigator.pop(context);
    globalEvent.emit("account_update");
  }

  void pickIcon(context) async {}
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      // Update the _account object with the new date
      _account!.date = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_account == null) {
      return const CircularProgressIndicator();
    }
    return AlertDialog(
      title: Text(
        widget.account != null ? "Edit Account" : "New Account",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      scrollable: true,
      insetPadding: const EdgeInsets.all(20),
      content: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              const SizedBox(
                height: 15,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: _account!.color,
                        borderRadius: BorderRadius.circular(40)),
                    alignment: Alignment.center,
                    child: Icon(
                      _account!.icon,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                      child: TextFormField(
                    initialValue: _account!.name,
                    decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'Title',
                        filled: true,
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 15)),
                    onChanged: (String text) {
                      setState(() {
                        _account!.name = text;
                      });
                    },
                  ))
                ],
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 20, top: 20),
                child: DropdownButtonFormField<String>(
                  value: selectedAccountType,
                  decoration: InputDecoration(
                    labelText: 'Select Account',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  items: accountTypes
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedAccountType = newValue;
                    });
                    _account!.type = newValue;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 20, top: 20),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Holder name',
                      hintText: 'Enter account holder name',
                      filled: true,
                      border: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 15)),
                  initialValue: _account!.holderName,
                  onChanged: (text) {
                    setState(() {
                      _account!.holderName = text;
                    });
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.only(
                  bottom: 20,
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'A/C Number',
                      hintText: 'Enter account number',
                      filled: true,
                      border: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 15)),
                  initialValue: _account!.accountNumber,
                  onChanged: (text) {
                    setState(() {
                      _account!.accountNumber = text;
                    });
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter amount',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true), // Set keyboard type for decimal numbers
                  initialValue:
                      _account!.amount?.toString() ?? '', // Handle null value
                  onChanged: (text) {
                    setState(() {
                      _account!.amount =
                          double.tryParse(text); // Convert text to double
                    });
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Goal',
                    hintText: 'Enter amount',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true), // Set keyboard type for decimal numbers
                  initialValue:
                      _account!.goal?.toString() ?? '', // Handle null value
                  onChanged: (text) {
                    setState(() {
                      _account!.goal =
                          double.tryParse(text); // Convert text to double
                    });
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Select Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(DateFormat('yyyy-MM-dd')
                            .format(selectedDate)), // Display the selected date
                        const Icon(Icons.calendar_today), // Calendar icon
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'Enter category',
                    // ... other decoration properties ...
                  ),
                  initialValue: _account!
                      .category, // Assuming 'category' is added to the Account model
                  onChanged: (text) {
                    setState(() {
                      _account!.category = text;
                    });
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter description',
                    // ... other decoration properties ...
                  ),
                  initialValue: _account!
                      .description, // Assuming 'description' is added to the Account model
                  onChanged: (text) {
                    setState(() {
                      _account!.description = text;
                    });
                  },
                ),
              ),
              //Color picker
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: Colors.primaries.length,
                    itemBuilder: (BuildContext context, index) => Container(
                          width: 45,
                          height: 45,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2.5, vertical: 2.5),
                          child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _account!.color = Colors.primaries[index];
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.primaries[index],
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(
                                      width: 2,
                                      color: _account!.color.value ==
                                              Colors.primaries[index].value
                                          ? Colors.white
                                          : Colors.transparent,
                                    )),
                              )),
                        )),
              ),
              const SizedBox(
                height: 5,
              ),

              //Icon picker
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppIcons.icons.length,
                    itemBuilder: (BuildContext context, index) => Container(
                        width: 45,
                        height: 45,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2.5, vertical: 2.5),
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _account!.icon = AppIcons.icons[index];
                              });
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                      color: _account!.icon ==
                                              AppIcons.icons[index]
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.transparent,
                                      width: 2)),
                              child: Icon(
                                AppIcons.icons[index],
                                color: Theme.of(context).colorScheme.primary,
                                size: 18,
                              ),
                            )))),
              ),
            ],
          )),
      actions: [
        AppButton(
          height: 45,
          isFullWidth: true,
          onPressed: () {
            onSave(context);
          },
          color: Theme.of(context).colorScheme.primary,
          label: "Save",
        )
      ],
    );
  }
}
