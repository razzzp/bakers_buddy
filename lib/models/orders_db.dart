import 'dart:collection';

import 'package:flutter/cupertino.dart';

import './order.dart';

class OrdersDB {
  static final Map<int, Order> _orders = HashMap<int, Order>();
  static int _count = 0;

  Order addOrder(Order o){
    o.id = ++_count;
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

  List<Order> queryOrders({int? id, Set<Status>? status}){
    return _orders.values
                  .where((e) {
                    return (id!=null ? e.id==id : true)
                      && (status!=null ? status.contains(e.status) : true);  
                  })
                  .toList();
  }
}