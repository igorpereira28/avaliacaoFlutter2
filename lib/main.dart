import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avaliação Flutter 2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CRUD Flutter Avaliação'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _idController = TextEditingController();
  final _nomeController = TextEditingController();
  final _precoCustoController = TextEditingController();
  final _precoVendaController = TextEditingController();
  final _categoriaController = TextEditingController();

 List<dynamic> _produtos = [];

 final String apiURL = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    get();
  }

  Future<void> get() async {
    try {
      final response = await http.get(Uri.parse('$apiURL/produtos'));
      if (response.statusCode == 200) {
        setState(() {
          _produtos = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Erro ao executar solicitação GET: $e');
    }
  }

  Future<void> post() async {
    try {
      final response = await http.post(Uri.parse('$apiURL/produto'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nome': _nomeController.text,
        'precoCusto': double.tryParse(_precoCustoController.text) ?? 0,
        'precoVenda': double.tryParse(_precoVendaController.text) ?? 0,
        'categoria': _categoriaController.text,
      }),);
      if (response.statusCode == 201) {
        get();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Produto adicionado com sucesso')));
      }
    } catch (e) {
      print('Erro ao executar solicitação POST: $e');
    }
  }

  Future <void> put() async {
    try {
      final response = await http.put(Uri.parse('$apiURL/produto/${_idController.text}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nome': _nomeController.text,
        'precoCusto': double.tryParse(_precoCustoController.text) ?? 0,
        'precoVenda': double.tryParse(_precoVendaController.text) ?? 0,
        'categoria': _categoriaController.text,
      }),);
      if (response.statusCode == 200) {
        get();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Produto atualizado com sucesso')));
      }
    } catch (e) {
      print('Erro ao executar solicitação PUT $e');
    }
  }

  Future<void> delete() async {
    final response = await http.delete(Uri.parse('$apiURL/produto/${_idController.text}'));
    if (response.statusCode == 200) {
      get();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Produto deletado com sucesso')));
    }
  }

  void selectRow(int id, String nome, double precoCusto, double precoVenda, String categoria) {
    setState(() {
      _idController.text = id.toString();
      _nomeController.text = nome;
      _precoCustoController.text = precoCusto.toString();
      _precoVendaController.text = precoVenda.toString();
      _categoriaController.text = categoria;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children:[
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'Id'),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Digite o nome'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _precoCustoController,
              decoration: InputDecoration(labelText: 'Digite o preço de custo'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _precoVendaController,
              decoration: InputDecoration(labelText: 'Digite o preço de venda'),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _categoriaController,
              decoration: InputDecoration(labelText: 'Digite a categoria'),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: get, child: Text('GET')),
                ElevatedButton(onPressed: post, child: Text('POST')),
                ElevatedButton(onPressed: delete, child: Text('DELETE')),
                ElevatedButton(onPressed: put, child: Text('PUT')),
              ]
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child:DataTable(
                columns: [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Nome')),
                  DataColumn(label: Text('Preço de Custo')),
                  DataColumn(label: Text('Preço de Venda')),
                  DataColumn(label: Text('Categoria')),
                ],
                rows: _produtos.map((item) {
                  return DataRow(
                    onSelectChanged:(_) {
                      selectRow(
                        int.tryParse(item['id'].toString()) ?? 0,
                        item['nome'] ?? '',
                        double.tryParse(item['precoCusto'].toString()) ?? 0.0,
                        double.tryParse(item['precoVenda'].toString()) ?? 0.0,
                        item['categoria'] ?? '',
                      );
                    },
                    cells: [
                      DataCell(Text(item['id'].toString())),
                      DataCell(Text(item['nome'])),
                      DataCell(Text(item['precoCusto'].toString())),
                      DataCell(Text(item['precoVenda'].toString())),
                      DataCell(Text(item['categoria'])),
                    ],
                  );
                }).toList(),
              )
              ),
            ),
          ],
        ),
      ),
    );
  }
}