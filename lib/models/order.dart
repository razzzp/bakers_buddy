import 'package:sqflite/sqflite.dart';

class Order {
  int id;
  String name;
  DateTime? dueDate;
  List<String>? myIngredients;
  double? costs;
  double? margin;
  double? sellingPrice;


  Order(this.id, this.name, {this.dueDate, this.myIngredients, this.costs, this.margin, this.sellingPrice});
  
  factory Order.from(Order order){
    return Order(
      order.id,
      order.name,
      dueDate: order.dueDate!=null ? DateTime.fromMillisecondsSinceEpoch(order.dueDate!.millisecondsSinceEpoch) : null,
      myIngredients: order.myIngredients!=null ? List.from(order.myIngredients!): null,
      costs: order.costs,
      margin: order.margin,
      sellingPrice: order.sellingPrice,
    );
  }
}