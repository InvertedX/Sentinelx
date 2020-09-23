import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/exchange/exchange_provider.dart';
import 'package:sentinelx/shared_state/rate_state.dart';
import 'package:sentinelx/shared_state/view_model_provider.dart';
import 'package:sentinelx/widgets/appbar_bottom_progress.dart';

class CurrencySettings extends StatefulWidget {
  @override
  _CurrencySettingsState createState() => _CurrencySettingsState();
}

class _CurrencySettingsState extends State<CurrencySettings> {
  bool loading = false;
  String selectedCurrency;
  String selectedPeriod;

  @override
  Widget build(BuildContext context) {
    RateState rateState = Provider.of<RateState>(context);
    try {
      selectedCurrency = Provider.of<RateState>(context).provider.currency;
      selectedPeriod = Provider.of<RateState>(context).provider.getSelectedPeriod();
    } catch (e) {}
    return Scaffold(
      appBar: AppBar(
        title: Text("Currency settings"),
        bottom: AppBarUnderProgress(loading),
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
          ListTile(
            title: Text("Rate period"),
            subtitle: Text(rateState.provider.getSelectedPeriod() == null ? "Default" : rateState.provider.getSelectedPeriod()),
            onTap: showRatePeriodChooser,
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
            margin: const EdgeInsets.all(8.0),
            child: ViewModelProvider<RateState>(
              builder: (rateState) {
                return Container(
                  height: double.infinity,
                  child: ListView.separated(
                    separatorBuilder: (b, c) => Divider(
                      height: 1,
                    ),
                    itemBuilder: (BuildContext context, int i) {
                      String curr = rateState.provider.availableCurrencies[i];
                      return ListTile(
                        title: Text(curr),
                        trailing: selectedCurrency == curr
                            ? Icon(
                                Icons.check,
                                color: Colors.greenAccent,
                              )
                            : SizedBox.shrink(),
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

  void showRatePeriodChooser() {
    ExchangeProvider provider = Provider.of<RateState>(context).provider;
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ViewModelProvider<RateState>(
              builder: (rateState) {
                return Wrap(
                  children: provider.ratePeriods.map((period) {
                    return Wrap(
                      children: <Widget>[
                        ListTile(
                          title: Text(period["title"]),
                          trailing: Radio(
                            value: period['title'],
                            groupValue: selectedPeriod,
                            onChanged: (va) {
                              this.setPeriod(period);
                            },
                          ),
                          onTap: () {
                            this.setPeriod(period);
                          },
                        ),
                        Divider(
                          height: 1,
                        )
                      ],
                    );
                  }).toList(),
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
    await Provider.of<RateState>(context, listen: false).setCurrency(currency);
    setState(() {
      loading = false;
    });
  }

  showProvider() {
    List<String> providers = ["LocalBitcoins"];
    String radioGroup = "LocalBitcoins";
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Wrap(
                direction: Axis.horizontal,
                children: providers.map((provider) {
                  return ListTile(
                    dense: true,
                    onTap: () {
                      //TODO
                    },
                    title: Text('$provider'),
                    trailing: Radio(
                      value: provider,
                      groupValue: radioGroup,
                      onChanged: (va) {},
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        });
  }

  void setPeriod(Map<String, String> period) async {
    setState(() {
      loading = true;
      selectedPeriod = period['title'];
    });
    PrefsStore().put(PrefsStore.CURRENCY_RATE_PERIOD, period['key']);
    Navigator.pop(context);
    await Provider.of<RateState>(context).getExchangeRates();
    setState(() {
      loading = false;
    });
  }
}
