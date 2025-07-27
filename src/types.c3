module schem::types;

import schem::runtime;

alias Callback = fn Value(Context*);

struct NativeFunction {
    String name;
    Callback fun;
}

enum Type : char {
    INVALID,
    NUMBER,
    DECIMAL,
    STRING,
    SYMBOL,
    BOOLEAN,
    EXPRESSION,
}

union ValueUnion {
    long n;
    double d;
    String s;
    bool b;
    Expression *e;
}

struct Value {
    Type t;
    ValueUnion v;
}

const Value NIL = {INVALID, {0}};
fn Value to_num(long num) => {NUMBER, {.n = num}};

struct Expression {
    Value current;
    Expression *next;
}
