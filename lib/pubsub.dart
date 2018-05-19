
typedef SubCallback( List<dynamic> arguments );

class PubSub {

  int _key = 0;
  Map<int, SubCallback> _callbacks = Map<int, SubCallback>();

  int sub( SubCallback cb ) {
    int k = _key++;
    _callbacks[k] = cb;
    return k;
  }
  void unsub( int key ) {
    _callbacks.remove(key);
  }

  void pub( List<dynamic> arguments ) {
    _callbacks.forEach((int key, SubCallback cb ) {
      cb(arguments);
    });
  }

}