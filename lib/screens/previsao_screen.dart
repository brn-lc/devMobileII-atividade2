import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/cidade_model.dart';
import '../models/previsao_model.dart';
import '../services/cptec_service.dart';
import '../services/storage_service.dart';
import '../utils/condicoes_tempo.dart';

class PrevisaoScreen extends StatefulWidget {
  final Cidade cidade;

  const PrevisaoScreen({super.key, required this.cidade});

  @override
  State<PrevisaoScreen> createState() => _PrevisaoScreenState();
}

class _PrevisaoScreenState extends State<PrevisaoScreen> {
  final CptecService _cptecService = CptecService();
  final StorageService _storageService = StorageService();

  PrevisaoCidade? _previsao;
  bool _carregando = true;
  bool _usandoCacheOffline = false;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _carregarPrevisao();
  }

  Future<void> _carregarPrevisao() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
      _usandoCacheOffline = false;
    });

    try {
      final previsaoOnline =
          await _cptecService.obterPrevisao4Dias(widget.cidade);
      await _storageService.salvarPrevisaoCache(previsaoOnline);

      if (mounted) {
        setState(() {
          _previsao = previsaoOnline;
          _carregando = false;
        });
      }
    } catch (e) {
      // Caso ocorra falha de rede/serviço, tenta recuperar a última previsão salva localmente
      final cache = await _storageService.obterPrevisaoCache(widget.cidade.id);
      if (mounted) {
        setState(() {
          _previsao = cache;
          _usandoCacheOffline = cache != null;
          _mensagemErro = e.toString();
          _carregando = false;
        });
      }
    }
  }

  Color _corIuv(double iuv) {
    if (iuv < 3) return Colors.green;
    if (iuv < 6) return Colors.amber.shade700;
    if (iuv < 8) return Colors.orange.shade800;
    if (iuv < 11) return Colors.redAccent;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cidade.nome} - ${widget.cidade.uf}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar previsão',
            onPressed: _carregando ? null : _carregarPrevisao,
          ),
        ],
      ),
      body: _construirCorpo(),
    );
  }

  Widget _construirCorpo() {
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('A consultar previsão para 4 dias no CPTEC/INPE...'),
          ],
        ),
      );
    }

    if (_previsao == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                _mensagemErro ??
                    'Não há previsão disponível para esta localidade.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _carregarPrevisao,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final previsao = _previsao!;

    return RefreshIndicator(
      onRefresh: _carregarPrevisao,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (_usandoCacheOffline && _mensagemErro != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.black87),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$_mensagemErro\nA apresentar dados guardados localmente no dispositivo.',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _construirCabecalho(previsao),
          const SizedBox(height: 16),
          _construirSecaoGrafico(previsao.dias),
          const SizedBox(height: 16),
          const Text(
            'Previsão Detalhada (4 Dias)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...previsao.dias.map(_construirCardDia),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Fonte dos dados: CPTEC/INPE',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCabecalho(PrevisaoCidade previsao) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${previsao.nomeCidade} (${previsao.uf})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Atualização CPTEC/INPE: ${previsao.atualizacaoFormatada}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Chip(
              avatar: const Icon(Icons.verified_outlined, size: 16),
              label: Text('ID ${previsao.cidadeId}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirSecaoGrafico(List<PrevisaoDia> dias) {
    final diasComTemperatura =
        dias.where((d) => d.minima != null && d.maxima != null).toList();

    if (diasComTemperatura.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Gráfico indisponível: temperaturas não informadas pelo serviço para os dias consultados.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final List<FlSpot> spotsMin = [];
    final List<FlSpot> spotsMax = [];
    double minTemp = 100;
    double maxTemp = -100;

    for (int i = 0; i < diasComTemperatura.length; i++) {
      final d = diasComTemperatura[i];
      final minVal = d.minima!.toDouble();
      final maxVal = d.maxima!.toDouble();

      spotsMin.add(FlSpot(i.toDouble(), minVal));
      spotsMax.add(FlSpot(i.toDouble(), maxVal));

      if (minVal < minTemp) minTemp = minVal;
      if (maxVal > maxTemp) maxTemp = maxVal;
    }

    final minY = (minTemp - 4).floorToDouble();
    final maxY = (maxTemp + 4).ceilToDouble();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Variação de Temperatura (°C)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _construirItemLegenda(Colors.redAccent, 'Máxima (°C)'),
                const SizedBox(width: 16),
                _construirItemLegenda(Colors.blueAccent, 'Mínima (°C)'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 210,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: true,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}°',
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= diasComTemperatura.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              diasComTemperatura[idx].diaMesCurto,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spotsMax,
                      isCurved: true,
                      color: Colors.redAccent,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.redAccent.withValues(alpha: 0.12),
                      ),
                    ),
                    LineChartBarData(
                      spots: spotsMin,
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blueAccent.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirItemLegenda(Color cor, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _construirCardDia(PrevisaoDia dia) {
    final condicao = CondicoesTempo.obter(dia.siglaTempo);
    final minTexto = dia.minima != null ? '${dia.minima}°C' : '--';
    final maxTexto = dia.maxima != null ? '${dia.maxima}°C' : '--';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: condicao.cor.withValues(alpha: 0.15),
              child: Icon(condicao.icone, color: condicao.cor, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dia.dataFormatada,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    condicao.descricao,
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (dia.iuv != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _corIuv(dia.iuv!).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Índice UV: ${dia.iuv!.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _corIuv(dia.iuv!),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                    Text(
                      maxTexto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_downward,
                      size: 16,
                      color: Colors.blueAccent,
                    ),
                    Text(
                      minTexto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
