import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cidade_model.dart';
import '../models/previsao_model.dart';

class StorageService {
  static const String _keyCidadesRecentes = 'cidades_recentes_v1';
  static const String _keyUltimaCidade = 'ultima_cidade_v1';
  static const String _prefixCachePrevisao = 'cache_previsao_';

  /// Guarda uma cidade na lista de recentes e define-a como última selecionada
  Future<void> salvarCidadeSelecionada(Cidade cidade) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUltimaCidade, jsonEncode(cidade.toJson()));

    final listaAtual = await obterCidadesRecentes();
    listaAtual.removeWhere((c) => c.id == cidade.id);
    listaAtual.insert(0, cidade);

    // Mantém até 10 cidades no histórico local
    final listaLimitada = listaAtual.take(10).toList();
    final jsonList = listaLimitada.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_keyCidadesRecentes, jsonList);
  }

  /// Obtém a lista de cidades guardadas localmente
  Future<List<Cidade>> obterCidadesRecentes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyCidadesRecentes) ?? [];
    final List<Cidade> cidades = [];

    for (final item in jsonList) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        cidades.add(Cidade.fromJson(map));
      } catch (_) {
        // Ignora entradas corrompidas sem encerrar a aplicação
      }
    }
    return cidades;
  }

  /// Guarda em cache a previsão de 4 dias de uma localidade
  Future<void> salvarPrevisaoCache(PrevisaoCidade previsao) async {
    final prefs = await SharedPreferences.getInstance();
    final chave = '$_prefixCachePrevisao${previsao.cidadeId}';
    await prefs.setString(chave, jsonEncode(previsao.toJson()));
  }

  /// Recupera a previsão guardada localmente para uma localidade
  Future<PrevisaoCidade?> obterPrevisaoCache(int cidadeId) async {
    final prefs = await SharedPreferences.getInstance();
    final chave = '$_prefixCachePrevisao$cidadeId';
    final jsonStr = prefs.getString(chave);
    if (jsonStr == null) return null;

    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return PrevisaoCidade.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Remove uma cidade do histórico local
  Future<void> removerCidadeRecente(int cidadeId) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await obterCidadesRecentes();
    lista.removeWhere((c) => c.id == cidadeId);
    final jsonList = lista.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_keyCidadesRecentes, jsonList);
  }
}
