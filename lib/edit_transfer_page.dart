import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Classes/CTransfer.dart';

class EditTransferPage extends StatefulWidget {
  EditTransferPage({this.transDoc});

  final DocumentSnapshot transDoc;

  @override
  _EditTransferPageState createState() => _EditTransferPageState();
}

class _EditTransferPageState extends State<EditTransferPage> {
  CProperty objProp = new CProperty();

  String _errorMessage;
  bool _isLoading;


  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    objProp.address = widget.transDoc['address'];
    objProp.refNumber = widget.transDoc['RefNum'];
    objProp.price = widget.transDoc['price'];
    super.initState();
  }

  final _formKey = new GlobalKey<FormState>();

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
          'RefNum': objProp.refNumber
        });
        await Firestore.instance
            .collection('Transfer')
            .document(widget.transDoc.documentID)
            .updateData(data);
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    }
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
    return Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: _showPage(),
          ),
        ));
  }

  initialValue(val) {
    return TextEditingController(text: val);
  }

  List<Widget> _showPage() {
    List<Widget> lstReturn = new List();
    lstReturn.add(_showRefInput());
    lstReturn.add(_showAddressInput());
    lstReturn.add(_showPriceInput());
    lstReturn.add(_showSubmitButton());
    return lstReturn;
  }

  Widget _showAddressInput() {
    String placeholder = objProp.address;
    TextEditingController _textController = initialValue(placeholder);
    _textController.selection =
        TextSelection.collapsed(offset: _textController.text.length);
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

  Widget _showRefInput() {
    String placeholder = objProp.refNumber;
    TextEditingController _textController = initialValue(placeholder);
    _textController.selection =
        TextSelection.collapsed(offset: _textController.text.length);
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
            hintText: 'Reference Number', labelText: 'Reference Number'),
        validator: (value) =>
            value.isEmpty ? 'Reference Number can\'t be empty' : null,
        onSaved: (value) => objProp.refNumber = value,
      ),
    );
  }

  Widget _showPriceInput() {
    String placeholder = objProp.price;
    TextEditingController _textController = initialValue(placeholder);
    _textController.selection =
        TextSelection.collapsed(offset: _textController.text.length);
    _textController.addListener(() {
      objProp.price = _textController.text;
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: _textController,
        keyboardType: TextInputType.number,
        maxLines: 1,
        autofocus: false,
        decoration: new InputDecoration(hintText: 'Price', labelText: 'Price'),
        validator: (value) => value.isEmpty ? 'Price can\'t be empty' : null,
        onSaved: (value) => objProp.price = value,
      ),
    );
  }

  Widget _showSubmitButton() {
    return RaisedButton(
      onPressed: () {
        _validateAndSubmit();
        Navigator.pop(context);
      },
      child: Text("Save"),
    );
  }
}
