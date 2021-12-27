import 'dart:convert';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart' as barcode;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:http/http.dart' as http;
import 'model/dish.dart';
import 'model/food.dart';
import 'globals.dart' as globals;


class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  final Dish currentDish = new Dish();

  List<int> readValues = [0,0,0,0,0,0,0,0];

  @override
  _HomeState createState() => _HomeState();
}


class _HomeState extends State<Home> {

  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;
  final _codeController = TextEditingController();
  final Map<String,TextEditingController> _customControllers = {
    "name": TextEditingController(),
    "energy": TextEditingController(),
    "carbs": TextEditingController(),
    "fat": TextEditingController(),
    "protein": TextEditingController(),
  };

  int _getWeight(){
    return widget.readValues[3] * 256 + widget.readValues[4];
  }

  _showCustomDialog(){
    showDialog(context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Put in Nutrition-Values per 100g", style: TextStyle(color: globals.dark_blue),),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: _nutritionStyle(),
                    controller: _customControllers["name"],
                    decoration: InputDecoration(
                      hintText: "Name"
                    ),
                  ),
                  TextField(
                    style: _nutritionStyle(globals.yellow),
                    controller: _customControllers["energy"],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: "Energy",
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                            style: _nutritionStyle(),
                            controller: _customControllers["carbs"],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Carbs"
                            ),
                          )
                      ),
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8,0,8,0),
                            child: TextField(
                              style: _nutritionStyle(),
                              controller: _customControllers["protein"],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  hintText: "Protein",
                              ),
                            ),
                          )
                      ),
                      Expanded(
                          child: TextField(
                            style: _nutritionStyle(),
                            controller: _customControllers["fat"],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: "Fat"
                            ),
                          )
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  } ,
                  child: Text("Cancel", style: TextStyle(color: globals.dark_blue),)
              ),
              TextButton(
                  onPressed: () async {
                    Food food = new Food("", _customControllers["name"].text, int.parse(_customControllers["energy"].text), double.parse(_customControllers["carbs"].text), double.parse(_customControllers["fat"].text), double.parse(_customControllers["protein"].text), _getWeight());
                    setState(() {
                      widget.currentDish.foods.add(food);
                    });
                    Navigator.of(context).pop();
                  } ,
                  child: Text("Add (" + _getWeight().toString() + "g)", style: TextStyle(color: globals.yellow),)
              ),
            ],
          );
        }
    );
  }

  _showCodeDialog([String start = ""]){
    showDialog(context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Put in Product-Code"),
            content:
                TextField(
                  controller: _codeController..text = start,
                  autofocus: true,
                ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  } ,
                  child: Text("Cancel")
              ),
              TextButton(
                  onPressed: () async {
                    var response = await _fetchCode(_codeController.text);
                    setState(() {
                      widget.currentDish.foods.add(response);
                    });
                    Navigator.of(context).pop();
                  } ,
                  child: Text("Add (" + _getWeight().toString() + "g)")
              ),
            ],
          );
        }
    );
  }

  Future<Food> _fetchCode(String code) async {
    final response = await http.get(Uri.parse("https://world.openfoodfacts.org/api/v0/product/" + code + ".json"));
    if (response.statusCode == 200) {
      return Food.fromJson(jsonDecode(response.body), _getWeight());
    } else {
      throw Exception('Failed to load album');
    }
  }

  TextStyle _nutritionStyle([Color c = Colors.black]){
    return TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.bold,
      color: c
    );
  }
  TextStyle _descriptionStyle(){
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w200,
    );
  }
  
  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }
  Column _buildConnectDeviceView() {
    return Column(
      children: [
        Container(
          height: 250,
          width: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white
          ),
          child: _connectedDevice != null ? Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text("kcal", style: _descriptionStyle(),),
                        Text(widget.currentDish.getEnergy().round().toString(), style: _nutritionStyle(globals.yellow)),
                      ],
                    ),
                    Text(""),
                    Text(""),
                  ],
                ),

                Text(
                    _getWeight().toString()+"g",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: globals.dark_blue
                    ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text("Carbs", style: _descriptionStyle(),),
                        Text(widget.currentDish.getCarbs().round().toString(), style: _nutritionStyle(),),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Protein", style: _descriptionStyle(),),
                        Text(widget.currentDish.getProtein().round().toString(), style: _nutritionStyle(),),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Fat", style: _descriptionStyle(),),
                        Text(widget.currentDish.getFat().round().toString(), style: _nutritionStyle(),),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ) : (Center(child:  widget.devicesList.length == 0 ? CircularProgressIndicator(backgroundColor: globals.dark_blue,) : TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<CircleBorder>(
                  CircleBorder()
              ),
              backgroundColor: MaterialStateProperty.all(globals.dark_blue),
              foregroundColor: MaterialStateProperty.all(Colors.white)
            ),
            onPressed: () async {
              BluetoothDevice device = widget.devicesList[0];
              widget.flutterBlue.stopScan();
              try {
                await device.connect();
              } catch (e) {
                if (e.code != 'already_connected') {
                  throw e;
                }
              } finally {
                _services = await device.discoverServices();
                BluetoothCharacteristic cs;
                _services.forEach((service) {
                  if(service.uuid.toString() == globals.service){
                    service.characteristics.forEach((characteristic) {
                      if(characteristic.uuid.toString() == globals.characteristic){
                        cs = characteristic;
                      }
                    });
                  }
                });

                await cs.setNotifyValue(true);
                cs.value.listen((value) {
                  if(value != widget.readValues){
                    setState(() {
                      widget.readValues = value;
                    });
                  }
                });
              }
              setState(() {
                _connectedDevice = device;
              });
            },
            child: Icon(Icons.bluetooth),
          ))),
        ),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: widget.currentDish.foods.length,
          itemBuilder: (BuildContext context, int index){
            Food food = widget.currentDish.foods[index];
            return Dismissible(
              background: Container(margin: const EdgeInsets.all(8), color: Colors.red,),
              key: Key(index.toString()),
              onDismissed: (direction) {
                setState(() {
                  widget.currentDish.foods.remove(food);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  color: Colors.white
                ),
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(child: Text(food.name, ), constraints: BoxConstraints(maxWidth: 200),),
                    Text(food.getEnergy().round().toString(), style: _nutritionStyle(globals.yellow),)
                  ],
                ),
              ),
            );
          },
        ))
      ],
    );
  }

  Widget _buildView() {
    return _buildConnectDeviceView();
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan(withServices: [Guid(globals.service)]);
  }

  @override
  void dispose() {
    _connectedDevice.disconnect();
  }


  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Color.fromRGBO(246, 251, 255, 1),
    appBar: AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      elevation: 0,
      backgroundColor: Colors.transparent,
    ),
    floatingActionButton: _connectedDevice != null  ? SpeedDial(
      visible: true,
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: globals.dark_blue,
      children: [
        SpeedDialChild(
          child: Icon(Icons.qr_code),
          onTap: () async {
            String res = await barcode.FlutterBarcodeScanner.scanBarcode("#000000", "Cancel", true, barcode.ScanMode.BARCODE);
            if(res != "-1"){
              _showCodeDialog(res);
            }
          }
        ),
        SpeedDialChild(
            child: Icon(Icons.text_fields),
            onTap: () {
              _showCustomDialog();
            }
        ),
        SpeedDialChild(
            child: Icon(Icons.bluetooth_disabled),
            onTap: () {
              setState(() {
                _connectedDevice.disconnect();
                _connectedDevice = null;
              });
            }
        ),
      ],
    ) : null,
    body: Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: _buildView(),
    ),
  );


}
