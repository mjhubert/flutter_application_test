// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dns_client/dns_client.dart';
import 'package:http/http.dart' as http;
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// #docregion MyApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // #docregion build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Startup Name Generator'),
        ),
        body: const Center(
          child: RandomWords(),
        ),
      ),
    );
  }
  // #enddocregion build
}
// #enddocregion MyApp

// #docregion RWS-var
class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  // #enddocregion RWS-var

  @override
  void initState() {
    // ignore: must_call_super
    _suggestions.addAll(generateWordPairs().take(101));
  }

  final _checked = <int, bool>{};

  Future<bool> checkDomainExists(ix) async {
    final hname = getSuggestion(ix).asPascalCase;

    try {
      var result = await DnsOverHttps.google().lookup(hname + ".com");
      final exists = result.isNotEmpty;
      _checked[ix] = exists;
      return exists;
    } catch (e) {
      return false;
    }
  }

  WordPair getSuggestion(int ix) {
    if (ix >= _suggestions.length) {
      _suggestions.addAll(
          generateWordPairs().take(((ix + 5) - _suggestions.length) * 2));
    }

    return _suggestions[ix];
  }

  Widget getIcon(ix) {
    if (_checked.containsKey(ix)) {
      final hostFree = !(_checked[ix] ?? false);
      return Icon(
        // NEW from here ...
        hostFree ? Icons.star_sharp : null,
        color: hostFree ? Colors.yellow : null,
        semanticLabel: 'Host free',
      );
    } else {
      return FutureBuilder<bool>(
          future: checkDomainExists(ix),
          builder: (context, snap) {
            if (snap.hasData) {
              final hostFree = !(snap.data ?? false);
              return Icon(
                // NEW from here ...
                hostFree ? Icons.star_sharp : null,
                color: hostFree ? Colors.yellow : null,
                semanticLabel: 'Host free',
              );
            }
            return CircularProgressIndicator();
          });
    }
  }

  // #docregion RWS-build
  @override
  Widget build(BuildContext context) {
    // #docregion itemBuilder
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return const Divider(); /*2*/
        final alreadySaved = _saved.contains(getSuggestion(i ~/ 2));
        // #docregion listTile
        return ListTile(
          title: Text(
            getSuggestion(i ~/ 2).asPascalCase,
            style: _biggerFont,
          ),
          trailing: FittedBox(
            fit: BoxFit.fill,
            child: Row(
              children: <Widget>[
                Icon(
                  // NEW from here ...
                  alreadySaved ? Icons.favorite : Icons.favorite_border,
                  color: alreadySaved ? Colors.red : null,
                  semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
                ),
                getIcon(i ~/ 2)
              ],
            ),
          ),
          onTap: () {
            // NEW from here ...
            setState(() {
              if (alreadySaved) {
                _saved.remove(getSuggestion(i ~/ 2));
              } else {
                _saved.add(getSuggestion(i ~/ 2));
              }
            }); // to here.
          },
        );
      },
    );
  }

  // #enddocregion itemBuilder
}
// #enddocregion RWS-build
// #docregion RWS-var

// #enddocregion RWS-var

class RandomWords extends StatefulWidget {
  const RandomWords({super.key});

  @override
  State<RandomWords> createState() => _RandomWordsState();
}
