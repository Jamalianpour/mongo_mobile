import 'package:mongo_dart/mongo_dart.dart' as Mongo;

class Cache {
  static Mongo.Db? db;
  static String mongoUri = '';
  static String mongoBaseUri = '';
  static String openCollection = '';
}
