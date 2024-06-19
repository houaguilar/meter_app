
abstract interface class ResultLocalDataSource {

  Future<void> saveResults(List<dynamic> results, String metradoId);

  Future<List<dynamic>> loadResults(String metradoId);
}
