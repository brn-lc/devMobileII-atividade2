import 'package:flutter/material.dart';
import 'screens/pesquisa_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PrevisaoTempoApp());
}

class PrevisaoTempoApp extends StatelessWidget {
  const PrevisaoTempoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Previsão do Tempo CPTEC/INPE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PesquisaScreen(),
    );
  }
}
