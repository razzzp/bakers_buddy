import 'package:bakers_buddy/models/orders_db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bakers_buddy/models/order.dart';
import 'package:bakers_buddy/routes/order_details.dart';


class OrdersPage extends StatefulWidget {
  static const ordersPageTitle = "Orders";
  
  const OrdersPage({ Key? key }) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin  {
  final _db = OrdersDB();
  final List<Tab> _orderTabs = <Tab>[
    const Tab(text: 'Preparing'),
    const Tab(text: 'Done')
  ];
  // mediates between TabBar and TabBarView
  late TabController _tabController;
  // global keys allows references to states/widgets later
  final GlobalKey<_OrdersListState> _preparingOrdersKey = GlobalKey<_OrdersListState>();
  final GlobalKey<_OrdersListState> _doneOrdersKey = GlobalKey<_OrdersListState>();
  late OrdersList _preparingOrders;
  late OrdersList _doneOrders;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _orderTabs.length, vsync: this);
    _preparingOrders = OrdersList(key: _preparingOrdersKey,statusFilters: const {Status.pending,Status.inProgress});
    _doneOrders = OrdersList(key:_doneOrdersKey, statusFilters: const {Status.done});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(OrdersPage.ordersPageTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: _orderTabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _preparingOrders,
          _doneOrders
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, semanticLabel: 'Add new order'),
        onPressed: _addNewOrder,
      ),
    );
  }

  void _addNewOrder() async {
    final Order? newOrder = await _navigateToOrderDetails(context, Order(0, 'New Order'), true);
      if(newOrder != null){
          _db.addOrder(newOrder);
          if (_tabController.index == 0){
            _preparingOrdersKey.currentState?.updateListFromDB();
          }else if (_tabController.index == 1){
            _doneOrdersKey.currentState?.updateListFromDB();
          }
      }
  }
}

class OrdersList extends StatefulWidget {

  const OrdersList({Key? key, required this.statusFilters}) : super(key: key);

  final Set<Status> statusFilters;

  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  List<Order> _orders = <Order>[];
  Set<Status> _statusFilters = {};
  final _db = OrdersDB();

  @override
  void initState() {
    super.initState();
    _statusFilters = widget.statusFilters;
    updateListFromDBWithoutSetState();
  }

  @override
  Widget build(BuildContext context) {
    return  ListView.builder(
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final Order curOrder = _orders[index];
        return _buildOrderCard(curOrder);
      },
    );
  }

  Widget _buildOrderCard(Order order){
    return ListTile(
      onTap: () => _viewOrModifyOrder(order),
      title: Card(
        margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
        child: 
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(order.name),
                margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                ),
              Text(order.status.asString())
            ],
          ),
        ),
    ));
  }

  // updates the local list of Orders
  // called after updating db
  void updateListFromDB(){
    setState(() {
      updateListFromDBWithoutSetState();
    });
  }

  void updateListFromDBWithoutSetState(){
    _orders.clear();
    _orders = _db.queryOrders(status: _statusFilters);
    //sort by status
    _orders.sort((orderA, orderB){
      return orderA.status.asInt().compareTo(orderB.status.asInt());
    });
  }

  OrdersList setStatusFilters(Set<Status> statusFilters){
    _statusFilters = statusFilters;
    updateListFromDB();
    return widget;
  }

  void _viewOrModifyOrder(Order order) async{
    final Order? newOrder = await _navigateToOrderDetails(context, order, false);
      if(newOrder != null){
          _db.updateOrder(newOrder.id, newOrder);
          updateListFromDB();
      }
  }
}

Future<Order?> _navigateToOrderDetails(BuildContext context, Order order, bool isModifiable, ) async {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => 
      OrderDetails(
        myOrder: order, 
        isModifiable: isModifiable
      )
    )
  );
}