import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dish.dart';
import 'food.dart';

class DatabaseHelper{

  final String _databaseName = "scale1.db";
  final int _databaseVersion = 1;
  Database _database;

  DatabaseHelper();

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await connect();
    return _database;
  }

  connect() async{
    return await openDatabase(
      join(await getDatabasesPath(), _databaseName), version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade
    );
  }

  _onUpgrade(Database db, int oldVersion, int newVersion){
    if(oldVersion < newVersion){
      //db.execute("ALTER TABLE food ADD COLUMN dish_id INTEGER;");
    }
  }

  Future _onCreate(Database db, int version) async{
    await db.execute('''
                      CREATE TABLE dishes (
                        id INTEGER PRIMARY KEY,
                        meal INTEGER,
                        date TEXT
                      )
                     ''');
    await db.execute('''
                      CREATE TABLE food (
                        id INTEGER PRIMARY KEY,
                        dish_id INTEGER,
                        isbn TEXT,
                        name TEXT,
                        energy INTEGER,
                        carbs FLOAT,
                        FAT FLOAT,
                        protein FLOAT,
                        amount INTEGER
                      )
                     ''');
  }

  Future<int> insertDish(Dish dish) async{
    Database db = await database;
    int id = await db.insert("dishes", dish.toMap());
    return id;
  }
  Future insertFood(Food food, int dishId) async{
    Database db = await database;
    var foodMap = food.toMap();
    foodMap.addAll({"dish_id": dishId});

    await db.insert("food", foodMap);
  }

  Future<Map<int, Dish>> getDishesByDate(DateTime dateTime) async{
    Map<int, Dish> dishes = new Map<int, Dish>();

    Database db = await database;

    List<Map<String, dynamic>> res = await db.query("dishes", where: 'date = ?', whereArgs: [dateTime.toString().substring(0,10)]);
    for(int i = 0; i < res.length; i++){
      dishes[i] = Dish(res[i]["id"]);
    }

    return dishes;
  }
  Future<List<Food>> getFoodByDish(int dishId) async{
    Database db = await database;

    List<Map<String, dynamic>> res = await db.query("food", where: 'dish_id = ?', whereArgs: [dishId]);
    return List.generate(res.length, (i) {
      return Food(
        res[i]['id'],
        res[i]['isbn'],
        res[i]['name'],
        res[i]['energy'],
        res[i]['carbs'],
        res[i]['fat'],
        res[i]['protein'],
        res[i]['amount'],
      );
    });
  }

}