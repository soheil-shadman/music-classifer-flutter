class PredictModel {
  late String date;
  late String filename;
  late String mood;

  PredictModel();
  PredictModel.fromJson(dynamic js) {
    date = js['date'];
    filename = js['filename'];
    mood = js['mood'];

    }
  }

