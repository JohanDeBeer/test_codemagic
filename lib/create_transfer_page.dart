import 'package:flutter/material.dart';
import 'Classes/CTransfer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTransferPage extends StatefulWidget {
  CreateTransferPage(this.userID);

  final String userID;

  @override
  _CreateTransferPageState createState() => _CreateTransferPageState();
}

enum TransferFormMode { PROPERTY, BUYER, SELLER, SUMMARY }

class _CreateTransferPageState extends State<CreateTransferPage> {
  final _formKey = new GlobalKey<FormState>();

  String _errorMessage;

// Initial form is Property form
  TransferFormMode _formMode = TransferFormMode.PROPERTY;
  bool _isLoading;

  CProperty objProp = new CProperty();

  List<CBuyer> lstBuyer = new List();
  List<CSeller> lstSeller = new List();

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      try {
        var data = ({
          'price': objProp.price,
          'address': objProp.address,
          'RefNum': objProp.refNumber,
          'creatorID': widget.userID,
          'progress': 0.0,
          "CreationDate": FieldValue.serverTimestamp()
        });
        var docRef = await Firestore.instance.collection('Transfer').add(data);

        Firestore.instance
            .collection("TransferProcess")
            .getDocuments()
            .then((doc) {
          doc.documents.forEach((snap) {
            Firestore.instance
                .collection('Transfer')
                .document(docRef.documentID)
                .collection("Steps")
                .add(snap.data);
          });
        });

        lstSeller.forEach((objSeller) {
          var sellerData = ({"ID": docRef.documentID});
          Firestore.instance
              .collection("user")
              .document(objSeller.idNumber)
              .collection("Transfers")
              .add(sellerData);
        });

        lstBuyer.forEach((objBuyer) {
          var sellerData = ({"ID": docRef.documentID});
          Firestore.instance
              .collection("user")
              .document(objBuyer.idNumber)
              .collection("Transfers")
              .add(sellerData);
        });

        print(docRef.documentID);
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    }
  }

  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _changeToBuyer() {
    //_formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = TransferFormMode.BUYER;
    });
  }

  void _changeFormToSeller() {
    setState(() {
      _formMode = TransferFormMode.SELLER;
    });
    //_formKey.currentState.reset();
    _errorMessage = "";
  }

  void _changeFormToSummary() {
    //_formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = TransferFormMode.SUMMARY;
    });
  }

  void _changeFormToProperty() {
    //_formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = TransferFormMode.PROPERTY;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: <Widget>[
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showBody() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: _showPage(),
          ),
        ));
  }

  List<Widget> _showPage() {
    List<Widget> lstReturn = new List();
    switch (_formMode) {
      case TransferFormMode.PROPERTY:
        {
          //lstReturn.add(_showSummary());
          lstReturn.add(_showPropertyHeading());
          lstReturn.add(_showAddressInput());
          lstReturn.add(_showRefInput());
          lstReturn.add(_showPriceInput());
          lstReturn.add(_showSellerCountInput());
          lstReturn.add(_showBuyerCountInput());
          lstReturn.add(_showNextForm());
        }
        break;
      case TransferFormMode.SELLER:
        {
          //lstReturn.add(_showSummary());
          lstReturn.add(_showSellerHeading());
          lstReturn.add(_showSellerForm());
          lstReturn.add(_showNextForm());
        }
        break;
      case TransferFormMode.BUYER:
        {
          //lstReturn.add(_showSummary());
          lstReturn.add(_showBuyerHeading());
          lstReturn.add(_showBuyerForm());
          lstReturn.add(_showNextForm());
        }
        break;
      case TransferFormMode.SUMMARY:
        {
          lstReturn.add(_showSummaryHeading());
          lstReturn.add(_showSummary());
          lstReturn.add(_showSubmitButton());
        }
    }
    return lstReturn;
  }

  TextStyle _headingText() {
    return TextStyle(fontSize: 30);
  }

  Widget _showSummaryHeading() {
    return Text(
      "Summary",
      style: _headingText(),
    );
  }

  Widget _showSellerHeading() {
    return Text(
      "Seller Information",
      style: _headingText(),
    );
  }

  Widget _showBuyerHeading() {
    return Text(
      "Buyer Information",
      style: _headingText(),
    );
  }

  Widget _showPropertyHeading() {
    return Text(
      "Property Information",
      style: _headingText(),
    );
  }

  Widget _showSubmitButton() {
    return RaisedButton(
      onPressed: () {
        _validateAndSubmit();
        //Navigator.pop(context);
      },
      child: Text("Pay & Submit"),
    );
  }

  Widget _showSummary() {
    return Column(
      children: <Widget>[
        Text("Adrress: ${objProp.address.toString()}"),
        Text("RefNum: ${objProp.refNumber.toString()}"),
        Text("Sellers: ${objProp.sellerCount.toString()}"),
        Text("Buyers: ${objProp.buyerCount.toString()}"),
        _showSellerSummary(),
        _showBuyerSummary(),
      ],
    );
  }

  Widget _showSellerSummary() {
    List<Widget> lstReturn = new List();
    lstReturn.add(Text("Sellers:"));
    if (lstSeller.length > 0) {
      lstSeller.forEach((objSeller) {
        lstReturn.add(Card(
            child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Text("Name: ${objSeller.name}"),
              Text("ID: ${objSeller.idNumber.toString()}"),
              Text("Number: ${objSeller.number.toString()}"),
              Text("Email: ${objSeller.email.toString()}"),
            ],
          ),
        )));
      });
    }
    return Column(
      children: lstReturn,
    );
  }

  Widget _showBuyerSummary() {
    List<Widget> lstReturn = new List();
    lstReturn.add(Text("Buyers:"));
    if (lstBuyer.length > 0) {
      lstBuyer.forEach((objBuyer) {
        lstReturn.add(Card(
            child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Text("Name: ${objBuyer.name}"),
              Text("ID: ${objBuyer.idNumber.toString()}"),
              Text("Number: ${objBuyer.number.toString()}"),
              Text("Email: ${objBuyer.email.toString()}"),
            ],
          ),
        )));
      });
    }

    return Column(
      children: lstReturn,
    );
  }

  Widget _showNextForm() {
    return RaisedButton(
      onPressed: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        if (_validateAndSave()) {
          switch (_formMode) {
            case TransferFormMode.PROPERTY:
              {
                _changeFormToSeller();
              }
              break;
            case TransferFormMode.SELLER:
              {
                _changeToBuyer();
                _removeExtraSellers();
              }
              break;
            case TransferFormMode.BUYER:
              {
                _changeFormToSummary();
                _removeExtraBuyers();
              }
              break;
            case TransferFormMode.SUMMARY:
              {
                _changeFormToProperty();
              }
          }
        }
      },
      child: Text("Next"),
    );
  }

  _removeExtraSellers() {
    lstSeller.removeWhere((objSeller) => objSeller.idNumber == null);
  }

  _removeExtraBuyers() {
    lstBuyer.removeWhere((objBuyer) => objBuyer.idNumber == null);
  }

  Widget _showBuyerForm() {
    return Column(
      children: _buyers(),
    );
  }

  List<Widget> _buyers() {
    List<Widget> lstReturn = new List();
    for (var i = 0; i < int.parse(objProp.buyerCount); i++) {
      CBuyer objBuyer = new CBuyer();
      lstBuyer.add(objBuyer);
      lstReturn.add(Card(
          child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            _showBuyerNameInput(i),
            _showBuyerIDInput(i),
            _showBuyerNumberInput(i),
            _showBuyerEmailInput(i),
          ],
        ),
      )));
    }
    return lstReturn;
  }

  Widget _showBuyerEmailInput(int index) {
    CBuyer thisBuyer = lstBuyer.elementAt(index);
    TextEditingController _textController = initialValue(thisBuyer.email);
    _textController.addListener(() {
      thisBuyer.email = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        onEditingComplete: () {
          thisBuyer.email = _textController.text;
        },
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Buyer Email Address',
        ),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => thisBuyer.email = value,
      ),
    );
  }

  Widget _showBuyerNameInput(int index) {
    CBuyer thisBuyer = lstBuyer.elementAt(index);
    TextEditingController _textController = initialValue(thisBuyer.name);
    _textController.addListener(() {
      thisBuyer.name = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        maxLines: 1,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Buyer Name',
        ),
        validator: (value) => value.isEmpty ? 'Name can\'t be empty' : null,
        onSaved: (value) => thisBuyer.name = _textController.text,
      ),
    );
  }

  Widget _showBuyerNumberInput(int index) {
    CBuyer thisBuyer = lstBuyer.elementAt(index);
    TextEditingController _textController = initialValue(thisBuyer.number);
    _textController.addListener(() {
      thisBuyer.number = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        onEditingComplete: () {
          thisBuyer.number = _textController.text;
        },
        maxLines: 1,
        keyboardType: TextInputType.number,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Buyer Phone Number',
        ),
        validator: (value) =>
            value.isEmpty ? 'Phone Number can\'t be empty' : null,
        onSaved: (value) => thisBuyer.number = value,
      ),
    );
  }

  Widget _showBuyerIDInput(int index) {
    CBuyer thisBuyer = lstBuyer.elementAt(index);
    TextEditingController _textController = initialValue(thisBuyer.idNumber);
    _textController.addListener(() {
      thisBuyer.idNumber = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        maxLines: 1,
        keyboardType: TextInputType.number,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Buyer ID Number',
        ),
        validator: (value) =>
            value.isEmpty ? 'ID Number can\'t be empty' : null,
        onSaved: (value) => thisBuyer.idNumber = value,
      ),
    );
  }

  Widget _showSellerForm() {
    return Column(
      children: _sellers(),
    );
  }

  List<Widget> _sellers() {
    List<Widget> lstReturn = new List();
    for (var i = 0; i < int.parse(objProp.sellerCount); i++) {
      CSeller objSeller = new CSeller();
      lstSeller.add(objSeller);
      lstReturn.add(Card(
          child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            _showSellerNameInput(i),
            _showSellerIDInput(i),
            _showSellerNumberInput(i),
            _showSellerEmailInput(i),
          ],
        ),
      )));
    }
    return lstReturn;
  }

  Widget _showSellerEmailInput(int index) {
    CSeller thisSeller = lstSeller.elementAt(index);
    TextEditingController _textController = initialValue(thisSeller.email);
    _textController.addListener(() {
      thisSeller.email = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Seller Email',
        ),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: ((value) {
          thisSeller.email = value;
        }),
      ),
    );
  }

  Widget _showSellerIDInput(int index) {
    CSeller thisSeller = lstSeller.elementAt(index);
    TextEditingController _textController = initialValue(thisSeller.idNumber);
    _textController.addListener(() {
      thisSeller.idNumber = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        maxLines: 1,
        keyboardType: TextInputType.number,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Seller ID Number',
        ),
        validator: (value) =>
            value.isEmpty ? 'ID Number can\'t be empty' : null,
        onSaved: ((value) {
          thisSeller.idNumber = value;
        }),
      ),
    );
  }

  Widget _showSellerNumberInput(int index) {
    CSeller thisSeller = lstSeller.elementAt(index);
    TextEditingController _textController = initialValue(thisSeller.number);
    _textController.addListener(() {
      thisSeller.number = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        maxLines: 1,
        keyboardType: TextInputType.number,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Seller Phone Number',
        ),
        validator: (value) =>
            value.isEmpty ? 'Phone Number can\'t be empty' : null,
        onSaved: (value) => thisSeller.number = value,
      ),
    );
  }

  Widget _showSellerNameInput(int index) {
    CSeller thisSeller = lstSeller.elementAt(index);
    TextEditingController _textController = initialValue(thisSeller.name);
    _textController.addListener(() {
      thisSeller.name = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        maxLines: 1,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Seller Name',
        ),
        validator: (value) => value.isEmpty ? 'Name can\'t be empty' : null,
        onSaved: (value) => thisSeller.name = value,
      ),
    );
  }

  Widget _showPriceInput() {
    String placeholder = objProp.price;
    TextEditingController _textController = initialValue(placeholder);
    _textController.addListener(() {
      objProp.price = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        maxLines: 1,
        autofocus: false,
        keyboardType: TextInputType.number,
        decoration: new InputDecoration(
            hintText: 'Price',
            labelText: 'Price',
            icon: Icon(Icons.attach_money)),
        validator: (value) => value.isEmpty ? 'Price can\'t be empty' : null,
        onSaved: (value) => objProp.price = value,
      ),
    );
  }

  Widget _showBuyerCountInput() {
    String placeholder = objProp.buyerCount;
    TextEditingController _textController = initialValue(placeholder);
    _textController.addListener(() {
      objProp.buyerCount = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        maxLines: 1,
        maxLength: 2,
        autofocus: false,
        keyboardType: TextInputType.number,
        decoration: new InputDecoration(
            hintText: 'Buyer Count', labelText: 'Buyer Count'),
        validator: (value) =>
            value.isEmpty ? 'Buyer Count can\'t be empty' : null,
        onSaved: (value) => objProp.buyerCount = value,
      ),
    );
  }

  Widget _showSellerCountInput() {
    String placeholder = objProp.sellerCount;
    TextEditingController _textController = initialValue(placeholder);
    _textController.addListener(() {
      objProp.sellerCount = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        maxLines: 1,
        maxLength: 2,
        autofocus: false,
        keyboardType: TextInputType.number,
        decoration: new InputDecoration(
            hintText: 'Seller Count', labelText: 'Seller Count'),
        validator: (value) =>
            value.isEmpty ? 'Seller Count can\'t be empty' : null,
        onSaved: ((value) {
          objProp.sellerCount = value;
        }),
      ),
    );
  }

  Widget _showAddressInput() {
    String placeholder = objProp.address;
    TextEditingController _textController = initialValue(placeholder);
    _textController.addListener(() {
      objProp.address = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        maxLines: 1,
        autofocus: false,
        decoration:
            new InputDecoration(hintText: 'Address', labelText: 'Address'),
        validator: (value) => value.isEmpty ? 'Address can\'t be empty' : null,
        onSaved: (value) => objProp.address = value,
      ),
    );
  }

  initialValue(val) {
    return TextEditingController(text: val);
  }

  Widget _showRefInput() {
    TextEditingController _textController = initialValue(objProp.refNumber);
    _textController.addListener(() {
      objProp.refNumber = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        maxLines: 1,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Reference Number',
          labelText: 'Reference Number',
        ),
        validator: (value) =>
            value.isEmpty ? 'Reference Number can\'t be empty' : null,
        onSaved: (value) => objProp.refNumber = value,
      ),
    );
  }
}
