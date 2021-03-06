class Food{
  //primary key for database
  int id;

  String isbn;
  String name;
  int energy;
  double carbs;
  double fat;
  double protein;
  int amount;

  Food(
    this.id,
    this.isbn,
    this.name,
    this.energy,
    this.carbs,
    this.fat,
    this.protein,
    this.amount
  );

  factory Food.fromJson(dynamic json, int amount){
    var product = json["product"];
    return Food(0,product["_id"], product["product_name"], product["nutriments"]["energy-kcal_100g"], product["nutriments"]["carbohydrates_100g"] + .0, product["nutriments"]["fat_100g"]+.0, product["nutriments"]["proteins_100g"]+.0, amount);
  }

  Map<String, dynamic> toMap(){
    return {
      'isbn': isbn,
      'name': name,
      'energy': energy,
      'carbs': carbs,
      'fat': fat,
      'protein': protein,
      'amount': amount
    };
  }

  double getCarbs(){
    return amount / 100 * carbs;
  }
  double getEnergy(){
    return amount / 100 * energy;
  }
  double getFat(){
    return amount / 100 * fat;
  }
  double getProtein(){
    return amount / 100 * protein;
  }

}
