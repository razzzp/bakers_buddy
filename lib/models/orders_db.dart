import 'dart:collection';

import 'package:flutter/cupertino.dart';

import './order.dart';

class OrdersDB {
  static final Map<int, Order> _orders = HashMap<int, Order>();
  Order addOrder(Order o){
    return _orders.putIfAbsent(o.id, () => o);
  }

  bool updateOrder(int id, Order order){
    _orders.update(id, (value) => order);
    return true;
  }

  Order? getOrder(int id){
    return _orders[id];
  }

  List<Order> getOrdersList(){
    return _orders.values.toList();
  }
}