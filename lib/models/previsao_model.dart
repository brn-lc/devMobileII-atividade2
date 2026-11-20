class PrevisaoDia {
  final String data;
  final String siglaTempo;
  final int? minima;
  final int? maxima;
  final double? iuv;

  PrevisaoDia({
    required this.data,
    required this.siglaTempo,
    this.minima,
    this.maxima,
    this.iuv,
  });

  Map<String, dynamic> toJson() => {
        'data': data,
        'siglaTempo': siglaTempo,
        'minima': minima,
        'maxima': maxima,
        'iuv': iuv,
      };

  factory PrevisaoDia.fromJson(Map<String, dynamic> json) {
    return PrevisaoDia(
      data: json['data'] as String? ?? '',
      siglaTempo: json['siglaTempo'] as String? ?? 'nd',
      minima: json['minima'] as int?,
      maxima: json['maxima'] as int?,
      iuv: (json['iuv'] as num?)?.toDouble(),
    );
  }

  String get dataFormatada {
    final partes = data.split('-');
    if (partes.length == 3) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }
    return data.isNotEmpty ? data : 'Data indisponível';
  }

  String get diaMesCurto {
    final partes = data.split('-');
    if (partes.length == 3) {
      return '${partes[2]}/${partes[1]}';
    }
    return data;
  }
}

class PrevisaoCidade {
  final int cidadeId;
  final String nomeCidade;
  final String uf;
  final String atualizacao;
  final List<PrevisaoDia> dias;

  PrevisaoCidade({
    required this.cidadeId,
    required this.nomeCidade,
    required this.uf,
    required this.atualizacao,
    required this.dias,
  });

  Map<String, dynamic> toJson() => {
        'cidadeId': cidadeId,
        'nomeCidade': nomeCidade,
        'uf': uf,
        'atualizacao': atualizacao,
        'dias': dias.map((d) => d.toJson()).toList(),
      };

  factory PrevisaoCidade.fromJson(Map<String, dynamic> json) {
    final listaDias = (json['dias'] as List<dynamic>? ?? [])
        .map((item) => PrevisaoDia.fromJson(item as Map<String, dynamic>))
        .toList();

    return PrevisaoCidade(
      cidadeId: json['cidadeId'] as int? ?? 0,
      nomeCidade: json['nomeCidade'] as String? ?? 'Desconhecida',
      uf: json['uf'] as String? ?? '--',
      atualizacao: json['atualizacao'] as String? ?? '',
      dias: listaDias,
    );
  }

  String get atualizacaoFormatada {
    final partes = atualizacao.split('-');
    if (partes.length == 3) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }
    return atualizacao.isNotEmpty ? atualizacao : 'Não informada';
  }
}
