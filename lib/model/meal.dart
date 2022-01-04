import 'dish.dart';

class Meal{
  final String name;
  Dish dish;

  Meal(this.name) : this.dish = new Dish(0);
}