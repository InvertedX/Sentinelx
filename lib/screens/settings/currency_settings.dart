import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/exchange/currencies.dart';
import 'package:sentinelx/shared_state/rate_state.dart';

class CurrencySettings extends StatefulWidget {
  @override
  _CurrencySettingsState createState() => _CurrencySettingsState();
}

class _CurrencySettingsState extends State<CurrencySettings> {
  bool loading = false;
  String selectedCurrency;

  @override
  Widget build(BuildContext context) {
     selectedCurrency = RateState().provider.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text("Currency settings"),
        bottom: UnderProgress(loading),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        children: <Widget>[
          Divider(),
          ListTile(
            title: Text("Rate provider"),
            subtitle: Text("Select exchange for fiat price"),
            onTap: showProvider,
          ),
          Divider(),
          ListTile(
            title: Text("Select currency"),
            subtitle: Text("$selectedCurrency"),
            onTap: showCurrencyChooser,
          ),
          Divider(),
        ],
      ),
    );
  }

  void showCurrencyChooser() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Card(
            margin:  const EdgeInsets.all(8.0),
            child: Consumer<RateState>(
              builder: (context, rateState, _) {
                return Container(
                  height: double.infinity,
                  child: ListView.separated(
                    separatorBuilder: (b, c) => Divider(height: 1,),
                    itemBuilder: (BuildContext context, int i) {
                      String curr = rateState.provider.availableCurrencies[i];
                      return ListTile(
                        title: Text(curr),
                        trailing: selectedCurrency ==  curr  ? Icon(Icons.check,color: Colors.greenAccent,): SizedBox.shrink(),
                        onTap: () {
                          this.setCurrency(rateState.provider.availableCurrencies[i]);
                        },
                      );
                    },
                    itemCount: rateState.provider.availableCurrencies.length,
                  ),
                );
              },
            ),
          );
        });
  }

  void setCurrency(String currency) async {
    PrefsStore().put(PrefsStore.CURRENCY, currency);
    setState(() {
      loading = true;
      selectedCurrency = currency;
    });
    Navigator.pop(context);
    await RateState().setCurrency(currency);
    setState(() {
      loading = false;
    });
  }

  showProvider  () {
    List<String> providers = ["LocalBitcoins"];
    String radioGroup = "LocalBitcoins";
    showModalBottomSheet(
        context: context,
        builder: (context){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Wrap(
                direction: Axis.horizontal,
                children: providers.map((provider) {
                  return ListTile(
                    dense: true,
                    onTap: () {
//                      onSelect(timeout);
                    },
                    title: Text('$provider'),
                    trailing: Radio(
                      value: provider,
                      groupValue: radioGroup,
                      onChanged: (va){},
                    ),
                  );
                }).toList(),
              ),
            ),
          );
    });
  }
}

class UnderProgress extends StatelessWidget implements PreferredSizeWidget {
  final bool loading;

  UnderProgress(this.loading);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: loading ? 1 : 0,
      duration: Duration(milliseconds: 600),
      child: Container(
        height: 1,
        child: LinearProgressIndicator(),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size(double.infinity, 1);
}
