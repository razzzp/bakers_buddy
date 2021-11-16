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
    // not called again when setState is called in the parrent widget
    // _isModifiable = widget.isModifiable;
    _textCtr = widget.controller;
    _textCtr.text = DateFormat.yMd().format(_selectedDate.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    //make sure to take latest value from widget
    _isModifiable = widget.isModifiable;
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

Widget attachLabelToWidget(String label, Widget widget, {bool isVertical = true}){
  if (isVertical){
    return Column(children: [Text(label), widget]);
  }else{
    return Row(children: [Text(label), widget]);
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
  Status _orderStatus = Status.pending;

  void _setModifiable(bool modifiable){
    setState(()=>_isModifiable = modifiable);
  }

  void _validateFields() {
    // TODO: implement validation
  }

  void _returnOrder() {
    final result = Order(
      widget.myOrder.id, 
      _nameTextCtr.text,
      status: _orderStatus,
      dueDate: DateFormat.yMd().parse(_dueDateTextCtr.text),
      margin: double.tryParse(_marginTextCtr.text),
      sellingPrice: double.tryParse(_sellingPriceTextCtr.text));
    Navigator.pop(context, result);
  }

  void _cancelOrder(){
    if(_isModifiable){
      _setModifiable(false);
    } else {
      Navigator.pop(context, null);
    }
  }

  void _editOrder(){
    _setModifiable(true);
  }

  @override
  void initState() {
    //
    super.initState();
    // initialize fields from widget
    _isModifiable = widget.isModifiable;
    _nameTextCtr.text = widget.myOrder.name;
    _orderStatus = widget.myOrder.status;
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
        title: const Text('Order Details'),
      ),
      body: Center(
        child: Column(children: [
          attachLabelToWidget(
            'Name',
            TextFormField(
            controller: _nameTextCtr,
            readOnly: !_isModifiable,
            ),
          ),
          attachLabelToWidget(
            'Status',
            DropdownButton<Status>(
            //initail value
              value: _orderStatus,
              //changes Status enums to a list of DropdownMenuItem<Status>
              items: Status.values.map<DropdownMenuItem<Status>>(
                (e) => DropdownMenuItem<Status>(value: e, child: Text(e.asString()))).toList(),
              // if not moidifiable set to null to disable
              onChanged: _isModifiable ? (curStatus) => {
                setState(()=>_orderStatus = curStatus ?? Status.pending)
              } : null,
            ),
            isVertical: false
          ),
          attachLabelToWidget(
            'Due Date',
            DatePicker(
              initialDate: DateTime.now(),
              controller: _dueDateTextCtr,
              isModifiable: _isModifiable,
            )
          ),
          attachLabelToWidget(
            'Margin',
            TextFormField(
              controller: _marginTextCtr,
              readOnly: !_isModifiable,
              inputFormatters: [_numberFormatter],
            )
          ),
          attachLabelToWidget(
            'Selling Price',
            TextFormField(
              controller: _sellingPriceTextCtr,
              readOnly: !_isModifiable,
              inputFormatters: [_numberFormatter],
            )
          ),
          Row(children: [
            // build Save / Edit button, depending on iSModifiable
            _isModifiable ? TextButton(onPressed: _returnOrder,child: const Text('Save'))
              : TextButton(onPressed: _editOrder,child: const Text('Edit')),              
            TextButton(onPressed: _cancelOrder, child: const Text('Cancel'))
          ],)
        ])
      )
    );
  }
}
