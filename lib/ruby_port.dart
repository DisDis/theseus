library ruby.port;
import 'dart:math' as math;

/**
 * if returned true then loop break
 */
typedef bool EachWithIndexCallback<V>(V item,int index);



bool each_with_index<V>(Iterable<V> array,EachWithIndexCallback<V> callback){
  int index= 0;
  return array.any((item){
    if (callback(item,index)==true){
      return true;
    }
    index++;
    return false;
  });
}

math.Random _rnd = new math.Random();

void srand(int seed){
  _rnd = new math.Random(seed);
}

int rand(int max){
  return _rnd.nextInt(max);
}

math.Random getRandom()=>_rnd;