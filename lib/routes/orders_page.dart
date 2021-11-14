import 'package:bakers_buddy/models/orders_db.dart';
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
  final db = OrdersDB();
  
  Future<Order?> _navigateToOrderDetails(Order order, bool isModifiable) async {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => 
        OrderDetails(
          myOrder: order, 
          isModifiable: isModifiable))
    );
  }

  // updates the local list of Orders
  // called after updating db
  void updateListFromDB(Order order){
    setState(() {
      bool orderFound = false;
      for (int i =0;i<_orders.length;i++){
        Order curOrder = _orders[i];
        if(curOrder.id == order.id){
          _orders[i] = order;
          orderFound= true;
        }
      }
      if (!orderFound){
        //means order just added
        // is this logic ok??
        _orders.add(order);
        _count++;
      }
    });
  }

  void _addNewOrder() async {
    final Order? newOrder = await _navigateToOrderDetails(Order(_count, 'New Order'), true);
      if(newOrder != null){
        db.addOrder(newOrder);
        updateListFromDB(newOrder);
      }
  }
  
  void _viewOrModifyOrder(Order order) async{
    final Order? newOrder = await _navigateToOrderDetails(order, false);
      if(newOrder != null){
        db.updateOrder(newOrder.id, newOrder);
        updateListFromDB(newOrder);
      }
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
