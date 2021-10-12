import 'package:flutter/material.dart';
import 'package:bakers_buddy/models/order.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatefulWidget {
  final DateTime initialDate;
  final bool isModifiable;
  final TextEditingController controller;
  const DatePicker({
    Key? key,
    required this.initialDate,
    this.isModifiable = false,
    required this.controller,
  }) : super(key: key);

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  bool _isModifiable = false;
  DateTime _selectedDate = DateTime.now();
  TextEditingController _textCtr = TextEditingController();

  void _pickDate() {
    // if not modifiable do nothing
    if (!_isModifiable) return;
    // let user pink date
    final Future<DateTime?> pickedDate = showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2101));

    // if picked and not null, update accordingly
    pickedDate.then((value) {
      if (value != null) {
        _selectedDate = value;
        _textCtr.text = DateFormat.yMd().format(_selectedDate.toLocal());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _isModifiable = widget.isModifiable;
    _textCtr = widget.controller;
    _textCtr.text = DateFormat.yMd().format(_selectedDate.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    // text field and button to show date picker in one row
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: TextFormField(
            readOnly: true,
            controller: _textCtr,
          ),
        ),
        Expanded(
          child: GestureDetector(
              onTap: _pickDate, child: const Icon(Icons.arrow_downward)),
        ),
      ],
    );
  }
}

class DatePickerWithLabel extends StatelessWidget {
  final String label;
  final DateTime initialDate;
  final bool isModifiable;
  final TextEditingController controller;

  const DatePickerWithLabel({
    Key? key,
    required this.label,
    required this.initialDate,
    this.isModifiable = false,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        DatePicker(
          initialDate: initialDate,
          isModifiable: isModifiable, 
          controller: controller,
          )
      ], 
    );
  }
}

class TextFormFieldWithLabel extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isReadOnly;
  final List<TextInputFormatter>? inputFormatters;

  const TextFormFieldWithLabel({
    Key? key,
    required this.label,
    required this.controller,
    this.isReadOnly = true,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // a label and text field stacked on top of each other
    return Column(
      children: [
        Text(label),
        TextFormField(
          readOnly: isReadOnly,
          controller: controller,
          inputFormatters: inputFormatters,
        )
      ],
    );
  }
}

class OrderDetails extends StatefulWidget {
  final Order myOrder;
  final bool isModifiable;
  const OrderDetails(
      {Key? key, required this.myOrder, this.isModifiable = false})
      : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool _isModifiable = false;
  final _nameTextCtr = TextEditingController();
  final _dueDateTextCtr = TextEditingController();
  final _marginTextCtr = TextEditingController();
  final _sellingPriceTextCtr = TextEditingController();
  final _numberFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]'));

  void _validateFields() {
    // TODO: implement validation
  }

  void _returnOrder() {
    final result = Order(
      widget.myOrder.id, 
      _nameTextCtr.text,
      dueDate: DateFormat.yMd().parse(_dueDateTextCtr.text),
      margin: double.parse(_marginTextCtr.text),
      sellingPrice: double.parse(_sellingPriceTextCtr.text));
    Navigator.pop(context, result);
  }

  @override
  void initState() {
    //
    super.initState();
    // initialize fields from widget
    _isModifiable = widget.isModifiable;
    _nameTextCtr.text = widget.myOrder.name;
    if (widget.myOrder.dueDate != null) {
      _dueDateTextCtr.text = DateFormat.yMd().format(widget.myOrder.dueDate!);
    }
    if (widget.myOrder.margin != null) {
      _marginTextCtr.text = widget.myOrder.margin.toString();
    }
    if (widget.myOrder.sellingPrice != null) {
      _sellingPriceTextCtr.text = widget.myOrder.sellingPrice.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Oder Details'),
        ),
        body: Center(
            child: Column(children: [
          TextFormFieldWithLabel(
            label: 'Name',
            controller: _nameTextCtr,
            isReadOnly: !_isModifiable,
          ),
          DatePickerWithLabel(
            label: 'Due Date',
            initialDate: DateTime.now(),
            isModifiable: _isModifiable,
            controller: _dueDateTextCtr),
          TextFormFieldWithLabel(
            label: 'Margin',
            controller: _marginTextCtr,
            isReadOnly: !_isModifiable,
            inputFormatters: [_numberFormatter],
          ),
          TextFormFieldWithLabel(
            label: 'Selling Price',
            controller: _sellingPriceTextCtr,
            isReadOnly: !_isModifiable,
            inputFormatters: [_numberFormatter],
          ),
          TextButton(
            onPressed: _returnOrder,
            child: const Text('Save'),
          )
        ])));
  }
}
