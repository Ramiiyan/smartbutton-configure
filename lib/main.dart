import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_configuration/wifi_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:dropdownfield/dropdownfield.dart';
import 'package:flushbar/flushbar.dart';

void main() => runApp(SmartButton());

class SmartButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Button',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Smart Button Configuration'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    
  String _ssid;  // wifi ssid for text-field to configure SmartButton
  String _pwd;   // wifi pwd for text-field to configure SmartButton
  List _ssidList = [] ;  // available wifi networks
  String url; // GET-Rest api for configure SmartButton
  List <String> wifiStringList = [];
  
  final _formKey = GlobalKey<FormState>();

  @override
  void initState(){
    super.initState();
    loadData();
    //makeConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,

      ),
      body: Column(
        children:[
          dropDownText(),
          inputRowSection(Icons.lock_outline, 'Your wifi password', 'password'),
          syncButton(context,'Pair'),
          _buttonInitConnect(context),
          
        ],
      ),
    );
  }
  
  Widget dropDownText() {
    return Container(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: 10,
      ),
      // color: Colors.white,
      //constraints: BoxConstraints.expand(),
      child: Form(
        key: _formKey,
        autovalidate: false,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              DropDownField(
                value: _ssid,
                icon: Icon(Icons.wifi),
                required: false,
                hintText: 'Choose a Wi-Fi',
                labelText: 'SSID',
                items: wifiStringList,
                strict: false,
                setter: (newValue){
                  _ssid = newValue;
                  print("NEW VAL : $newValue");
                },
                onValueChanged: (newVal){
                  print("NEW VAL : $newVal");
                  setState(() {
                   _ssid = newVal; 
                  });
                },
              ),
            ]
          )
        )
      )
    );
  }

  Widget inputRowSection(ic,hinttxt,label){
    return Container(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: 10,
      ),
      child: TextField(
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          filled: true,
          icon: Icon(ic),
          hintText: '$hinttxt',
          labelText: '$label',
        ),
        keyboardType: TextInputType.text,
        onChanged: (value){
          _pwd = value;
        }
      ),
    );
  }
  
  Widget syncButton(BuildContext context,label){
    return Container (
      margin: const EdgeInsets.all(10),
      child: RaisedButton(
        child: Text('$label'),
        onPressed:() {
          configuration(context);
        },
      ),
    );
  }

  Widget _buttonInitConnect(BuildContext context){
    return Container(
      margin:EdgeInsets.only(top: 80) ,
      alignment: Alignment.bottomCenter,
      child:Column(
        children: [
          Text("Press & Hold the Smart Button until beep sound."),
          RaisedButton(
            child: Text('Connect to SmartButton'),
            onPressed:(){ 
              makeConnection(context);
            }
          ),
        ],
      ),
    );
    
  }

  Future<Null> configuration(BuildContext context) async {
    
    print("SSID :$_ssid");
    print("PWD :$_pwd");
    String url = "http://192.168.4.1/?SSID=$_ssid&Password=$_pwd&END=Submit"; // need to text after dollar sign
    print("Response....");
    if(_ssid == null ||  _pwd == null ){
      createSnack(context,Icons.not_interested,Colors.red.shade300,'Error!','Check the credentials');
    }else if(_ssid != null && _pwd != null){
      createSnack(context,Icons.hearing,Colors.green.shade300,'Sent!','Configuration Sent, Check for the 3 beeps.');
    }
    var response = await http.get(url);
    print("Response : $response");
    print('Response status :${response.statusCode}');
    print('Response status :${response.body}');
    
    
  }
  
  Future<Null> loadData() async {
    print("Loading SSID");
    await WifiConfiguration.getWifiList().then((list) {
      setState(() {
        _ssidList = list.toSet().toList();
        wifiStringList = _ssidList.cast<String>().toList();
      });
    });
    
    print("SSID LENGTH : ");
    print(_ssidList.length);
    print("ssidlist 1 :${_ssidList[1]}");
    print("ssidlist 2 :${_ssidList[2]}");

  }

  void makeConnection(BuildContext context) async {
    print("make Connection begining...");
    createSnack(context,Icons.info_outline,Colors.blue.shade300,'Connection','Connecting to the button begin');
    //String connectionState = await WifiConfiguration.connectToWifi("Smart Button", "", "com.example.smart_button");
    String connectionState = await WifiConfiguration.connectToWifi("Smart Button", "", "com.example.smart_button");
    print("ConnectionState : $connectionState");
    print("make Connection END...");
    if(connectionState  == "notConnected") {
      createSnack(context,Icons.info_outline,Colors.blue.shade300,'Try Again','Smart Button is not connected with your Phone');

    }else if(connectionState  == "connected") {
      createSnack(context,Icons.done_outline,Colors.green.shade300,'Success!','Smart Button connected with your Phone');
    }
  }
  
  void filterSsid(List ssidList){
    print('newList :${ssidList.toSet().toList()}');
    //return ssidList.toSet().toList();
  }
  
  //pop message
  void createSnack(BuildContext context,icon,color,String title,String msg){
    Flushbar(
      flushbarStyle: FlushbarStyle.FLOATING,
      title: title,
      message: msg,
      icon: Icon(
        icon,
        size: 28,
        color: color,
      ),
      leftBarIndicatorColor: Colors.blue.shade300,
      duration: Duration(seconds: 5),
    ).show(context);

  }



}
