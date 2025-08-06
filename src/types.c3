module schem::types;

import schem::runtime;
import std::collections::map;

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
    LAMBDA,
    ERROR,
}

union ValueUnion {
    long n;
    double d;
    String s;
    bool b;
    Expression *e;
    Lambda l;
}

struct Value {
    Type t;
    ValueUnion v;
}

struct Lambda {
    Expression *params;
    Expression *body;
    Scope *parent_scope;
}

struct Scope {
    HashMap{String,Value} vars;
    Scope *previous;
}

const Value NIL = {INVALID, {0}};
fn Value to_num(long num) => {NUMBER, {.n = num}};
fn Value to_dec(double num) => {DECIMAL, {.d = num}};
fn Value to_bool(bool val) => {BOOLEAN, {.b = val}};
fn Value to_error(String str) => {ERROR, {.s = str}};

struct Expression {
    Value current;
    Expression *next;
}
