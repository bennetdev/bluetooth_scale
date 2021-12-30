
final String tableFood = 'foods';
final String columnId = '_id';
final String columnDishId = 'dish_id';
final String columnCode = 'code';
final String columnName = 'name';
final String columnEnergy = 'energy';
final String columnCarbs = 'carbs';
final String columnFat = 'fat';
final String columnProtein = 'protein';
final String columnAmount = 'amount';


class FoodDatabase{
  int id;

  int dish_id;
  String code;
  String name;
  int energy;
  double carbs;
  double fat;
  double protein;
  int amount;

  FoodDatabase();

  FoodDatabase.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    code = map[columnCode];
    dish_id = map[columnDishId];
    energy = map[columnEnergy];
    carbs = map[columnCarbs];
    protein = map[columnProtein];
    fat = map[columnFat];
    amount = map[columnAmount];
  }
}

class DishDatabase{
  int id;
  int meal_id;

  DishDatabase();
}