import 'package:bitcoin_ticker/coin_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

const main = 'https://rest.coinapi.io/v1/exchangerate';
const apikey = '056C4479-E4F5-4A33-9FFD-A3FC2DF7D18B';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'AUD',
      value1 = '?',
      value2 = '?',
      value3 = '?',
      base1 = 'BTC',
      base2 = 'ETH',
      base3 = 'LTC';
  double rateValue;

  DropdownButton<String> androidDropDown() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String currency in currenciesList) {
      var newItem = DropdownMenuItem(
        child: Text(currency),
        value: currency,
      );
      dropDownItems.add(newItem);
    }

    return DropdownButton<String>(
      value: selectedCurrency,
      items: dropDownItems,
      onChanged: (value) {
        setState(() {
          selectedCurrency = value;
          updateValues();
        });
      },
    );
  }

  CupertinoPicker iOSPicker() {
    List<Text> cupertinoPickerItems = [];
    for (String currency in currenciesList) {
      var newItem = Text(currency);
      cupertinoPickerItems.add(newItem);
    }

    return CupertinoPicker(
      backgroundColor: Colors.lightBlue,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          selectedCurrency = currenciesList[selectedIndex];
          updateValues();
        });
      },
      children: cupertinoPickerItems,
    );
  }

  Future<String> getURLsRateValue(String base, String selectedCurrency) async {
    String url = '$main/$base/$selectedCurrency?apikey=$apikey';
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      rateValue = jsonResponse['rate'];
    } else {
      print(response.statusCode);
      rateValue = null;
    }

    return rateValue.toInt().toString();
  }

  @override
  void initState() {
    super.initState();
    updateValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('🤑 Coin Ticker'),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardWidget(
                base: base1,
                value: value1,
                selectedCurrency: selectedCurrency,
              ),
              CardWidget(
                base: base2,
                value: value2,
                selectedCurrency: selectedCurrency,
              ),
              CardWidget(
                base: base3,
                value: value3,
                selectedCurrency: selectedCurrency,
              ),
            ],
          ),
          Container(
              height: 100.0,
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 30.0),
              color: Colors.lightBlue,
              child: Platform.isIOS ? iOSPicker() : androidDropDown()),
        ],
      ),
    );
  }

  void updateValues() async {
    value1 = '?';
    value2 = '?';
    value3 = '?';
    var a = await getURLsRateValue(base1, selectedCurrency);
    var b = await getURLsRateValue(base2, selectedCurrency);
    var c = await getURLsRateValue(base3, selectedCurrency);
    setState(() {
      value1 = a;
      value2 = b;
      value3 = c;
    });
  }
}

class CardWidget extends StatelessWidget {
  CardWidget(
      {@required this.selectedCurrency,
      @required this.base,
      @required this.value});

  String selectedCurrency, base, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Text(
            '1 $base = $value $selectedCurrency',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
