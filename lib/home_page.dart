import 'package:flutter/material.dart';
import 'authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transfer_page.dart';
import 'edit_transfer_page.dart';
import 'create_transfer_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: _signOut)
        ],
      ),
      body: _buildBody(),
      floatingActionButton: RaisedButton(
        shape: CircleBorder(),
        color: Colors.blue,
        padding: EdgeInsets.all(10),
        onPressed: () => _openCreateTransferPage(widget.userId),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder(
        stream: Firestore.instance.collection('Transfer').where('creatorID',isEqualTo: widget.userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Container(
              child: Text(
                "Loading",
                style: TextStyle(fontSize: 40),
              ),
            );
          } else if(snapshot.data.documents.length == 0){
            return Container(
              child: Text(
                "No Transfers",
                style: TextStyle(fontSize: 40),
              ),
            );
          }else {
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot transDoc = snapshot.data.documents[index];
                  return Card(
                    child: InkWell(
                      onTap: () => _openTransferPage(context, transDoc),
                      child: ListTile(
                        title: Text(transDoc['RefNum']),
                        subtitle: Text(transDoc['address']),
                        trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _openEditTransferPage(context, transDoc)
                            ),
                      ),
                    ),
                  );
                });
          }
        });
  }

  _openTransferPage(BuildContext context, DocumentSnapshot transDoc){
    return Navigator.push(context,
        MaterialPageRoute(builder: (context) => TransferPage(transDoc: transDoc)));
  }
  _openEditTransferPage(BuildContext context, DocumentSnapshot transDoc){
    return Navigator.push(context,
        MaterialPageRoute(builder: (context) => EditTransferPage(transDoc: transDoc)));
  }
  
  _openCreateTransferPage(String userId){
    return Navigator.push(context,
        MaterialPageRoute(builder: (context) => CreateTransferPage(userId)));
  }
}
