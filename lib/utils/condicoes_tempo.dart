import 'package:flutter/material.dart';

class InfoCondicaoTempo {
  final String descricao;
  final IconData icone;
  final Color cor;

  const InfoCondicaoTempo({
    required this.descricao,
    required this.icone,
    required this.cor,
  });
}

class CondicoesTempo {
  static const Map<String, InfoCondicaoTempo> _mapa = {
    'ec': InfoCondicaoTempo(
      descricao: 'Encoberto com Chuvas Isoladas',
      icone: Icons.thunderstorm,
      cor: Colors.blueGrey,
    ),
    'ci': InfoCondicaoTempo(
      descricao: 'Chuvas Isoladas',
      icone: Icons.grain,
      cor: Colors.lightBlue,
    ),
    'c': InfoCondicaoTempo(
      descricao: 'Chuva',
      icone: Icons.umbrella,
      cor: Colors.blue,
    ),
    'in': InfoCondicaoTempo(
      descricao: 'Instável',
      icone: Icons.cloud_sync,
      cor: Colors.blueGrey,
    ),
    'pp': InfoCondicaoTempo(
      descricao: 'Possibilidade de Pancadas de Chuva',
      icone: Icons.water_drop_outlined,
      cor: Colors.lightBlue,
    ),
    'cm': InfoCondicaoTempo(
      descricao: 'Chuva pela Manhã',
      icone: Icons.wb_twilight,
      cor: Colors.blue,
    ),
    'cn': InfoCondicaoTempo(
      descricao: 'Chuva à Noite',
      icone: Icons.nights_stay,
      cor: Colors.indigo,
    ),
    'pt': InfoCondicaoTempo(
      descricao: 'Pancadas de Chuva à Tarde',
      icone: Icons.beach_access,
      cor: Colors.blue,
    ),
    'pm': InfoCondicaoTempo(
      descricao: 'Pancadas de Chuva pela Manhã',
      icone: Icons.beach_access,
      cor: Colors.lightBlue,
    ),
    'np': InfoCondicaoTempo(
      descricao: 'Nublado e Pancadas de Chuva',
      icone: Icons.thunderstorm_outlined,
      cor: Colors.blueGrey,
    ),
    'pc': InfoCondicaoTempo(
      descricao: 'Pancadas de Chuva',
      icone: Icons.umbrella,
      cor: Colors.blueAccent,
    ),
    'pn': InfoCondicaoTempo(
      descricao: 'Parcialmente Nublado',
      icone: Icons.cloud_queue,
      cor: Colors.amber,
    ),
    'cv': InfoCondicaoTempo(
      descricao: 'Chuvisco',
      icone: Icons.grain,
      cor: Colors.lightBlueAccent,
    ),
    'ch': InfoCondicaoTempo(
      descricao: 'Chuvoso',
      icone: Icons.water_drop,
      cor: Colors.blue,
    ),
    't': InfoCondicaoTempo(
      descricao: 'Tempestade',
      icone: Icons.flash_on,
      cor: Colors.deepPurple,
    ),
    'ps': InfoCondicaoTempo(
      descricao: 'Predomínio de Sol',
      icone: Icons.wb_sunny,
      cor: Colors.orange,
    ),
    'e': InfoCondicaoTempo(
      descricao: 'Encoberto',
      icone: Icons.cloud,
      cor: Colors.grey,
    ),
    'n': InfoCondicaoTempo(
      descricao: 'Nublado',
      icone: Icons.wb_cloudy,
      cor: Colors.blueGrey,
    ),
    'cl': InfoCondicaoTempo(
      descricao: 'Céu Claro',
      icone: Icons.wb_sunny_outlined,
      cor: Colors.orangeAccent,
    ),
    'nv': InfoCondicaoTempo(
      descricao: 'Nevoeiro',
      icone: Icons.foggy,
      cor: Colors.grey,
    ),
    'g': InfoCondicaoTempo(
      descricao: 'Geada',
      icone: Icons.ac_unit,
      cor: Colors.cyan,
    ),
    'ne': InfoCondicaoTempo(
      descricao: 'Neve',
      icone: Icons.snowing,
      cor: Colors.cyanAccent,
    ),
    'nd': InfoCondicaoTempo(
      descricao: 'Não Definido',
      icone: Icons.help_outline,
      cor: Colors.grey,
    ),
    'pnt': InfoCondicaoTempo(
      descricao: 'Pancadas de Chuva à Noite',
      icone: Icons.nights_stay_outlined,
      cor: Colors.indigo,
    ),
    'psc': InfoCondicaoTempo(
      descricao: 'Possibilidade de Chuva',
      icone: Icons.water_drop_outlined,
      cor: Colors.lightBlue,
    ),
    'pcm': InfoCondicaoTempo(
      descricao: 'Possibilidade de Chuva pela Manhã',
      icone: Icons.wb_twilight,
      cor: Colors.lightBlue,
    ),
    'pct': InfoCondicaoTempo(
      descricao: 'Possibilidade de Chuva à Tarde',
      icone: Icons.wb_cloudy_outlined,
      cor: Colors.lightBlue,
    ),
    'pcn': InfoCondicaoTempo(
      descricao: 'Possibilidade de Chuva à Noite',
      icone: Icons.nights_stay_outlined,
      cor: Colors.indigoAccent,
    ),
    'npt': InfoCondicaoTempo(
      descricao: 'Nublado com Pancadas à Tarde',
      icone: Icons.thunderstorm_outlined,
      cor: Colors.blueGrey,
    ),
    'npn': InfoCondicaoTempo(
      descricao: 'Nublado com Pancadas à Noite',
      icone: Icons.nights_stay,
      cor: Colors.indigo,
    ),
    'ncn': InfoCondicaoTempo(
      descricao: 'Nublado com Possibilidade de Chuva à Noite',
      icone: Icons.nights_stay_outlined,
      cor: Colors.blueGrey,
    ),
    'nct': InfoCondicaoTempo(
      descricao: 'Nublado com Possibilidade de Chuva à Tarde',
      icone: Icons.cloud_outlined,
      cor: Colors.blueGrey,
    ),
    'ncm': InfoCondicaoTempo(
      descricao: 'Nublado com Possibilidade de Chuva pela Manhã',
      icone: Icons.wb_cloudy_outlined,
      cor: Colors.blueGrey,
    ),
    'npm': InfoCondicaoTempo(
      descricao: 'Nublado com Pancadas pela Manhã',
      icone: Icons.thunderstorm_outlined,
      cor: Colors.blueGrey,
    ),
    'npp': InfoCondicaoTempo(
      descricao: 'Nublado com Possibilidade de Chuva',
      icone: Icons.cloud_queue,
      cor: Colors.blueGrey,
    ),
    'vn': InfoCondicaoTempo(
      descricao: 'Variação de Nebulosidade',
      icone: Icons.cloud_sync_outlined,
      cor: Colors.amber,
    ),
    'ct': InfoCondicaoTempo(
      descricao: 'Chuva à Tarde',
      icone: Icons.umbrella_outlined,
      cor: Colors.blue,
    ),
    'ppn': InfoCondicaoTempo(
      descricao: 'Possibilidade de Pancadas de Chuva à Noite',
      icone: Icons.nights_stay_outlined,
      cor: Colors.indigoAccent,
    ),
    'ppt': InfoCondicaoTempo(
      descricao: 'Possibilidade de Pancadas de Chuva à Tarde',
      icone: Icons.grain,
      cor: Colors.blue,
    ),
    'ppm': InfoCondicaoTempo(
      descricao: 'Possibilidade de Pancadas de Chuva pela Manhã',
      icone: Icons.grain,
      cor: Colors.lightBlue,
    ),
  };

  static InfoCondicaoTempo obter(String? sigla) {
    if (sigla == null || sigla.trim().isEmpty) {
      return _mapa['nd']!;
    }
    final chave = sigla.trim().toLowerCase();
    return _mapa[chave] ??
        InfoCondicaoTempo(
          descricao: 'Condição ($chave)',
          icone: Icons.help_outline,
          cor: Colors.grey,
        );
  }
}
