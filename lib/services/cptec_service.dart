import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/cidade_model.dart';
import '../models/previsao_model.dart';

class CptecException implements Exception {
  final String mensagem;
  CptecException(this.mensagem);

  @override
  String toString() => mensagem;
}

class CptecService {
  static const String _baseUrl = 'http://servicos.cptec.inpe.br/XML';
  static const Duration _timeout = Duration(seconds: 15);

  /// Constrói a URI direta no mobile/desktop ou via proxy CORS no navegador (Web)
  Uri _construirUri(String endpointCompleto) {
    if (kIsWeb) {
      return Uri.parse(
        'https://api.allorigins.win/raw?url=${Uri.encodeComponent(endpointCompleto)}',
      );
    }
    return Uri.parse(endpointCompleto);
  }

  /// Decodifica corretamente os bytes conforme a plataforma (Web já entrega UTF-8)
  String _decodificarResposta(List<int> bodyBytes) {
    if (kIsWeb) {
      return utf8.decode(bodyBytes, allowMalformed: true);
    }
    return latin1.decode(bodyBytes, allowInvalid: true);
  }

  /// Remove acentos para compatibilidade com o parâmetro 'city' do CPTEC/INPE
  String _removerAcentos(String texto) {
    const comAcento =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const semAcento =
        'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';
    String resultado = texto;
    for (int i = 0; i < comAcento.length; i++) {
      resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
    }
    return resultado;
  }

  String? _extrairTextoElemento(XmlElement pai, String tag) {
    final elementos = pai.findElements(tag);
    if (elementos.isEmpty) return null;
    final texto = elementos.first.innerText.trim();
    if (texto.isEmpty || texto.toLowerCase() == 'null' || texto == '-') {
      return null;
    }
    return texto;
  }

  /// Pesquisa localidades pelo parâmetro 'city'
  Future<List<Cidade>> pesquisarCidades(String nomeCidade) async {
    final consultaLimpa = _removerAcentos(nomeCidade.trim());
    if (consultaLimpa.isEmpty) {
      return [];
    }

    final urlOriginal =
        '$_baseUrl/listaCidades?city=${Uri.encodeQueryComponent(consultaLimpa)}';
    final uri = _construirUri(urlOriginal);

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw CptecException(
          'Serviço do CPTEC/INPE indisponível no momento (HTTP ${response.statusCode}).',
        );
      }

      final xmlString = _decodificarResposta(response.bodyBytes);
      final document = XmlDocument.parse(xmlString);
      final elementosCidade = document.findAllElements('cidade');

      final List<Cidade> cidades = [];
      for (final elemento in elementosCidade) {
        final idStr = _extrairTextoElemento(elemento, 'id');
        final nome = _extrairTextoElemento(elemento, 'nome');
        final uf = _extrairTextoElemento(elemento, 'uf');

        final id = idStr != null ? int.tryParse(idStr) : null;
        if (id != null && nome != null && uf != null) {
          cidades.add(Cidade(id: id, nome: nome, uf: uf));
        }
      }

      return cidades;
    } on SocketException {
      throw CptecException(
        'Sem ligação à internet. Verifique a sua conectividade e tente novamente.',
      );
    } on TimeoutException {
      throw CptecException(
        'O servidor do CPTEC/INPE demorou muito a responder. Tente novamente.',
      );
    } on XmlException {
      throw CptecException(
        'Resposta XML inválida recebida do serviço do CPTEC/INPE.',
      );
    } catch (e) {
      if (e is CptecException) rethrow;
      throw CptecException('Erro inesperado ao consultar localidades: $e');
    }
  }

  /// Consulta a previsão de 4 dias pelo código identificador da localidade
  Future<PrevisaoCidade> obterPrevisao4Dias(Cidade cidade) async {
    final urlOriginal = '$_baseUrl/cidade/${cidade.id}/previsao.xml';
    final uri = _construirUri(urlOriginal);

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw CptecException(
          'Serviço de previsão indisponível (HTTP ${response.statusCode}).',
        );
      }

      final xmlString = _decodificarResposta(response.bodyBytes);
      final document = XmlDocument.parse(xmlString);
      final root = document.rootElement;

      final nomeXml = _extrairTextoElemento(root, 'nome') ?? cidade.nome;
      final ufXml = _extrairTextoElemento(root, 'uf') ?? cidade.uf;
      final atualizacao =
          _extrairTextoElemento(root, 'atualizacao') ?? 'Não informada';

      final elementosPrevisao = root.findElements('previsao');
      final List<PrevisaoDia> dias = [];

      for (final prev in elementosPrevisao) {
        final dia = _extrairTextoElemento(prev, 'dia') ?? '';
        final tempo = _extrairTextoElemento(prev, 'tempo') ?? 'nd';
        final minStr = _extrairTextoElemento(prev, 'minima');
        final maxStr = _extrairTextoElemento(prev, 'maxima');
        final iuvStr = _extrairTextoElemento(prev, 'iuv');

        final minima = minStr != null ? int.tryParse(minStr) : null;
        final maxima = maxStr != null ? int.tryParse(maxStr) : null;
        final iuv = iuvStr != null
            ? double.tryParse(iuvStr.replaceAll(',', '.'))
            : null;

        if (dia.isNotEmpty || minima != null || maxima != null) {
          dias.add(
            PrevisaoDia(
              data: dia,
              siglaTempo: tempo,
              minima: minima,
              maxima: maxima,
              iuv: iuv,
            ),
          );
        }
      }

      if (dias.isEmpty) {
        throw CptecException(
          'Não há previsão disponível para ${cidade.nome} - ${cidade.uf} no momento.',
        );
      }

      return PrevisaoCidade(
        cidadeId: cidade.id,
        nomeCidade: nomeXml,
        uf: ufXml,
        atualizacao: atualizacao,
        dias: dias,
      );
    } on SocketException {
      throw CptecException(
        'Falha na ligação de rede ao consultar a previsão do tempo.',
      );
    } on TimeoutException {
      throw CptecException(
        'Tempo limite esgotado ao contactar o serviço do CPTEC/INPE.',
      );
    } on XmlException {
      throw CptecException(
        'Formato XML inválido recebido ao consultar a previsão.',
      );
    } catch (e) {
      if (e is CptecException) rethrow;
      throw CptecException('Erro ao processar os dados da previsão: $e');
    }
  }
}
