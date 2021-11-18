import 'package:flutter/material.dart';
import 'package:bakers_buddy/models/order.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatefulWidget {
  final bool isModifiable;
  final FormFieldState formFieldState;

  const DatePicker({
    Key? key,
    required this.formFieldState,
    this.isModifiable = false
  }) : super(key: key);

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  bool _isModifiable = false;
  final TextEditingController _textCtr = TextEditingController();
  late FormFieldState _formFieldState;

  @override
  void initState() {
    super.initState();
    _isModifiable = widget.isModifiable;
    _formFieldState = widget.formFieldState;
    if (_formFieldState.value != null){
      _textCtr.text = DateFormat.yMd().format(_formFieldState.value.toLocal());
    }
  }

  @override
  void dispose() {
    _textCtr.dispose();
    super.dispose();
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

  void _pickDate() {
    // if not modifiable do nothing
    if (!_isModifiable) return;
    // let user pink date
    final Future<DateTime?> pickedDate = showDatePicker(
        context: context,
        initialDate: _formFieldState.value ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2101));

    // if picked and not null, update accordingly
    pickedDate.then((value) {
      if (value != null) {
        _formFieldState.didChange(value);
        _textCtr.text = DateFormat.yMd().format(_formFieldState.value.toLocal());
      }
    });
  }

  void setModifiable(bool isModifiable){
    setState(() {
      _isModifiable = isModifiable;
    });
  }

  DateTime? getDateTime(){
    return _formFieldState.value;
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
  late bool _isModifiable;
  late final TextEditingController _nameTextCtr;
  late final TextEditingController _marginTextCtr;
  late final TextEditingController _sellingPriceTextCtr;
  final _numberFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]'));
  late Status _orderStatus = Status.pending;
  final _datePickerKey = GlobalKey<_DatePickerState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    //
    super.initState();
    // init textCtr
    _nameTextCtr = TextEditingController();
    _marginTextCtr = TextEditingController();
    _sellingPriceTextCtr = TextEditingController();
    
    // init values from widget
    _isModifiable = widget.isModifiable;
    _nameTextCtr.text = widget.myOrder.name;
    _orderStatus = widget.myOrder.status;
    if (widget.myOrder.margin != null) {
      _marginTextCtr.text = widget.myOrder.margin.toString();
    }
    if (widget.myOrder.sellingPrice != null) {
      _sellingPriceTextCtr.text = widget.myOrder.sellingPrice.toString();
    }
  }

  @override
  void dispose() {
    _marginTextCtr.dispose();
    _sellingPriceTextCtr.dispose();
    _nameTextCtr.dispose();
    //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              wrapWidgetWithLabel(
                'Name',
                TextFormField(
                controller: _nameTextCtr,
                readOnly: !_isModifiable,
                ),
              ),
              wrapWidgetWithLabel(
                'Status',
                DropdownButton<Status>(
                  //initial value
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
              wrapWidgetWithLabel(
                'Due Date',
                FormField<DateTime>(
                  initialValue: widget.myOrder.dueDate,
                  builder: (FormFieldState<DateTime> state){
                    return DatePicker(
                      key: _datePickerKey,
                      formFieldState: state,
                      isModifiable: _isModifiable,
                    );
                  }
                )
              ),
              wrapWidgetWithLabel(
                'Margin',
                TextFormField(
                  controller: _marginTextCtr,
                  readOnly: !_isModifiable,
                  inputFormatters: [_numberFormatter],
                )
              ),
              wrapWidgetWithLabel(
                'Selling Price',
                TextFormField(
                  controller: _sellingPriceTextCtr,
                  readOnly: !_isModifiable,
                  inputFormatters: [_numberFormatter],
                )
              ),
              // bottom buttons
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 10)  ,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildBottomButtons(),
                ),
              )
            ],
          )
        )
      )
    );
  }

  List<Widget> _buildBottomButtons(){
    Widget saveOrEdit;
    Widget cancel;
    // build Save / Edit button, depending on iSModifiable
    if (_isModifiable){
      saveOrEdit = TextButton(onPressed: _returnOrder,child: const Text('Save'));
    } else{
      saveOrEdit = TextButton(onPressed: _editOrder,child: const Text('Edit'));
    }
    cancel = TextButton(onPressed: _cancelOrder, child: const Text('Cancel'));
    return <Widget>[saveOrEdit, cancel];
  }

  void _setModifiable(bool isModifiable){
    setState(() {
      _isModifiable = isModifiable;
      // notify stateful wdigets to update
      _datePickerKey.currentState?.setModifiable(isModifiable);
    });
  }

  String? _validateName(String? name) {
    // TODO: implement validation
    return null;
  }
  String? _validateMargin(String? name) {
    // TODO: implement validation
    return null;
  }
  String? _validateSellingPrice(String? name) {
    // TODO: implement validation
    return null;
  }

  void _returnOrder() {
    final result = Order(
      widget.myOrder.id, 
      _nameTextCtr.text,
      status: _orderStatus,
      dueDate: _datePickerKey.currentState?.getDateTime(),
      margin: double.tryParse(_marginTextCtr.text),
      sellingPrice: double.tryParse(_sellingPriceTextCtr.text));
    Navigator.pop(context, result);
  }

  void _cancelOrder(){
    if(_isModifiable && widget.myOrder.id != 0){
      _setModifiable(false);
    } else {
      // if myOrder is is 0, means its new, cancel will
      //  close page
      Navigator.pop(context, null);
    }
  }

  void _editOrder(){
    _setModifiable(true);
  }
}

Widget wrapWidgetWithLabel(String label, Widget widget, {bool isVertical = true}){
  Widget rowOrColumn;
  if (isVertical){
    rowOrColumn = Column(
      children: [
        Container(child: Text(label)), 
        widget
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }else{
    rowOrColumn = Row(
      children: [
        Container(margin: EdgeInsets.only(right: 40),child: Text(label)), 
        widget
      ])
    ;
  }
  return Container(
    child: rowOrColumn,
    margin: EdgeInsets.fromLTRB(0, 20, 0, 20),);
}