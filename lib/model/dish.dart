import 'food.dart';

class Dish{
  // database primary key
  int id;
  DateTime dateTime;

  List<Food> foods;

  Dish(int id){
    this.id = id;
    foods = new List<Food>();
    dateTime = DateTime.now();
  }

  Map<String, dynamic> toMap(){
    return {
      'date': dateTime.toString().substring(0,10)
    };
  }

  double getEnergy(){
    double energy = 0;
    foods.forEach((food) {
      energy += food.getEnergy();
    });
    return energy;
  }
  double getCarbs(){
    double sum = 0;
    foods.forEach((food) {
      sum += food.getCarbs();
    });
    return sum;
  }
  double getFat(){
    double sum = 0;
    foods.forEach((food) {
      sum += food.getFat();
    });
    return sum;
  }
  double getProtein(){
    double sum = 0;
    foods.forEach((food) {
      sum += food.getProtein();
    });
    return sum;
  }
}