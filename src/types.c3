module schem::types;

import schem::runtime;

alias Callback = fn Value?(Context*);

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

// fn Value Value.add(&self, Value val) @operator(+)
// {
//     if (self.t == DECIMAL) {
//         if (val.t == DECIMAL) {
//             return to_dec(self.v.d + val.v.d);
//         } else {
//             return to_dec(self.v.d + (double) val.v.n);
//         }
//     } else {
//         if (val.t == DECIMAL) {
//             return to_dec((double) self.v.n + val.v.d);
//         } else {
//             return to_num(self.v.n + val.v.n);
//         }
//     }
// }

const Value NIL = {INVALID, {0}};
fn Value to_num(long num) => {NUMBER, {.n = num}};
fn Value to_dec(double num) => {DECIMAL, {.d = num}};

struct Expression {
    Value current;
    Expression *next;
}
