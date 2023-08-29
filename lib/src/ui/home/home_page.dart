import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:travel_app/src/core/theme.dart';
import 'package:travel_app/src/core/ui_constants.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController searchCountry = TextEditingController();

  Stream fetchCountry(String country) async* {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'GET', Uri.parse('https://countries.trevorblades.com/graphql'));
    request.body =
        '''{"query":"query Query {\\r\\n  country(code: \\"BR\\") {\\r\\n    name\\r\\n    native\\r\\n    emoji\\r\\n    currency\\r\\n    languages {\\r\\n      code\\r\\n      name\\r\\n    }\\r\\n  }\\r\\n}\\r\\n","variables":{}}''';

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      yield await response.stream.bytesToString();
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.airplane_ticket_sharp),
        leadingWidth: 35,
        titleSpacing: 0,
        title: const Text(
          'Travel App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          CountryFlag.fromCountryCode(
            'IN',
            height: 24,
            width: 24,
            borderRadius: 8,
          ),
          IconButton(
            onPressed: () {
              ref.read(themeProvider.notifier).changeTheme();
            },
            icon: ref.watch(themeProvider) == ThemeMode.light
                ? const Icon(Icons.wb_sunny_rounded)
                : const Icon(Icons.nightlight_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchCountry,
                  decoration: const InputDecoration(
                    hintText: 'Search Countries here',
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.amberAccent),
                ),
                icon: const Icon(Icons.search_outlined),
                label: const Text('Search'),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: StreamBuilder(
              stream: fetchCountry(
                searchCountry.text.toString(),
              ),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data.toString(),
                  );
                }
                return const Text('Tap on search');
              },
            ),
          ),
        ],
      ),
    );
  }
}
