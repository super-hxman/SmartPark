import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:smartpark/Model/System.dart';
import 'package:smartpark/Model/User.dart';
import 'package:smartpark/Model/Vehicle.dart';
import 'package:smartpark/RouteTransition.dart';
import 'package:smartpark/Screen/PageChangeReservation.dart';
import 'package:smartpark/Screen/PageHome.dart';
import 'package:smartpark/Screen/PageMap.dart';
import 'package:smartpark/Screen/PageSlotDirection.dart';
import 'package:smartpark/Widget/WidgetBottomNavigation.dart';
import 'package:smartpark/Widget/WidgetCountDownTimer.dart';

class WidgetReservation extends StatefulWidget {
  WidgetReservation({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _WidgetReservationState createState() => _WidgetReservationState();
}

class _WidgetReservationState extends State<WidgetReservation> {
  final User _user = User();
  final Vehicle _vehicle = Vehicle();
  final System _system = System();

  int _reservationStatus;
  String _chosenVehicle;

  DateFormat dateFormat = DateFormat("MMM d, yyyy");
  DateFormat timeFormat = DateFormat("HH: mm");

  void _dialogPaymentFailed(){
    Alert(
      context: context,
      type: AlertType.error,
      title: "OH NO!",
      desc: "You do not have enough credits.",
      buttons: [
        DialogButton(
          color: Colors.red,
          child: Text(
            "OK",
            style: TextStyle(
              color: Colors.white, 
              fontSize: 20
            ),
          ),
          onPressed: () => Navigator.pushAndRemoveUntil(context, RouteTransition(page: WidgetBottomNavigation()), (route) => false),
          width: 120,
        )
      ],
    ).show();
  } 

  void _dialogPaymentSuccessful(price){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return  AlertDialog(
          //title:
            content: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Divider(),Text("Thank You!",style: TextStyle(color: Colors.green),),
                Text("Your transaction was successful"),
                Divider(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "DATE",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        "TIME",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(dateFormat.format(DateTime.now())),
                      Text(timeFormat.format(DateTime.now())),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "AMOUNT",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                          Text("Rs " + price.toString()),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("OK"),
                onPressed: () async {
                   Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => PageHome()),
                    (Route<dynamic> route) => true,
                  );
                },
              ),
            ],
          );
      }
    );
  }

  void _dialogMakePayment(fee){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return FutureBuilder<dynamic>(
          future: _user.getReservationDetails(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if (snapshot.connectionState == ConnectionState.done){
              return  AlertDialog(
              //title:
                content: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Make Payment",
                      style: TextStyle(
                        fontWeight: FontWeight.w700
                      ),
                    ),
                    Divider(),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "DATE",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              dateFormat.format(snapshot.data["reservationDate"].toDate()),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "TIME",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                            Text(timeFormat.format(snapshot.data["reservationStartTime"].toDate()) + " - " + timeFormat.format(snapshot.data["reservationEndTime"].toDate())),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "AMOUNT",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                            Text("Rs " + fee.toString()),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.red
                      ),
                    ),
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                  ),
                  new RaisedButton(
                    color: hex("#8860d0"),
                    child: new Text("OK"),
                    onPressed: () async {
                      var result = await _user.makePayment(fee, "cancelled");
                      Navigator.of(context).pop();
                      if (result){
                        _dialogPaymentSuccessful(fee);
                      }
                      else{
                        _dialogPaymentFailed();
                      }
                    },
                  ),
                ],
              );
            }
            else{
              return Container();
            }
          }
        );
      }
    );
  }


  Widget vehicles(){
    return Container(
      height: 200,
      width: 300,
      child: FutureBuilder<dynamic>(
        future: _vehicle.getVehiclePlateNumbers(),
        builder: (context, snap){
          if (snap.connectionState == ConnectionState.done){
            return Container(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snap.data.length,
                  itemBuilder: (context, index){
                    return GestureDetector(
                      onTap: () async{
                        await _user.changeVehicle(snap.data[index]);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 100,
                        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: _chosenVehicle == snap.data[index] ?  BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          border: Border.all(
                            color: hex("#84ceeb"),
                            width: 2
                          )
                        ) : BoxDecoration(
                          border: Border.all(color: Colors.white)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.directions_car,
                              color: hex("#5680e9"),
                            ),
                            Text(
                              snap.data[index]
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                
              ),
            );
          }
          return Container();
        }
      ),
    );
  }

  void _dialogChangeVehicle(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Choose another vehicle"),
          content: vehicles(),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "CANCEL",
                style: TextStyle(
                  color: Colors.red
                ),
              ),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  void _dialogCancelReservation(parkingLotID, startTime, endTime){
    Alert(
      context: context,
      type: AlertType.warning,
      title: "",
      desc: "Are you sure you want to cancel your reservation?",
      buttons: [
        DialogButton(
          color: Colors.white,
          child: Text(
            "Dismiss",
            style: TextStyle(
              color: Colors.red, 
              fontSize: 20
            ),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        ),
        DialogButton(
          color: Colors.red,
          child: Text(
            "Confirm",
            style: TextStyle(
              color: Colors.white, 
              fontSize: 20
            ),
          ),
          onPressed: () async{
            var fee = await _system.calculateFee(parkingLotID, startTime, endTime, endTime, "cancelled");
            Navigator.of(context).pop();
            return _dialogMakePayment(fee);
          },
          width: 120,
        )
      ],
    ).show();
  }  

  Widget _timer(int status, DateTime startTime, DateTime endTime){
    if (status == 1){
      if (DateTime.now().isAfter(startTime)){
        _system.setReservationOngoing();
        // Navigator.push(context, RouteTransition(page: PageHome()));
        return _countdownTo(DateTime.now(), endTime, Colors.red);
      }
      return _countdownTo(DateTime.now(), startTime, hex("#5ab9ea"));
    }
    else if (status == 2){
      return _countdownTo(DateTime.now(), endTime, Colors.red);
    }
    else if (status == 3){
      // return _countdownTo(DateTime.now(), endTime, hex("#5ab9ea"));
      Navigator.push(context, RouteTransition(page: PageHome()));
    }
  }

  Widget _countdownTo(DateTime startTime, DateTime endTime, Color color){
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 0),
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Center(
              child: WidgetCountDownTimer(
                secondsRemaining: endTime.difference(startTime).inSeconds,
                whenTimeExpires: (){

                 },
                countDownTimerStyle: TextStyle(
                  color: color,
                  fontSize: 50
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _btnCancelReservation(parkingLotID, startTime, endTime){
    return FlatButton(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Text(
        'Cancel Reservation?',
        style: TextStyle(color: hex("#5680e9")),
      ),
      onPressed: () {
        _dialogCancelReservation(parkingLotID, startTime, endTime);
      },
    );
  }

  Widget _reservationDetails(){
    return FutureBuilder<dynamic>(
      future: _user.getReservationDetails(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if (snapshot.connectionState == ConnectionState.done){
          _reservationStatus = snapshot.data["reservationStatus"];

          DateFormat dateFormat = DateFormat("MMM d, yyyy");
          DateTime dtDate = snapshot.data["reservationDate"].toDate();
          String date = dateFormat.format(dtDate);

          DateFormat timeFormat = DateFormat("HH: mm");
          DateTime dtStartTime = snapshot.data["reservationStartTime"].toDate();
          String startTime = timeFormat.format(dtStartTime);
          DateTime dtEndTime = snapshot.data["reservationEndTime"].toDate();
          String endTime = timeFormat.format(dtEndTime);

          return Center(
            child: Container(
              alignment: Alignment(0.0, 0.0),
              height: 800,
              // child: Card(
              //   color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: ListView(
                    children: <Widget>[
                      _timer(_reservationStatus, dtStartTime, dtEndTime),
                      SizedBox(height: 30,),
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.directions_car,
                            color: hex("#5680e9"),
                          ),
                          title: Text(snapshot.data["vehicleID"]),
                          trailing: Icon(
                            Icons.edit,
                            color: hex("#34ceeb"),
                          ),
                          onTap: (){
                            return _dialogChangeVehicle();
                          },
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.access_time,
                            color: hex("#5680e9"),
                          ),
                          title: Text(startTime + " - " + endTime),
                          subtitle: Text(date),
                          trailing: Icon(
                            Icons.edit,
                            color: hex("#34ceeb"),
                          ),
                          onTap: (){
                            Navigator.push(context, RouteTransition(page: PageChangeReservation(date: date, startTime: startTime, endTime: endTime,)));
                          },
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.local_parking,
                            color: hex("#5680e9"),
                          ),
                          title: Text("Slot " + snapshot.data["parkingSlotID"]),
                          subtitle: Text("Lot " + snapshot.data["parkingLotID"]),
                          trailing: Icon(
                            Icons.location_on,
                            color: hex("#f172a1"),
                          ),
                          onTap: (){
                            Navigator.push(context, RouteTransition(page: PageSlotDirection(parkingSlotID: snapshot.data["parkingSlotID"])));
                          },
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.attach_money,
                            color: hex("#5680e9")
                          ),
                          title: Text("Rs " + snapshot.data["reservationFee"].toString()),
                        ),
                      ),
                      _btnCancelReservation(snapshot.data["parkingLotID"], snapshot.data["reservationStartTime"].toDate(), snapshot.data["reservationEndTime"].toDate()),
                    ],
                  ),
                ),
              ),
            // ),
          );
        }
        else{
          return Container();
        }
      }
    );
  }

  Widget _btnLotLocation(){
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FloatingActionButton.extended(
          icon: Icon(Icons.location_on),
          backgroundColor: hex("#f172a1"),
          label: Text("Parking Lot"),
          onPressed: (){
            Navigator.push(context, RouteTransition(page: PageMap()));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "Your reservation",
          style: TextStyle(
            color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5.0,
      ),
      body: Stack(
        children: <Widget>[
          _reservationDetails(),
          _btnLotLocation(),
        ],
      ),
    );
  }
}