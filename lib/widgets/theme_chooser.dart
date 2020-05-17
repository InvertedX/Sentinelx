import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/shared_state/theme_provider.dart';

class ThemeChooser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<ThemeState>(
        builder: (context, model, child) {
          return Container(
            height: MediaQuery.of(context).size.height / 2.8,
            child: SingleChildScrollView(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Theme",
                          style: Theme.of(context).textTheme.subhead,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          InkWell(
                            onTap: () => setLightTheme(model),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .textTheme
                                          .title
                                          .color
                                          .withOpacity(model.isDarkThemeEnabled()
                                              ? 0.0
                                              : 0.9),
                                      style: BorderStyle.solid,
                                      width:
                                          model.isDarkThemeEnabled() ? 0 : 0.9),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Wrap(
                                direction: Axis.vertical,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Card(
                                    color: Provider.of<ThemeState>(context)
                                        .lightTheme
                                        .backgroundColor,
                                    elevation: 2,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Light",
                                        style:
                                            Theme.of(context).textTheme.caption),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(4),
                          ),
                          InkWell(
                            onTap: () => setDarkTheme(model),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .textTheme
                                          .title
                                          .color
                                          .withOpacity(model.isDarkThemeEnabled()
                                              ? 0.9
                                              : 0.0),
                                      style: BorderStyle.solid,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Wrap(
                                direction: Axis.vertical,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Card(
                                    color: Provider.of<ThemeState>(context)
                                        .darkTheme
                                        .backgroundColor,
                                    elevation: 2,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Dark",
                                        style:
                                            Theme.of(context).textTheme.caption),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Divider(),
                      Text("Accent"),
                      Container(
                        height: 80,
                        child: Row(
//                              scrollDirection: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: ThemeState.accentColors.keys.map((key) {
                            Color accent = ThemeState.accentColors[key];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  InkWell(
                                    child: ClipOval(
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .color,
                                                width: Provider.of<ThemeState>(
                                                            context)
                                                        .isActiveAccent(accent)
                                                    ? 2
                                                    : 0,
                                                style: BorderStyle.solid),
                                            color: accent),
                                      ),
                                    ),
                                    onTap: () {
                                      setAccent(model, accent, key);
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(4),
                                  ),
                                  Text(
                                    key,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  setLightTheme(ThemeState model) async {
    model.setLight();
    try {
      await PrefsStore().put(PrefsStore.SELECTED_THEME, "light");
    } catch (e) {
      print(e);
    }
  }

  setDarkTheme(ThemeState model) async {
    model.setDark();
    try {
      await PrefsStore().put(PrefsStore.SELECTED_THEME, "dark");
    } catch (e) {
      print(e);
    }
  }

  setAccent(ThemeState model, Color color, String key) async {
    model.changeAccent(color);
    try {
      PrefsStore().put(PrefsStore.THEME_ACCENT, key);
    } catch (e) {
      print(e);
    }
  }
}
