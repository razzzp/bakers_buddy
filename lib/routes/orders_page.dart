import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bakers_buddy/models/order.dart';
import 'package:bakers_buddy/routes/order_details.dart';


class OrdersPage extends StatefulWidget {
  static const ordersPageTitle = "Orders";

  const OrdersPage({Key? key}) : super(key: key);
  
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _count = 0;
  final List<Order> _orders = <Order>[];
  
  Future<Order?> _navigateToOrderDetails(Order order, bool isModifiable) async {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => 
        OrderDetails(
          myOrder: order, 
          isModifiable: isModifiable))
    );
  }

  void _addNewOrder() async {
    final Order? newOrder = await _navigateToOrderDetails(Order(_count, 'New Order'), true);
    setState(() {
      if(newOrder != null){
        _orders.add(newOrder);
        _count++;
      }
    });
  }
  
  void _viewOrModifyOrder(Order order) async{
    final Order? newOrder = await _navigateToOrderDetails(order, false);
  }

  Widget _buildOrderCard(Order order){
    return ListTile(
      onTap: () => _viewOrModifyOrder(order),
      title: Card(
        child: Text(order.name),
        margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
    ));
  }

  Widget _buildOrdersList(){
    return ListView.builder(
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final Order curOrder = _orders[index];
        return _buildOrderCard(curOrder);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(OrdersPage.ordersPageTitle),
      ),
      body: _buildOrdersList(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, semanticLabel: 'Add new order'),
        onPressed: _addNewOrder,
      ),
    );
  }
}
