import 'food.dart';

class Dish{
  List<Food> foods;

  Dish(){
    foods = new List<Food>();
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