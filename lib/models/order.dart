import 'package:sqflite/sqflite.dart';

enum Status {
  pending,
  inProgress,
  done
}

extension StatusEx on Status{
  // returns a presentable string
  String asString(){
    switch (this){
      case Status.pending:
        return 'Pending';
      case Status.inProgress:
        return 'In Progess';
      case Status.done:
        return 'Done';
    }
  }
  int asInt(){
    switch (this){
      case Status.pending:
        return 1;
      case Status.inProgress:
        return 0;
      case Status.done:
        return 2;
    }
  }
}

class Order {
  int id;
  String name;
  Status status;
  DateTime? dueDate;
  List<String>? myIngredients;
  double? costs;
  double? margin;
  double? sellingPrice;


  Order(this.id, this.name,{ this.status = Status.pending, this.dueDate, this.myIngredients, this.costs, this.margin, this.sellingPrice});

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