#### 1.6. Булевые операции

 - Напишите модуль bool.erl и определите в нём логические операции
   - `b_not/1`
   - `b_and/2`
   - `b_or/2`
   - `b_xor/2`

на атомах `true` и `false`. При определении функций пользуйтесь сопоставлением с
образцом, а не встроенными функциями and, or и not. Ниже приведены примеры
использования модуля в интерпретаторе:

```erlang
1> c(bool).
{ok,bool}
2> bool:b_not(true).
false
3> bool:b_and(true, true).
true
4> bool:b_and(true, false).
false
5> bool:b_or(true, false).
true
6> bool:b_or(false, false).
false
7> bool:b_or(false, true). 
true
8> bool:b_not(bool:b_or(false, true)).
false
9> bool:b_xor(true, false).
true
10> bool:b_xor(true, true). 
false
```

#### Решение
[bool.erl](https://github.com/Pantelonia/Reksoft_erl/blob/master/hm1/bool/bool.erl)
