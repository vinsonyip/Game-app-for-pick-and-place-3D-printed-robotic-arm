import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:stack/stack.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';

const int positiveInfinity = 100000;
const int negativeInfinity = -100000;
const int maxNode = 1; /// [maxNode] To define the maximum node
const int minNode = 0; /// [minNode] To define the minimum node
const int sizeOfChessboard = 64;
const int lengthOfAxis_X = 8; // This is a 8*8 chessboard
const int lengthOfAxis_Y = 8; // This is a 8*8 chessboard
const int stepsToForesee = 2;

Future<void> main() async{
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
      MaterialApp(
        title: 'Gobang Monitor',
        home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context)=> Tree()),
            ],
            child: NaviBar(camera: firstCamera,)
        ),
      ));
}
class NaviBar extends StatefulWidget {

  final CameraDescription camera;

  const NaviBar({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  _NaviBarState createState() => _NaviBarState();
}

class _NaviBarState extends State<NaviBar> {

  int _idx = 0;
  void _onTappedBar(int idx){
    setState(() {
      _idx = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _idx,
        children: [
          MyApp(camera: widget.camera,),
          ChessboardUI()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _idx,
          onTap: _onTappedBar,
          showSelectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items:[
            BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.monitor),label: 'Chessboard')
          ]
      ),
    );
  }
}
List<Choice> choices = List <Choice>(sizeOfChessboard);

// ignore: must_be_immutable
class ChessboardUI extends StatelessWidget {
  List<int> chessIndexList = [];
  Node newNode;

  @override
  Widget build(BuildContext context) {
    for(int cnt = 0;cnt<sizeOfChessboard;cnt++){
      choices[cnt] = Choice(playerOrBot: -1);
    }

    // print("HAHAHAHA");
    try{
      newNode = context.watch<Tree>().initNode;
    }catch(e){
      newNode = Node();
      print(e);
    }

    for(int i=0;i<newNode.chessPattern.length;i++) {
      if(newNode.chessPattern[i] != null) {
        if(newNode.chessPattern[i].playerOrBot == true){
          choices[i] = Choice(playerOrBot: 1, icon: Icons.circle);
        }else{
          choices[i] = Choice(playerOrBot: 0, icon: Icons.circle);
        }
      }else{
        // choices[i] = Choice(playerOrBot: 1, icon: Icons.circle);
        choices[i] = Choice(playerOrBot: -1);
      }
    }

    return MaterialApp(
        home: Scaffold(appBar: AppBar(
          title: Text("Real Time Chessboard"),
        ),
            body: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min ,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(child: Text('ChessBoard',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 420,
                    child: GridView.count(
                        crossAxisCount: 8,
                        crossAxisSpacing: 0.1,
                        mainAxisSpacing: 0.1,
                        children: List.generate(choices.length, (index) {
                          if(choices[index].icon == null){
                            return Center(
                              child: SelectCard(choice: choices[index]),
                            );
                          }else{
                            chessIndexList.add(index);
                            if(choices[index].playerOrBot == 0){ // a bot
                              return Center(
                                child: SelectCard(choice: choices[index]),
                              );
                            }else if(choices[index].playerOrBot == 1){ // a player
                              return Center(
                                child: SelectCard2(choice: choices[index]),
                              );
                            }
                            return Center(
                              child: SelectCard(choice: choices[index]),
                            );
                          }
                        }
                        )
                    ),
                  ),
                ],

              ),
            )
        )
    );
  }
}


class Choice {
  const Choice({this.playerOrBot, this.icon});
  final int playerOrBot;
  final IconData icon;
}


class SelectCard extends StatelessWidget {
  const SelectCard({Key key, this.choice}) : super(key: key);
  final Choice choice;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.0, color: Colors.black),
            left: BorderSide(width: 1.0, color: Colors.black),
            right: BorderSide(width: 1.0, color: Colors.black),
            bottom: BorderSide(width: 1.0, color: Colors.black),
          )
      ),
      child: RaisedButton(

        onPressed: (){},
        color: Colors.yellow,
        child:  Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(child: Icon(choice.icon, size:15.0)),
            ]
        ),

      ),
    );
  }
}

class SelectCard2 extends StatelessWidget {
  const SelectCard2({Key key, this.choice}) : super(key: key);
  final Choice choice;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.0, color: Colors.black),
            left: BorderSide(width: 1.0, color: Colors.black),
            right: BorderSide(width: 1.0, color: Colors.black),
            bottom: BorderSide(width: 1.0, color: Colors.black),
          )
      ),
      child: RaisedButton(
          onPressed: (){},
          color: Colors.yellow,
          child: Center(child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(child: Icon(choice.icon, size:15.0,color: Colors.white,)),
                Text("", style: TextStyle(fontSize: 0.0)),
              ]
          ),
          )
      ),
    );
  }
}



class MainPage extends StatefulWidget {
  final CameraDescription camera;
  final BluetoothDevice server;

  const MainPage({
    Key key,
    @required this.camera,
    this.server
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String x = '';
  int i = 1;
  List<Node> tree1 = [];
  int idx = 0;
  Tree myTree = Tree();
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;
  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    // Connect bluetooth to specific device address here...
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Node n1 = Node();
    n1.setName('One');
    n1.setDepth(0);
    n1.setIdx(0);
    n1.setParentIdx(-1);
    n1.setScore(negativeInfinity);

    Chesspiece c1 = Chesspiece(); // Generate the first chess on chess board
    c1.setIndex(7); // The index is the position of the chess
    c1.playerOrBot = false;

    n1.chessPattern[7] = c1;
    Timer _timer;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gobang Monitor'),),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  return CameraPreview(
                      _controller,
                      child: Column(
                        children: [
                          SizedBox(height: 45,),
                          Center(
                            child: CustomPaint(
                              painter: DetectGridPainter(
                                strokeColor: Colors.redAccent,
                                strokeWidth: 5,
                                paintingStyle: PaintingStyle.stroke,
                              ),
                              child: Container(
                                height: 190,
                                width: 195,
                              ),
                            ),
                          ),
                        ],
                      ));
                } else {
                  // Otherwise, display a loading indicator.
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            Container(
              padding: EdgeInsets.all(3.0),
              width: 10,
              child: OutlineButton(
                child: Text('Reset All'),
                onPressed: (){
                  context.read<Tree>().resetAll();
                  // print('\nLength of tree= ' + context.read<Tree>().tree.length.toString());
                },
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0),),
              ),
            ),
            Text('    Optimal Evaluation = ' + context.watch<Tree>().optimalEval.toString()),
            Text('    The name of next step = ' + context.watch<Tree>().nextStep.index.toString() +
                '\n    Depth :' + context.watch<Tree>().nextStep.depth.toString()),
            Text('    Length of tree= ' + context.watch<Tree>().tree.length.toString())
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {

          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Uncomment these rows!!!!---------------------
            await Future.delayed(Duration(milliseconds: 333)).then((_) async {
              connection.output.add(utf8.encode("M3\r"));
            });
            await Future.delayed(Duration(milliseconds: 500)).then((_) async {
              connection.output.add(utf8.encode("G1 X-70 Y55 Z-44\r"));
            });


            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();
            // print('my Path = '+ image.path);
            File imgFile = File(image.path);
            List<int> imageBytes = await imgFile.readAsBytesSync();
            String base64Img = base64Encode(imageBytes);
            // print('base64Img = '+ base64Img);

            //url to send the post request to
            final url = 'http://10.68.187.245:5000/image';

            //sending a post request to the url
            await http.post(url, body: json.encode({'image' : base64Img}));
            final response = await http.get(url);
            final decoded = json.decode(response.body) as Map<String, dynamic>;
            List<dynamic> chessboardList = jsonDecode(decoded['image']);
            // print(chessboardList); // chessboardList[chessPositionInArr][2] -> bot chess(black chess) = 0, player chess(white chess) = 1

            Node n1 = Node();
            n1.setName('One');
            n1.setDepth(0);
            n1.setIdx(0);
            n1.setParentIdx(-1);
            n1.setScore(negativeInfinity);
            // print(chessboardList.length);
            int countChess = 0;
            for(int i=0;i<chessboardList.length;i++){
              if(chessboardList[i][2] == 1){ //White chess detected
                n1.chessPattern[i] = Chesspiece();
                n1.chessPattern[i].setIndex(i);
                n1.chessPattern[i].playerOrBot = true; // true -> player chess
                print('processing...');
                countChess += 1;
              }else if(chessboardList[i][2] == 0){ //Black chess detected
                n1.chessPattern[i] = Chesspiece();
                n1.chessPattern[i].setIndex(i);
                n1.chessPattern[i].playerOrBot = false; // true -> player chess
                print('processing...');
                countChess += 1;
              }else{
                continue;
              }
            }
            await Future.delayed(Duration(seconds: 1)).then((_) async {
              connection.output.add(utf8.encode("G1 X0 Y120 Z120\r"));
            });



            if(countChess < 2){
              await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                connection.output.add(utf8.encode("G1 X-12 Y90 Z-36.5\r"));
              });
              await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                connection.output.add(utf8.encode("M5\r"));
              }); // row 7 end
              await Future.delayed(Duration(seconds: 5)).then((_) async {
                connection.output.add(utf8.encode("G1 X0 Y120 Z120\r"));
              }); // row 7 end
            }else{

              Stopwatch stopwatch = new Stopwatch()..start();


              context.read<Tree>().resetAll();
              context.read<Tree>().setInitialNode(n1);
              context.read<Tree>().generateNodes(stepsToForesee);
              Node newNode = context.read<Tree>().findNextStep();

              print('doSomething() executed in ${stopwatch.elapsed.inMilliseconds}');

              for(int i=0;i<newNode.chessPattern.length;i++){
                Chesspiece tmpC = newNode.chessPattern[i];
                if(tmpC != n1.chessPattern[i] && tmpC.playerOrBot==false){
                  print("different on: role - "+tmpC.playerOrBot.toString() + " index: "+i.toString());
                  try{
                    await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                      switch(i){
                        case 0:
                        // index 0
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X18 Y60 Z-32.5\r"));
                          });
                          break;
                        case 1:
                        //index 1
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X10 Y60 Z-32.5\r"));
                          });
                          break;
                        case 2:
                        //index 2
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X3 Y60 Z-32.5\r"));
                          });
                          break;
                        case 3:
                        //index 3
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-3 Y60 Z-32.5\r"));
                          });
                          break;
                        case 4:
                        //index 4
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-10 Y62 Z-32.5\r"));
                          });

                          break;
                        case 5:
                        //index 5
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-18 Y64 Z-32.5\r"));
                          });
                          break;
                        case 6:
                        //index 6
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-26 Y70 Z-34.5\r"));
                          });
                          break;
                        case 7:
                        //index 7
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-40 Y85 Z-40.5\r"));
                          }); //row 1 end
                          break;
                        case 8:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X30 Y97 Z-36.5\r"));
                          });
                          break;
                        case 9:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X18 Y92 Z-36.5\r"));
                          });
                          break;
                        case 10:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X6 Y90 Z-36.5\r"));
                          });
                          break;
                        case 11:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-2 Y90 Z-36.5\r"));
                          });

                          break;
                        case 12:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-12 Y90 Z-36.5\r"));
                          });
                          break;
                        case 13:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-22 Y95 Z-36.5\r"));
                          });
                          break;
                        case 14:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-34 Y100 Z-40\r"));
                          });
                          break;
                        case 15:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-48 Y108 Z-42\r"));
                          }); //row 1 end
                          break;
                        case 16:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X35 Y120 Z-45.5\r"));
                          });
                          break;
                        case 17:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X24 Y120 Z-45.5\r"));
                          });
                          break;
                        case 18:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X10 Y118 Z-45.5\r"));
                          });
                          break;
                        case 19:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-2 Y118 Z-45.5\r"));
                          });
                          break;
                        case 20:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-14 Y120 Z-45.5\r"));
                          });
                          break;
                        case 21:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-26 Y122 Z-45.5\r"));
                          });
                          break;
                        case 22:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-38 Y124 Z-47.5\r"));
                          });
                          break;
                        case 23:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-50 Y130 Z-50.5\r"));
                          }); // row 2 end
                          break;
                        case 24:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X40 Y144 Z-45.5\r"));
                          });
                          break;
                        case 25:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X26 Y144 Z-45.5\r"));
                          });
                          break;
                        case 26:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X12 Y144 Z-45.5\r"));
                          });
                          break;
                        case 27:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-2 Y144 Z-45.5\r"));
                          });
                          break;
                        case 28:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-14 Y144 Z-45.5\r"));
                          });
                          break;
                        case 29:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-28 Y144 Z-45.5\r"));
                          });
                          break;
                        case 30:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-42 Y150 Z-49.5\r"));
                          });
                          break;
                        case 31:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-54 Y155 Z-49.5\r"));
                          }); // row 3 end
                          break;
                        case 32:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X47 Y170 Z-54.5\r"));
                          });
                          break;
                        case 33:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X30.5 Y170 Z-54.5\r"));
                          });
                          break;
                        case 34:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X17 Y170 Z-54.5\r"));
                          });
                          break;
                        case 35:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X0 Y170 Z-54.5\r"));
                          });
                          break;
                        case 36:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-15 Y173 Z-56.5\r"));
                          });
                          break;
                        case 37:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-27 Y173 Z-56.5\r"));
                          });
                          break;
                        case 38:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-43 Y178 Z-58.5\r"));
                          });
                          break;
                        case 39:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-57 Y182 Z-60.5\r"));
                          }); // row 4 end

                          break;
                        case 40:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X53 Y195 Z-56.5\r"));
                          });
                          break;
                        case 41:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X35 Y195 Z-56.5\r"));
                          });
                          break;
                        case 42:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X20 Y195 Z-56.5\r"));
                          });
                          break;
                        case 43:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X5 Y195 Z-56.5\r"));
                          });
                          break;
                        case 44:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-12 Y195 Z-56.5\r"));
                          });
                          break;
                        case 45:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-28 Y200 Z-58.5\r"));
                          });
                          break;
                        case 46:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-45 Y205 Z-58.5\r"));
                          });
                          break;
                        case 47:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-61 Y205 Z-59.5\r"));
                          }); // row 5 end
                          break;
                        case 48:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X56 Y225 Z-65.5\r"));
                          });
                          break;
                        case 49:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X35 Y225 Z-65.5\r"));
                          });
                          break;
                        case 50:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X20 Y225 Z-65.5\r"));
                          });
                          break;
                        case 51:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X5 Y225 Z-65.5\r"));
                          });
                          break;
                        case 52:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-10 Y225 Z-65.5\r"));
                          });
                          break;
                        case 53:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-25 Y225 Z-65.5\r"));
                          });
                          break;
                        case 54:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-45 Y235 Z-65.5\r"));
                          });
                          break;
                        case 55:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-60 Y235 Z-67.5\r"));
                          });//row 6 end
                          break;
                        case 56:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X60 Y255 Z-70.5\r"));
                          });
                          break;
                        case 57:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X45 Y255 Z-70.5\r"));
                          });
                          break;
                        case 58:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X25 Y255 Z-70.5\r"));
                          });
                          break;
                        case 59:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X10 Y255 Z-70.5\r"));
                          });
                          break;
                        case 60:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-15 Y255 Z-70.5\r"));
                          });
                          break;
                        case 61:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-30 Y260 Z-70.5\r"));
                          });
                          break;
                        case 62:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-50 Y270 Z-70.5\r"));
                          });
                          break;
                        case 63:
                          await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                            connection.output.add(utf8.encode("G1 X-75 Y280 Z-75.5\r"));
                          }); // row 7 end
                          break;
                      }
                    });


                    await Future.delayed(Duration(milliseconds: 333)).then((_) async {
                      connection.output.add(utf8.encode("M5\r"));
                    }); // row 7 end
                    await Future.delayed(Duration(seconds: 5)).then((_) async {
                      connection.output.add(utf8.encode("G1 X0 Y120 Z120\r"));
                    }); // row 7 end

                    await connection.output.allSent;
                    // await connection.finish(); // Closing connection
                  }catch(e){
                    print(e);
                  }



                  break;
                }
              }
              // print('\nLength of tree= ' + context.read<Tree>().tree.length.toString());
            }


            // -------------------Uncomment---------------------------






          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }


  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}

class Tree extends ChangeNotifier{
  List<Node> _tree = [];
  int _currentIdx = 0; // A cursor for current visiting node(used by DFS)
  int _minOrMax = 1; // Max == 1 else 0
  int _length = 0;
  int _optimalEval = 0;
  Node _nextStep = Node();
  Node _initialNode = Node();


  List<Node> get tree{
    return _tree;
  }
  void setInitialNode(Node n){ // This method should be called first, when object generated
    _initialNode = n;
    notifyListeners();
  }
  void generateNodes(int stepsToForesee){// you can decide how many steps to foresee, recommend: stepsToForesee = 3
    _tree = [];
    int depth = stepsToForesee*2;
    _initialNode.setIdx(0);
    _initialNode.setDepth(0);
    _tree.add(_initialNode);
    Node currentNode = _initialNode;
    List <int>possibleChessLocationList = [];
    // possibleChessLocationList = possibleChessLocationList.toSet().toList(); // remove duplicates in list
    int parentIndex = 0;
    int currentIndex = 1;
    for(int d=0;d<=_tree.length;d++){ // depth 0 is initial node, so we start with depth 1
      // if the last element of the tree has depth = preset foresee step then break the node generation
      if(_tree[_tree.length-1].depth >= depth+1) break;
      parentIndex = d;
      currentNode = _tree[d];
      possibleChessLocationList = [];

      if(_tree[d].depth%2 == 0){ // Generate maximizing node(bot node)
        for(int i=0;i<currentNode.chessPattern.length;i++){
          Chesspiece tmpChess = currentNode.chessPattern[i];
          if(tmpChess!=null && !tmpChess.playerOrBot){// Generate new node for player
            //Check the top grid of current node - 1
            if(tmpChess.yAxis-1 >= 0) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis-1)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis-1));
              }
            }
            //Check the bottom grid of current node - 2
            if(tmpChess.yAxis+1 < lengthOfAxis_Y) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis+1)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis+1));
              }
            }

            //Check the left grid of current node - 3
            if(tmpChess.xAxis-1 >=0 ) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-1, tmpChess.yAxis)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis-1, tmpChess.yAxis));
              }
            }

            //Check the right grid of current node - 4
            if(tmpChess.xAxis+1 < lengthOfAxis_X ) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+1, tmpChess.yAxis)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis+1, tmpChess.yAxis));
              }
            }

            //Check the top-right grid of current node - 5
            if(tmpChess.xAxis+1 < lengthOfAxis_X && tmpChess.yAxis-1 >= 0) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+1, tmpChess.yAxis-1)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis+1, tmpChess.yAxis-1));
              }
            }

            //Check the top-left grid of current node - 6
            if(tmpChess.xAxis-1 >=0 && tmpChess.yAxis-1 >= 0) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-1, tmpChess.yAxis-1)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis-1, tmpChess.yAxis-1));
              }
            }

            //Check the bottom-right grid of current node - 7
            if(tmpChess.yAxis+1 < lengthOfAxis_Y && tmpChess.xAxis+1 < lengthOfAxis_X) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+1, tmpChess.yAxis+1)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis+1, tmpChess.yAxis+1));
              }
            }

            //Check the bottom-left grid of current node - 8
            if(tmpChess.yAxis+1 < lengthOfAxis_Y && tmpChess.xAxis-1 < lengthOfAxis_X) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-1, tmpChess.yAxis+1)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis-1, tmpChess.yAxis+1));
              }
            }
          }
        }
        // all possible new chess already put in 'possibleChessLocationList'
        possibleChessLocationList = possibleChessLocationList.toSet().toList(); //remove duplicates from origin list

        // generate new node with pattern based on the new chess location provided in 'possibleChessLocationList'
        for(int i=0;i<possibleChessLocationList.length;i++){
          Node n = Node();
          for(int cnt=0; cnt<currentNode.chessPattern.length;cnt++){// copy the chess pattern of the current node
            n.chessPattern[cnt] = currentNode.chessPattern[cnt];
          }
          Chesspiece newChess = Chesspiece(); // Generate new chess piece on parent chessboard
          newChess.setIndex(possibleChessLocationList[i]);
          newChess.playerOrBot = true; // Generate bot chess in player chessboard
          n.chessPattern[possibleChessLocationList[i]] = newChess; // append a new chess on empty grid nearing current bot chess
          n.setIdx(currentIndex);
          n.setParentIdx(parentIndex);
          n.setDepth(currentNode.depth+1);
          n.setScore(positiveInfinity); // A new maximizing node must have negative infinity score
          n.evaluateScore();
          currentNode.getChildrenIndexList.add(currentIndex); // Add the new node to parent node children list
          _tree.add(n);
          currentIndex+=1; // +1 for indexing next node in the tree

        }
      }else{ // Generate minimizing node(player node)
        for(int i=0;i<currentNode.chessPattern.length;i++){
          Chesspiece tmpChess = currentNode.chessPattern[i];
          if(tmpChess!=null && tmpChess.playerOrBot){ // Generate new node for bot
            //Check the top grid of current node - 1
            if(tmpChess.yAxis-1 >= 0) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis-1)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis-1));
              }
            }
            //Check the bottom grid of current node - 2
            if(tmpChess.yAxis+1 < lengthOfAxis_Y) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis+1)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis+1));
              }
            }

            //Check the left grid of current node - 3
            if(tmpChess.xAxis-1 >=0 ) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-1, tmpChess.yAxis)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis-1, tmpChess.yAxis));
              }
            }

            //Check the right grid of current node - 4
            if(tmpChess.xAxis+1 < lengthOfAxis_X ) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+1, tmpChess.yAxis)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis+1, tmpChess.yAxis));
              }
            }

            //Check the top-right grid of current node - 5
            if(tmpChess.xAxis+1 < lengthOfAxis_X && tmpChess.yAxis-1 >= 0) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+1, tmpChess.yAxis-1)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis+1, tmpChess.yAxis-1));
              }
            }

            //Check the top-left grid of current node - 6
            if(tmpChess.xAxis-1 >=0 && tmpChess.yAxis-1 >= 0) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-1, tmpChess.yAxis-1)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis-1, tmpChess.yAxis-1));
              }
            }

            //Check the bottom-right grid of current node - 7
            if(tmpChess.yAxis+1 < lengthOfAxis_Y && tmpChess.xAxis+1 < lengthOfAxis_X) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+1, tmpChess.yAxis+1)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis+1, tmpChess.yAxis+1));
              }
            }

            //Check the bottom-left grid of current node - 8
            if(tmpChess.yAxis+1 < lengthOfAxis_Y && tmpChess.xAxis-1 < lengthOfAxis_X) { //then the bottom-left grids
              if(currentNode.chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-1, tmpChess.yAxis+1)] == null){
                possibleChessLocationList.add(tmpChess.coordToIndex(tmpChess.xAxis-1, tmpChess.yAxis+1));
              }
            }
          }
        }
        // all possible new chess already put in 'possibleChessLocationList'
        possibleChessLocationList = possibleChessLocationList.toSet().toList(); //remove duplicates from origin list

        // generate new node with pattern based on the new chess location provided in 'possibleChessLocationList'
        for(int i=0;i<possibleChessLocationList.length;i++){
          Node n = Node();
          for(int cnt=0; cnt<currentNode.chessPattern.length;cnt++){// copy the chess pattern of the current node
            n.chessPattern[cnt] = currentNode.chessPattern[cnt];
          }
          Chesspiece newChess = Chesspiece(); // Generate new chess piece on parent chessboard
          newChess.setIndex(possibleChessLocationList[i]);
          newChess.playerOrBot = false; // Generate bot chess in player chessboard
          n.chessPattern[possibleChessLocationList[i]] = newChess; // place a new chess on empty grid found before
          n.setIdx(currentIndex);
          n.setParentIdx(parentIndex);
          n.setDepth(currentNode.depth+1);
          n.setScore(negativeInfinity); // A new maximizing node must have negative infinity score
          n.evaluateScore();
          currentNode.getChildrenIndexList.add(currentIndex); // Add the new node to parent node children list
          _tree.add(n);// Add the node to tree
          currentIndex+=1; // +1 for indexing next node in the tree
        }
      }
    }

  }
  void resetAllNodeAfterDFS(){
    for(int i=0;i<_tree.length;i++){
      _tree[i].setVisited(false);
    }
  }
  void depthFirstTraversal(){
    int rootIdx = 0;
    Stack<int> idxStack = Stack();
    _tree[rootIdx].setVisited(true);
    idxStack.push(rootIdx);
    // print(_tree[rootIdx].name);
    while(true){
      for(int i=0;i<_tree[rootIdx].getChildrenIndexList.length;i++){
        Node visitingNode = _tree[_tree[rootIdx].getChildrenIndexList[i]];
        if(visitingNode.visited == false){
          rootIdx = visitingNode.index;
          visitingNode.setVisited(true);
          idxStack.push(rootIdx);
          // print(_tree[rootIdx].name + _tree[rootIdx].score.toString());
          break;
        }
        if(i == _tree[rootIdx].getChildrenIndexList.length-1){ // If all children nodes are visited
          if(idxStack.isEmpty()==true){
            return;
          }else{
            rootIdx = idxStack.pop();
            break;
          }
        }
      }
      if(_tree[rootIdx].getChildrenIndexList.length == 0){ // If no children node
        // print('This is a leaf');
        if(idxStack.isEmpty()==true){
          return;
        }else{
          rootIdx = idxStack.pop();
        }
      }
    }
  }

  // node - current node to evaluate
  // depth - how many steps to foresee
  // maxOrMinPlayer - Maximizer or Minimizer - True or False
  int minimaxAlgo(Node node,int depth,bool maxOrMinPlayer,int alpha,int beta){ // This algorithm will provide optimal value to each node
    if(depth == 0 || node.getChildrenIndexList.length == 0){// A leaf or a root
      return node.score;
    }
    if(maxOrMinPlayer){ // if the player is maximizer
      int maxEval = negativeInfinity;
      List<int> eval = List(node.getChildrenIndexList.length);
      for(int i=0;i<eval.length;i++){
        eval[i] = positiveInfinity;
      }
      for(int i=0;i<node.getChildrenIndexList.length;i++){
        eval[i] = minimaxAlgo(_tree[node.getChildrenIndexList[i]],depth-1,false,alpha,beta);
        maxEval = max(maxEval,eval[i]);
        alpha = max(alpha,maxEval);
        if(beta<=alpha)break;
      }
      node.setScore(maxEval);
      return maxEval;
    }else{ // if the player is minimizer
      int minEval = positiveInfinity;
      List<int> eval = List(node.getChildrenIndexList.length);
      for(int i=0;i<eval.length;i++){
        eval[i] = positiveInfinity;
      }
      for(int i=0;i<node.getChildrenIndexList.length;i++){
        eval[i] = minimaxAlgo(_tree[node.getChildrenIndexList[i]],depth-1,true,alpha,beta);
        minEval = min(minEval,eval[i]);
        beta = min(beta,minEval);
        if(beta <= alpha)break;
      }
      node.setScore(minEval);
      return minEval;
    }
  }

  void findOptimalEval(){
    int depth = stepsToForesee*2; // Steps to foresee
    Node firstElementOfTree = _tree[0];
    bool maxOrMin = true;
    int alpha = negativeInfinity;
    int beta = positiveInfinity;
    if(_tree.length > 0){
      _optimalEval = minimaxAlgo(firstElementOfTree, depth, maxOrMin,alpha,beta);
    }
    notifyListeners();
  }

  Node findNextStep() { // Mainly use this method, but not minimaxAlgo and findOptimalEval method
    findOptimalEval();
    for (int i = 0; i < _tree[0].getChildrenIndexList.length; i++) {
      if (_tree[_tree[0].getChildrenIndexList[i]].score == _optimalEval) {
        Node opponentStep = Node();
        opponentStep = _tree[_tree[0].getChildrenIndexList[i]];
        for (int j = 0; j < opponentStep.getChildrenIndexList.length; j++) {
          if (_tree[opponentStep.getChildrenIndexList[j]].score == _optimalEval) {
            _nextStep = _tree[opponentStep.getChildrenIndexList[j]];

            notifyListeners();
            return _nextStep;
          }
        }
      }
    }
    Node undefinedNode = Node();
    undefinedNode.setName('Undefined node!');
    return undefinedNode;
  }

  Node get initNode{
    return _initialNode;
  }

  Node get nextStep{
    return _nextStep;
  }

  int get optimalEval{
    return _optimalEval;
  }

  int get length{
    return _length;
  }

  int get currentIdx{
    return _currentIdx;
  }

  int get minOrMax{
    return _minOrMax;
  }

  int checkNodeIsMinOrMax(int nodeIdx){
    if(nodeIdx % 2 == 0){
      return maxNode;
    }else{
      return minNode;
    }
  }

  Node getNodeByIndex(int i){
    return _tree[i];
  }

  Node visitNodeByIndex(int i){
    _currentIdx = i;
    _tree[i].depth % 2 == 0 ? _minOrMax = maxNode : _minOrMax = minNode;
    return _tree[i];
  }

  void addNode(Node n){
    _tree.add(n);
    _length += 1;
    notifyListeners();
  }

  void insertNode(int idx,Node n){
    _tree.insert(idx,n);
    _length+=1;
    notifyListeners();
  }

  void updateTree(List<Node> t){
    _tree = t;
    _length = t.length;
    notifyListeners();
  }

  void resetAll(){
    _tree = [];
    _currentIdx = 0; // A cursor for current visiting node(used by DFS)
    _minOrMax = 1; // Max == 1 else 0
    _length = 0;
    _optimalEval = 0;
    _nextStep = Node();
    _initialNode = Node();
    notifyListeners();
  }

}

class Chesspiece{
  int _xAxis = -1;
  int _yAxis = -1;
  int _index = -1;
  bool playerOrBot = false; // false = bot, else player

  int get index{
    return _index;
  }

  int get xAxis{
    return _xAxis;
  }

  int get yAxis{
    return _yAxis;
  }
  void setIndex(int idx){
    _index = idx;
    _xAxis = (_index%8);
    _yAxis =  (_index~/8);
  }

  int coordToIndex(int x,int y){
    return y*8+x;
  }

}

class Node{
  String _name = 'Undefined node';
  int _depth = -1;
  int _parentIdx;
  int _score = 0;
  int _idx = -1;
  bool _visited = false;
  List<int> _childrenIdx = [];
  List<Chesspiece> chessPattern = List<Chesspiece>(sizeOfChessboard);

  void addChildNodeIdx(int i){
    _childrenIdx.add(i);
  }

  void setVisited(bool v){
    _visited = v;
  }

  void setIdx(int i){
    _idx = i;
  }

  void setScore(int s){
    _score = s;
  }

  void setParentIdx(int p){
    _parentIdx = p;
  }

  void setName(String n){
    _name = n;
  }

  void setDepth(int d){
    _depth = d;
  }

  void evaluateScore(){
    _score = 0; //initialize the score first
    List<Chesspiece> existingChess = List<Chesspiece>();
    for(int i=0;i<sizeOfChessboard;i++){
      if(chessPattern[i] != null){
        existingChess.add(chessPattern[i]);
      }
    }
    if(_depth % 2 == 0){//Maximizing node
      // print('\n//// Attacker Score ////');
      //Attacker score
      bool live1CheckAlready = false;
      bool live2CheckAlready = false;
      bool live3CheckAlready = false;
      bool live4CheckAlready = false;
      bool dead1CheckAlready = false;
      bool dead2CheckAlready = false;
      bool dead3CheckAlready = false;
      bool dead4CheckAlready = false;

      for(int i=0;i<existingChess.length;i++){
        Chesspiece tmpChess = existingChess[i];
        if(tmpChess.playerOrBot == false){

          ///// For live 1 evaluation /////
          int condition = 0;
          // if condition = 4 means the chess being block from 8 direction
          // where
          // 1. left-right,
          // 2. top left-bottom right
          // 3. left - right
          // 4. top - bottom
          //  then the chess is a dead 1

          ///// For live 2-4 evaluation /////
          int boundaryHitCnt = 0; // Useless for now

          int cntContChess = 1; // must be initialized after each counting
          int cntEmptyGrid = 0;




          //////     BOTTOM RIGHT -> TOP LEFT (A cross pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check Bottom Right grids first
            if(tmpChess.xAxis+cnt < lengthOfAxis_X && tmpChess.yAxis+cnt < lengthOfAxis_Y) { //then the top-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis+cnt)] != null){
                Chesspiece bottomRightChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis+cnt)];
                if(bottomRightChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.xAxis-cnt >= 0 && tmpChess.yAxis-cnt >= 0) { //then the top-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis-cnt)] != null){
                Chesspiece topLeftChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis-cnt)];
                if(topLeftChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score += 150;
                  // print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead1CheckAlready){
                  condition+=1;
                  // dead1CheckAlready = true;
                  // print('dead 1 suspect - idx 1');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score += 500;
                  // print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score += 100;
                  dead2CheckAlready = true;
                  // print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score += 1000;
                  // print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score += 300;
                  // print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score += 8000;
                  // print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score += 2000;
                  // print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     BOTTOM RIGHT -> TOP LEFT (A cross pattern) //////

          //////     BOTTOM LEFT -> TOP RIGHT (A cross pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check Bottom Right grids first
            if(tmpChess.xAxis-cnt > 0 && tmpChess.yAxis+cnt < lengthOfAxis_Y) { //then the bottom-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis+cnt)] != null){
                Chesspiece bottomLeftChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis+cnt)];
                if(bottomLeftChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.xAxis+cnt < lengthOfAxis_X && tmpChess.yAxis-cnt >= 0) { //then the top-right grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis-cnt)] != null){
                Chesspiece topRightChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis-cnt)];
                if(topRightChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score += 150;
                  // print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 1
                if(!dead1CheckAlready){
                  condition+=1;
                  // dead1CheckAlready = true;
                  // print('dead 1 suspect - idx 2');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score += 500;
                  // print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score += 100;
                  dead2CheckAlready = true;
                  // print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score += 1000;
                  // print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score += 300;
                  // print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score += 8000;
                  // print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score += 2000;
                  //print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     BOTTOM LEFT -> TOP RIGHT (A cross pattern) //////

          //////     RIGHT -> LEFT (A row pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check Right grids first
            if(tmpChess.xAxis+cnt < lengthOfAxis_X) {
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis)] != null){
                Chesspiece bottomRightChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis)];
                if(bottomRightChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.xAxis-cnt >= 0) { //then the left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis)] != null){
                Chesspiece topLeftChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis)];
                if(topLeftChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score += 150;
                  //print('live 1 ');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead1CheckAlready){
                  condition+=1;
                  // dead1CheckAlready = true;
                  //print('dead 1 suspect - idx 3');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score += 500;
                  //('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score += 100;
                  dead2CheckAlready = true;
                  //print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score += 1000;
                  // print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score += 300;
                  //  print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score += 8000;
                  // print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score += 2000;
                  //  print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     RIGHT -> LEFT (A row pattern) //////

          //////     BOTTOM -> TOP (A cross pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check bottom grids first
            if(tmpChess.yAxis+cnt < lengthOfAxis_Y) { //then the bottom-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis+cnt)] != null){
                Chesspiece bottomChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis+cnt)];
                if(bottomChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.yAxis-cnt >= 0) { //then the top grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis-cnt)] != null){
                Chesspiece topChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis-cnt)];
                if(topChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score += 150;
                  //  print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 1
                if(!dead1CheckAlready){
                  condition+=1;
                  if(condition == 4){
                    _score += 25;
                    dead1CheckAlready = true;
                  }
                  // print('dead 1 suspect - idx 4');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score += 500;
                  // print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score += 100;
                  dead2CheckAlready = true;
                  // print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score += 1000;
                  //  print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score += 300;
                  //  print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score += 8000;
                  //  print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score += 2000;
                  //   print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     BOTTOM -> TOP (A column pattern) //////

        }
      }
      //print('\n//// Attacker Score : ' + _score.toString() + ' ////');

      //Defender score(The attacker score of opponent in this round)
      //print('\n//// Defender Score ////');
      live1CheckAlready = false;
      live2CheckAlready = false;
      live3CheckAlready = false;
      live4CheckAlready = false;
      dead1CheckAlready = false;
      dead2CheckAlready = false;
      dead3CheckAlready = false;
      dead4CheckAlready = false;
      for(int i=0;i<existingChess.length;i++){
        Chesspiece tmpChess = existingChess[i];
        if(tmpChess.playerOrBot == true){

          ///// For live 1 evaluation /////
          int condition = 0;
          // if condition = 4 means the chess being block from 8 direction
          // where
          // 1. left-right,
          // 2. top left-bottom right
          // 3. left - right
          // 4. top - bottom
          //  then the chess is a dead 1

          ///// For live 2-4 evaluation /////
          int boundaryHitCnt = 0; // Useless for now

          int cntContChess = 1; // must be initialized after each counting
          int cntEmptyGrid = 0;




          //////     BOTTOM RIGHT -> TOP LEFT (A cross pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check Bottom Right grids first
            if(tmpChess.xAxis+cnt < lengthOfAxis_X && tmpChess.yAxis+cnt < lengthOfAxis_Y) { //then the top-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis+cnt)] != null){
                Chesspiece bottomRightChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis+cnt)];
                if(!bottomRightChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.xAxis-cnt >= 0 && tmpChess.yAxis-cnt >= 0) { //then the top-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis-cnt)] != null){
                Chesspiece topLeftChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis-cnt)];
                if(!topLeftChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score += 300;
                  // print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead1CheckAlready){
                  condition+=1;
                  // dead1CheckAlready = true;
                  // print('dead 1 suspect - idx 1');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score += 2000;
                  // print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score += 250;
                  dead2CheckAlready = true;
                  // print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score += 2500;
                  // print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score += 800;
                  // print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score += 16000;
                  // print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score += 16000;
                  //  print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     BOTTOM RIGHT -> TOP LEFT (A cross pattern) //////

          //////     BOTTOM LEFT -> TOP RIGHT (A cross pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check Bottom Right grids first
            if(tmpChess.xAxis-cnt > 0 && tmpChess.yAxis+cnt < lengthOfAxis_Y) { //then the bottom-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis+cnt)] != null){
                Chesspiece bottomLeftChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis+cnt)];
                if(!bottomLeftChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.xAxis+cnt < lengthOfAxis_X && tmpChess.yAxis-cnt >= 0) { //then the top-right grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis-cnt)] != null){
                Chesspiece topRightChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis-cnt)];
                if(!topRightChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score += 300;
                  //   print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead1CheckAlready){
                  condition+=1;
                  // dead1CheckAlready = true;
                  //  print('dead 1 suspect - idx 2');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score += 2000;
                  // print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score += 250;
                  dead2CheckAlready = true;
                  //   print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score += 2500;
                  //  print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score += 800;
                  // print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score += 16000;
                  // print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score += 16000;
                  // print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     BOTTOM LEFT -> TOP RIGHT (A cross pattern) //////

          //////     RIGHT -> LEFT (A row pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check Right grids first
            if(tmpChess.xAxis+cnt < lengthOfAxis_X) {
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis)] != null){
                Chesspiece bottomRightChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis)];
                if(!bottomRightChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.xAxis-cnt >= 0) { //then the left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis)] != null){
                Chesspiece topLeftChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis)];
                if(!topLeftChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score += 300;
                  // print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead1CheckAlready){
                  condition+=1;
                  // dead1CheckAlready = true;
                  // print('dead 1 suspect - idx 3');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score += 2000;
                  // print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score += 250;
                  dead2CheckAlready = true;
                  // print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score += 2500;
                  //  print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score += 800;
                  // print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score += 16000;
                  // print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score += 16000;
                  // print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     RIGHT -> LEFT (A row pattern) //////

          //////     BOTTOM -> TOP (A cross pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check bottom grids first
            if(tmpChess.yAxis+cnt < lengthOfAxis_Y) { //then the bottom-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis+cnt)] != null){
                Chesspiece bottomChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis+cnt)];
                if(!bottomChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.yAxis-cnt >= 0) { //then the top grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis-cnt)] != null){
                Chesspiece topChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis-cnt)];
                if(!topChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score += 300;
                  // print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 1
                if(!dead1CheckAlready){
                  condition+=1;
                  if(condition == 4){
                    _score += 60;
                    dead1CheckAlready = true;
                  }
                  // print('dead 1 suspect - idx 4');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score += 2000;
                  // print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score += 250;
                  dead2CheckAlready = true;
                  //  print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score += 2500;
                  //  print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score += 800;
                  // print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score += 16000;
                  // print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score += 16000;
                  // print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     BOTTOM -> TOP (A column pattern) //////

        }
      }
      //print('Depth = '+ _depth.toString() +'\n//// Total Score : ' + _score.toString() + ' ////');

    }else{//Minimizing node
      //('\n//// Attacker Score ////');
      //Attacker score
      bool live1CheckAlready = false;
      bool live2CheckAlready = false;
      bool live3CheckAlready = false;
      bool live4CheckAlready = false;
      bool dead1CheckAlready = false;
      bool dead2CheckAlready = false;
      bool dead3CheckAlready = false;
      bool dead4CheckAlready = false;

      for(int i=0;i<existingChess.length;i++){
        Chesspiece tmpChess = existingChess[i];
        if(tmpChess.playerOrBot == true){

          ///// For live 1 evaluation /////
          int condition = 0;
          // if condition = 4 means the chess being block from 8 direction
          // where
          // 1. left-right,
          // 2. top left-bottom right
          // 3. left - right
          // 4. top - bottom
          //  then the chess is a dead 1

          ///// For live 2-4 evaluation /////
          int boundaryHitCnt = 0; // Useless for now

          int cntContChess = 1; // must be initialized after each counting
          int cntEmptyGrid = 0;




          //////     BOTTOM RIGHT -> TOP LEFT (A cross pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check Bottom Right grids first
            if(tmpChess.xAxis+cnt < lengthOfAxis_X && tmpChess.yAxis+cnt < lengthOfAxis_Y) { //then the top-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis+cnt)] != null){
                Chesspiece bottomRightChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis+cnt)];
                if(!bottomRightChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.xAxis-cnt >= 0 && tmpChess.yAxis-cnt >= 0) { //then the top-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis-cnt)] != null){
                Chesspiece topLeftChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis-cnt)];
                if(!topLeftChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score -= 150;
                  //  print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead1CheckAlready){
                  condition+=1;
                  // dead1CheckAlready = true;
                  //  print('dead 1 suspect - idx 1');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score -= 500;
                  //   print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score -= 100;
                  dead2CheckAlready = true;
                  //  print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score -= 1000;
                  //  print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score -= 300;
                  //  print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score -= 8000;
                  //   print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score -= 2000;
                  //   print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     BOTTOM RIGHT -> TOP LEFT (A cross pattern) //////

          //////     BOTTOM LEFT -> TOP RIGHT (A cross pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check Bottom Right grids first
            if(tmpChess.xAxis-cnt > 0 && tmpChess.yAxis+cnt < lengthOfAxis_Y) { //then the bottom-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis+cnt)] != null){
                Chesspiece bottomLeftChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis+cnt)];
                if(!bottomLeftChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.xAxis+cnt < lengthOfAxis_X && tmpChess.yAxis-cnt >= 0) { //then the top-right grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis-cnt)] != null){
                Chesspiece topRightChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis-cnt)];
                if(!topRightChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score -= 150;
                  //   print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 1
                if(!dead1CheckAlready){
                  condition+=1;
                  // dead1CheckAlready = true;
                  //  print('dead 1 suspect - idx 2');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score -= 500;
                  //  print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score -= 100;
                  dead2CheckAlready = true;
                  //  print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score -= 1000;
                  //  print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score -= 300;
                  //     print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score -= 8000;
                  //  print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score -= 2000;
                  //  print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     BOTTOM LEFT -> TOP RIGHT (A cross pattern) //////

          //////     RIGHT -> LEFT (A row pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check Right grids first
            if(tmpChess.xAxis+cnt < lengthOfAxis_X) {
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis)] != null){
                Chesspiece bottomRightChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis)];
                if(!bottomRightChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.xAxis-cnt >= 0) { //then the left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis)] != null){
                Chesspiece topLeftChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis)];
                if(!topLeftChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score -= 150;
                  //   print('live 1 ');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead1CheckAlready){
                  condition+=1;
                  // dead1CheckAlready = true;
                  // print('dead 1 suspect - idx 3');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score -= 500;
                  //  print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score -= 100;
                  dead2CheckAlready = true;
                  //  print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score -= 1000;
                  //   print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score -= 300;
                  //  print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score -= 8000;
                  // print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score -= 2000;
                  //  print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     RIGHT -> LEFT (A row pattern) //////

          //////     BOTTOM -> TOP (A cross pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check bottom grids first
            if(tmpChess.yAxis+cnt < lengthOfAxis_Y) { //then the bottom-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis+cnt)] != null){
                Chesspiece bottomChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis+cnt)];
                if(!bottomChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.yAxis-cnt >= 0) { //then the top grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis-cnt)] != null){
                Chesspiece topChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis-cnt)];
                if(!topChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score -= 150;
                  //  print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 1
                if(!dead1CheckAlready){
                  condition+=1;
                  if(condition == 4){
                    _score -= 25;
                    dead1CheckAlready = true;
                  }
                  //  print('dead 1 suspect - idx 4');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score -= 500;
                  //  print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score -= 100;
                  dead2CheckAlready = true;
                  //  print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score -= 1000;
                  //  print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score -= 300;
                  //  print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score -= 8000;
                  //  print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score -= 2000;
                  //  print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     BOTTOM -> TOP (A column pattern) //////

        }
      }
      //  print('\n//// Attacker Score : ' + _score.toString() + ' ////');

      //Defender score(The attacker score of opponent in this round)
      //  print('\n//// Defender Score ////');
      live1CheckAlready = false;
      live2CheckAlready = false;
      live3CheckAlready = false;
      live4CheckAlready = false;
      dead1CheckAlready = false;
      dead2CheckAlready = false;
      dead3CheckAlready = false;
      dead4CheckAlready = false;
      for(int i=0;i<existingChess.length;i++){
        Chesspiece tmpChess = existingChess[i];
        if(tmpChess.playerOrBot == false){

          ///// For live 1 evaluation /////
          int condition = 0;
          // if condition = 4 means the chess being block from 8 direction
          // where
          // 1. left-right,
          // 2. top left-bottom right
          // 3. left - right
          // 4. top - bottom
          //  then the chess is a dead 1

          ///// For live 2-4 evaluation /////
          int boundaryHitCnt = 0; // Useless for now

          int cntContChess = 1; // must be initialized after each counting
          int cntEmptyGrid = 0;




          //////     BOTTOM RIGHT -> TOP LEFT (A cross pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check Bottom Right grids first
            if(tmpChess.xAxis+cnt < lengthOfAxis_X && tmpChess.yAxis+cnt < lengthOfAxis_Y) { //then the top-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis+cnt)] != null){
                Chesspiece bottomRightChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis+cnt)];
                if(bottomRightChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.xAxis-cnt >= 0 && tmpChess.yAxis-cnt >= 0) { //then the top-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis-cnt)] != null){
                Chesspiece topLeftChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis-cnt)];
                if(topLeftChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score -= 300;
                  //  print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead1CheckAlready){
                  condition+=1;
                  // dead1CheckAlready = true;
                  //  print('dead 1 suspect - idx 1');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score -= 2000;
                  //   print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score -= 250;
                  dead2CheckAlready = true;
                  //  print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score -= 2500;
                  //    print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score -= 800;
                  //    print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score -= 16000;
                  //   print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score -= 16000;
                  //    print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     BOTTOM RIGHT -> TOP LEFT (A cross pattern) //////

          //////     BOTTOM LEFT -> TOP RIGHT (A cross pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check Bottom Right grids first
            if(tmpChess.xAxis-cnt > 0 && tmpChess.yAxis+cnt < lengthOfAxis_Y) { //then the bottom-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis+cnt)] != null){
                Chesspiece bottomLeftChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis+cnt)];
                if(bottomLeftChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.xAxis+cnt < lengthOfAxis_X && tmpChess.yAxis-cnt >= 0) { //then the top-right grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis-cnt)] != null){
                Chesspiece topRightChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis-cnt)];
                if(topRightChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score -= 300;
                  //    print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead1CheckAlready){
                  condition+=1;
                  // dead1CheckAlready = true;
                  //    print('dead 1 suspect - idx 2');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score -= 2000;
                  //   print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score -= 250;
                  dead2CheckAlready = true;
                  //   print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score -= 2500;
                  //  print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score -= 800;
                  //    print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score -= 16000;
                  //    print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score -= 16000;
                  //    print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     BOTTOM LEFT -> TOP RIGHT (A cross pattern) //////

          //////     RIGHT -> LEFT (A row pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check Right grids first
            if(tmpChess.xAxis+cnt < lengthOfAxis_X) {
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis)] != null){
                Chesspiece bottomRightChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis+cnt, tmpChess.yAxis)];
                if(bottomRightChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.xAxis-cnt >= 0) { //then the left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis)] != null){
                Chesspiece topLeftChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis-cnt, tmpChess.yAxis)];
                if(topLeftChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1; // Hit the boundary
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score -= 300;
                  //   print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead1CheckAlready){
                  condition+=1;
                  // dead1CheckAlready = true;
                  // print('dead 1 suspect - idx 3');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score -= 2000;
                  // print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score -= 250;
                  dead2CheckAlready = true;
                  // print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score -= 2500;
                  // print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score -= 800;
                  //   print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score -= 16000;
                  //  print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score -= 16000;
                  //  print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     RIGHT -> LEFT (A row pattern) //////

          //////     BOTTOM -> TOP (A cross pattern) //////
          for(int cnt=1;cnt<5;cnt++){ // Check bottom grids first
            if(tmpChess.yAxis+cnt < lengthOfAxis_Y) { //then the bottom-left grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis+cnt)] != null){
                Chesspiece bottomChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis+cnt)];
                if(bottomChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }


          for(int cnt=1;cnt<5;cnt++){
            if(tmpChess.yAxis-cnt >= 0) { //then the top grids
              if(chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis-cnt)] != null){
                Chesspiece topChess = chessPattern[tmpChess.coordToIndex(tmpChess.xAxis, tmpChess.yAxis-cnt)];
                if(topChess.playerOrBot){
                  boundaryHitCnt+=1;
                  break;
                }else{
                  cntContChess+=1;
                }
              }else{
                cntEmptyGrid +=1;
                break;
              }
            }else{
              boundaryHitCnt+=1;
              break;
            }
          }

          switch(cntContChess){
            case 1:
              if(cntEmptyGrid>0 ){
                if(!live1CheckAlready){
                  _score -= 300;
                  //    print('live 1');
                  live1CheckAlready = true;
                }
              }else{ // This is a dead 1
                if(!dead1CheckAlready){
                  condition+=1;
                  if(condition == 4){
                    _score -= 60;
                    dead1CheckAlready = true;
                  }
                  //  print('dead 1 suspect - idx 4');
                }
              }
              break;
            case 2: // This is a live 2
              if(cntEmptyGrid>0 ){
                if(!live2CheckAlready){
                  _score -= 2000;
                  //  print('live 2');
                  live2CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead2CheckAlready){
                  _score -= 250;
                  dead2CheckAlready = true;
                  //    print('dead 2');
                }
              }
              break;
            case 3: // This is a live 3
              if(cntEmptyGrid>0){
                if(!live3CheckAlready){
                  _score -= 2500;
                  //    print('live 3');
                  live3CheckAlready = true;
                }
              }else{ // This is a dead 3
                if(!dead3CheckAlready){
                  _score -= 800;
                  //  print('dead 3');
                  dead3CheckAlready = true;
                }
              }
              break;
            case 4: // This is a live 4
              if(cntEmptyGrid>0){
                if(!live4CheckAlready){
                  _score -= 16000;
                  //  print('live 4');
                  live4CheckAlready = true;
                }
              }else{ // This is a dead 2
                if(!dead4CheckAlready){
                  _score -= 16000;
                  // print('dead 4');
                  dead4CheckAlready = true;
                }
              }
              break;
          }

          boundaryHitCnt = 0;
          cntContChess = 1; // must be initialized after each counting
          cntEmptyGrid = 0;
          //////     BOTTOM -> TOP (A column pattern) //////

        }
      }
      //print('Depth = '+ _depth.toString() +' //// Total Score : ' + _score.toString() + ' ////');

    }
  }


  bool get visited{
    return _visited;
  }

  List<int> get getChildrenIndexList{
    return _childrenIdx;
  }

  int get index{
    return _idx;
  }

  int get score{
    return _score;
  }

  int get parentIdx{
    return _parentIdx;
  }

  int get depth{
    return _depth;
  }

  String get name{
    return _name;
  }


}

// Bluetooth page here ....

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({
    Key key,
    @required this.camera,
  }) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: FlutterBluetoothSerial.instance.requestEnable(),
        builder: (context, future) {
          if (future.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Container(
                height: double.infinity,
                child: Center(
                  child: Icon(
                    Icons.bluetooth_disabled,
                    size: 200.0,
                    color: Colors.blue,
                  ),
                ),
              ),
            );
          } else if (future.connectionState == ConnectionState.done) {
            // return MyHomePage(title: 'Flutter Demo Home Page');
            return Home(camera: camera);
          } else {
            return Home(camera: camera);
          }
        },
        // child: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class Home extends StatelessWidget {
  final CameraDescription camera;

  const Home({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Connection'),
          ),
          body: SelectBondedDevicePage(
            onCahtPage: (device1) {
              BluetoothDevice device = device1;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return MainPage(camera: camera,server: device);
                  },
                ),
              );
            },
          ),
        ));
  }
}

///////////////////////////



class Stack<T> {
  final _stack = Queue<T>();

  void push(T element) {
    _stack.addLast(element);
  }

  T pop() {
    T lastElement = _stack.last;
    _stack.removeLast();
    return lastElement;
  }

  bool isEmpty(){
    if(_stack.isEmpty == true){
      return true;
    }else{
      return false;
    }
  }
}
// BlueTooth Device List here ....
class BluetoothDeviceListEntry extends StatelessWidget {
  final Function onTap;
  final BluetoothDevice device;

  BluetoothDeviceListEntry({this.onTap, @required this.device});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(Icons.devices),
      title: Text(device.name ?? "Unknown device"),
      subtitle: Text(device.address.toString()),
      trailing: FlatButton(
        child: Text('Connect'),
        onPressed: onTap,
        color: Colors.blue,
      ),
    );
  }
}
/////////////////////////////////

// Chat page defined here ....

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}
/////////////////////////////////


// Select bonded Device here ....

class SelectBondedDevicePage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not available, they would be disabled from the selection.
  final bool checkAvailability;
  final Function onCahtPage;

  const SelectBondedDevicePage(
      {this.checkAvailability = true, @required this.onCahtPage});

  @override
  _SelectBondedDevicePage createState() => new _SelectBondedDevicePage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
  List<_DeviceWithAvailability> devices = List<_DeviceWithAvailability>();

  // Availability
  StreamSubscription<BluetoothDiscoveryResult> _discoveryStreamSubscription;
  bool _isDiscovering;

  _SelectBondedDevicePage();

  @override
  void initState() {
    super.initState();

    _isDiscovering = widget.checkAvailability;

    if (_isDiscovering) {
      _startDiscovery();
    }

    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
            device,
            widget.checkAvailability
                ? _DeviceAvailability.maybe
                : _DeviceAvailability.yes,
          ),
        )
            .toList();
      });
    });
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
          setState(() {
            Iterator i = devices.iterator;
            while (i.moveNext()) {
              var _device = i.current;
              if (_device.device == r.device) {
                _device.availability = _DeviceAvailability.yes;
                _device.rssi = r.rssi;
              }
            }
          });
        });

    _discoveryStreamSubscription.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices
        .map(
          (_device) => BluetoothDeviceListEntry(
        device: _device.device,
        onTap: () {
          widget.onCahtPage(_device.device);
        },
      ),
    )
        .toList();
    return ListView(
      children: list,
    );
  }
}

/////////////////////////////

class DetectGridPainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  DetectGridPainter({this.strokeColor = Colors.black, this.strokeWidth = 3, this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, y/4)
      ..moveTo(0, 0)
      ..lineTo(x/4, 0)

      ..moveTo(3*x/4, 0)
      ..lineTo(x, 0)
      ..moveTo(x, 0)
      ..lineTo(x, y/4)

      ..moveTo(0, y)
      ..lineTo(0, 3*y/4)
      ..moveTo(0, y)
      ..lineTo(x/4, y)

      ..moveTo(x, 3*y/4)
      ..lineTo(x, y)
      ..moveTo(x, y)
      ..lineTo(3*x/4, y)

    //
    // ..lineTo(x, y)
    // ..lineTo(x, 0)
        ;
    // ..lineTo(x, 0)
    // ..lineTo(x, y)
    // ..lineTo(0, y);
    // ..lineTo(10,100);
  }

  @override
  bool shouldRepaint(DetectGridPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}