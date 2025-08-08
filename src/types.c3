module schem::types;

import schem::runtime;
import schem::gc;
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
    bool b;
    String s;
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
    Scope *captured_env;
}

struct Scope {
    HashMap{String,Value} vars;
    Scope *previous;
    TrackedObject *gc_ref;
}

const Value NIL = {INVALID, {0}};
fn Value to_num(long num) => {NUMBER, {.n = num}};
fn Value to_dec(double num) => {DECIMAL, {.d = num}};
fn Value to_bool(bool val) => {BOOLEAN, {.b = val}};
fn Value to_error(String str) => {ERROR, {.s = str}};

struct Expression {
    Value current;
    Expression *next;
    TrackedObject *gc_ref;
}

fn void Value.mark(&self)
{
    switch (self.t) {
    // case STRING:
    // case SYMBOL:
    // case ERROR:
    //     self.v._s.gc_ref.mark();
    case LAMBDA:
        Lambda *lambda = &self.v.l;
        lambda.params.gc_ref.mark();
        lambda.body.gc_ref.mark();
        lambda.captured_env.gc_ref.mark();
    case EXPRESSION:
        self.v.e.gc_ref.mark();
    default:
    }
}

fn void Value.free(&self)
{
    // TODO: cleanup strings
}

fn bool mark_scope(void *data)
{
    Scope *self = data;
    Scope *iter = self.previous;

    while (iter) {
        iter.gc_ref.mark();
        iter = iter.previous;
    }

    return true;
}

fn void free_scope(void *data)
{
    Scope *self = data;
    self.vars.free();
}

fn bool mark_expression(void *data)
{
    Expression *self = data;
    self.current.mark();
    self.next.gc_ref.mark();

    return true;
}

fn void free_expression(void *data)
{
    Expression *self = data;
    self.current.free();
}
