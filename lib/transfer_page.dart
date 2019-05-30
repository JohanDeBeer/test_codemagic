import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TransferPage extends StatefulWidget {
  TransferPage({this.transDoc});

  final DocumentSnapshot transDoc;

  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  double _completionPersentage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: _buildBody(),
      ),
    );
  }

  Widget _topCard() {
    return new CircularPercentIndicator(
      radius: 100.0,
      lineWidth: 7.0,
      percent: _completionPersentage,
      center: new Text("${(_completionPersentage * 100).floor()}%"),
      progressColor: Colors.blue,
      animation: true,
      animateFromLastPercent: true,
    );
  }

  Widget _buildPropCard() {
    return new Card(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("Address: ${widget.transDoc.data['address']}"),
              Text("Ref: ${widget.transDoc.data['RefNum']}"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("Price: R${widget.transDoc.data['price']}"),
              //Text("Address: ${widget.transDoc.data['address']}"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("Transfer")
          .document(widget.transDoc.documentID)
          .collection("Steps")
          .orderBy('Index')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Container(
            child: Text(
              "Error, no Steps found",
              style: TextStyle(fontSize: 30),
            ),
          );
        } else {
          _completionPersentage = _getCompletionAmount(snapshot.data);
          return Column(
            children: <Widget>[
              _topCard(),
              _buildPropCard(),
              Flexible(
                child: ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot stepDoc = snapshot.data.documents[index];
                      bool _complete =
                          stepDoc['Status'] == 'Pending' ? false : true;
                      return Card(
                        child: InkWell(
                          //onTap: () => _openTransferPage(context, transDoc),
                          child: CheckboxListTile(
                            title: Text(stepDoc['Name']),
                            subtitle: Text(
                              stepDoc['Status'].toString(),
                              style: TextStyle(
                                color: stepDoc['Status'] == 'Pending'
                                    ? Colors.amber
                                    : Colors.green,
                              ),
                            ),
                            value: _complete,
                            onChanged: (value) {
                              if (value) {
                                _showDialog(context, stepDoc);

                              }
                            },
                          ),
                        ),
                      );
                    }),
              ),
            ],
          );
        }
      },
    );
  }

  double _getCompletionAmount(QuerySnapshot snap) {
    int totalVal = 0;
    int compVal = 0;
    if (snap.documents.length > 0) {
      snap.documents.forEach((doc) {
        totalVal = totalVal + doc["Value"];
        if (doc["Status"] == "Complete") {
          compVal = compVal + doc["Value"];
        }
      });
      var documentReference = Firestore.instance
          .collection("Transfer")
          .document(widget.transDoc.documentID);
      double progress = (compVal / totalVal);
      print(progress);
      var data = ({
        'progress':progress,
      });
      Firestore.instance
          .runTransaction((trans) async {
        await trans
            .update(documentReference, data);
      });
      return progress;
    } else {
      return 0.0;
    }
  }
  Widget _amountInput (){
    return TextField();
  }

  Future _showDialog(BuildContext context, DocumentSnapshot stepDoc){
    return showDialog(
        context: context,
      builder: (BuildContext context){
          return AlertDialog(
            title: Text("Are You Sure?"),
            content: Container(
              height: 120,
              width: 100,
              child: ListView(
                children: <Widget>[
                  Text("Are You Sure you want to complete this step?"),
                  stepDoc["input"] ? _amountInput() : null,
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: Text("Cancel")),
              FlatButton(onPressed: (){
                var documentReference = Firestore.instance
                    .collection("Transfer")
                    .document(widget.transDoc.documentID)
                    .collection("Steps")
                    .document(stepDoc.documentID);

                var data = ({
                  "Status": "Complete",
                  "TimeStamp": FieldValue.serverTimestamp()
                });

                Firestore.instance
                    .runTransaction((trans) async {
                  await trans
                      .update(documentReference, data)
                      .then((val) {});
                });
                Navigator.of(context).pop();
              }, child: Text("Confirm")),
            ],
          );
      }
    );
  }
}
