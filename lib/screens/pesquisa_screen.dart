import 'package:flutter/material.dart';
import '../models/cidade_model.dart';
import '../services/cptec_service.dart';
import '../services/storage_service.dart';
import 'previsao_screen.dart';

class PesquisaScreen extends StatefulWidget {
  const PesquisaScreen({super.key});

  @override
  State<PesquisaScreen> createState() => _PesquisaScreenState();
}

class _PesquisaScreenState extends State<PesquisaScreen> {
  final TextEditingController _buscaController = TextEditingController();
  final CptecService _cptecService = CptecService();
  final StorageService _storageService = StorageService();

  List<Cidade> _resultadosPesquisa = [];
  List<Cidade> _cidadesRecentes = [];
  bool _carregando = false;
  bool _pesquisaRealizada = false;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _carregarHistoricoLocal();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarHistoricoLocal() async {
    final recentes = await _storageService.obterCidadesRecentes();
    if (mounted) {
      setState(() {
        _cidadesRecentes = recentes;
      });
    }
  }

  Future<void> _executarPesquisa() async {
    final termo = _buscaController.text.trim();
    if (termo.length < 2) {
      setState(() {
        _mensagemErro =
            'Informe pelo menos 2 caracteres para pesquisar a cidade.';
        _pesquisaRealizada = false;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _carregando = true;
      _mensagemErro = null;
      _pesquisaRealizada = true;
    });

    try {
      final cidades = await _cptecService.pesquisarCidades(termo);
      if (mounted) {
        setState(() {
          _resultadosPesquisa = cidades;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _resultadosPesquisa = [];
          _mensagemErro = e.toString();
          _carregando = false;
        });
      }
    }
  }

  Future<void> _selecionarCidade(Cidade cidade) async {
    await _storageService.salvarCidadeSelecionada(cidade);
    await _carregarHistoricoLocal();

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrevisaoScreen(cidade: cidade),
      ),
    );
  }

  Future<void> _removerRecente(Cidade cidade) async {
    await _storageService.removerCidadeRecente(cidade.id);
    await _carregarHistoricoLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previsão do Tempo - CPTEC/INPE'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscaController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _executarPesquisa(),
                    decoration: InputDecoration(
                      labelText: 'Pesquisar cidade brasileira',
                      hintText: 'Ex.: São José dos Campos, Jacareí...',
                      prefixIcon: const Icon(Icons.location_city),
                      suffixIcon: _buscaController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _buscaController.clear();
                                setState(() {
                                  _resultadosPesquisa = [];
                                  _pesquisaRealizada = false;
                                  _mensagemErro = null;
                                });
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _carregando ? null : _executarPesquisa,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _construirConteudoPrincipal(),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Text(
              'Fonte dos dados: CPTEC/INPE (Centro de Previsão de Tempo e Estudos Climáticos)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirConteudoPrincipal() {
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('A consultar localidades no CPTEC/INPE...'),
          ],
        ),
      );
    }

    if (_mensagemErro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                _mensagemErro!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _executarPesquisa,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pesquisaRealizada && _resultadosPesquisa.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Nenhuma cidade encontrada para o termo informado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    if (_pesquisaRealizada && _resultadosPesquisa.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Resultados encontrados (${_resultadosPesquisa.length}):',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _resultadosPesquisa.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final cidade = _resultadosPesquisa[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(cidade.uf),
                  ),
                  title: Text(cidade.nome),
                  subtitle:
                      Text('UF: ${cidade.uf} • Código CPTEC: ${cidade.id}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selecionarCidade(cidade),
                );
              },
            ),
          ),
        ],
      );
    }

    // Exibe o histórico persistido localmente quando não há pesquisa ativa
    if (_cidadesRecentes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Pesquise pelo nome de uma cidade brasileira acima para consultar a previsão do tempo para 4 dias.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.history, size: 18),
              SizedBox(width: 6),
              Text(
                'Cidades consultadas recentemente ( salvas no dispositivo ):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _cidadesRecentes.length,
            itemBuilder: (context, index) {
              final cidade = _cidadesRecentes[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(cidade.uf),
                  ),
                  title: Text('${cidade.nome} - ${cidade.uf}'),
                  subtitle: Text('ID CPTEC: ${cidade.id}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remover do histórico',
                    onPressed: () => _removerRecente(cidade),
                  ),
                  onTap: () => _selecionarCidade(cidade),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
