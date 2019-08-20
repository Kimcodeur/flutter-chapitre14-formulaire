import 'package:flutter/material.dart';
import 'package:projet_dyma_end/models/activity_model.dart';
import 'package:projet_dyma_end/providers/city_provider.dart';
import 'package:provider/provider.dart';

class ActivityForm extends StatefulWidget {
  final String cityName;

  ActivityForm({this.cityName});

  @override
  _ActivityFormState createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode _priceFocusNode;
  FocusNode _urlFocusNode;
  Activity _newActivity;
  String _nameInputAsync;
  bool _isLoading = false;
  FormState get form {
    return _formKey.currentState;
  }

  @override
  void initState() {
    _newActivity = Activity(
      city: widget.cityName,
      name: null,
      price: 0,
      image: null,
      status: ActivityStatus.ongoing,
    );
    _priceFocusNode = FocusNode();
    _urlFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    try {
      CityProvider cityProvider = Provider.of<CityProvider>(
        context,
        listen: false,
      );
      _formKey.currentState.save();
      setState(() => _isLoading = true);
      _nameInputAsync = await cityProvider.verifyIfActivityNameIsUnique(
        widget.cityName,
        _newActivity.name,
      );
      if (form.validate()) {
        await cityProvider.addActivityToCity(_newActivity);
        Navigator.pop(context);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              autofocus: true,
              validator: (value) {
                if (value.isEmpty)
                  return 'Remplissez le nom';
                else if (_nameInputAsync != null) return _nameInputAsync;
                return null;
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Nom',
              ),
              onSaved: (value) => _newActivity.name = value,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_priceFocusNode),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              focusNode: _priceFocusNode,
              decoration: InputDecoration(
                hintText: 'Prix',
              ),
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_urlFocusNode),
              validator: (value) {
                if (value.isEmpty) return 'Remplissez le Prix';
                return null;
              },
              onSaved: (value) => _newActivity.price = double.parse(value),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              keyboardType: TextInputType.url,
              focusNode: _urlFocusNode,
              validator: (value) {
                if (value.isEmpty) return 'Remplissez l\'url';
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Url image',
              ),
              onSaved: (value) => _newActivity.image = value,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  child: Text('annuler'),
                  onPressed: () => Navigator.pop(context),
                ),
                RaisedButton(
                  child: Text('sauvegarder'),
                  onPressed: _isLoading ? null : submitForm,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
