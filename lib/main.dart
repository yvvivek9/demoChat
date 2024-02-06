import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import 'models/ModelProvider.dart';
import 'amplifyconfiguration.dart';

import 'chatScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const MyApp());
}

Future<void> _configureAmplify() async {
  try {
    // Create the API plugin.
    //
    // If `ModelProvider.instance` is not available, try running
    // `amplify codegen models` from the root of your project.
    final api = AmplifyAPI(modelProvider: ModelProvider.instance);
    // Create the Auth plugin.
    final auth = AmplifyAuthCognito();
    // Add the plugins and configure Amplify for your app.
    await Amplify.addPlugins([api, auth]);
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // GoRouter configuration
  static final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp.router(
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.grey[850],
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        builder: Authenticator.builder(),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

Future<String> getCurrentUser() async {
  final user = await Amplify.Auth.getCurrentUser();
  return user.username;
}

Future<int> sendMessage({required String name, required String message}) async {
  final newEntry = Chats(
    name: name,
    message: message,
  );
  final request = ModelMutations.create(newEntry);
  final response = await Amplify.API.mutate(request: request).response;
  safePrint('Create result: $response');
  return 1;
}

Future<List<Chats>> refreshMessages() async {
  final request = ModelQueries.list(Chats.classType);
  final response = await Amplify.API.query(request: request).response;
  final todos = response.data?.items;
  return todos!.whereType<Chats>().toList();
}
