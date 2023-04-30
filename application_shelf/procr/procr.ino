#include <memory>


#if __cplusplus == 201703L
#pragma message ("it's this version: 17")

#endif

#if __cplusplus == 201402L
#pragma message ("it's this version: 14")


#endif

#if __cplusplus == 201103L
#pragma message ("it's this version: 11")
#endif

auto f(int i){
    return i;
}


void setup(){
f(5);
auto smartPtr = std::make_unique<int>(500);
}

void loop(){

}

