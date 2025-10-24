module schem::types;

import schem::runtime;
import std::collections::map;
import std::core::mem::allocator;

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
    Scope *captured_env;
}

struct Scope {
    HashMap{String,Value} vars;
    Scope *previous;
    uint count;
}

const Value NIL = {INVALID, {0}};
fn Value to_num(long num) => {NUMBER, {.n = num}};
fn Value to_dec(double num) => {DECIMAL, {.d = num}};
fn Value to_bool(bool val) => {BOOLEAN, {.b = val}};
fn Value to_error(String str) => {ERROR, {.s = str}};

struct Expression {
    Value current;
    Expression *next;
    uint count;
}

fn Expression *new_expression(Allocator alloc)
{
    Expression *expr = allocator::new(alloc, Expression);
    expr.count = 1;

    return expr;
}

fn Expression *Expression.dup(&self)
{
    self.count++;

    if (self.next) self.next.dup();

    return self;
}

fn Expression *Expression.free(&self, Allocator alloc)
{
    if (self.next) self.next = self.next.free(alloc);

    if (--self.count == 0) {
        allocator::free(alloc, self);
        return null;
    }

    return self;
}

fn void Scope.free(&self, Allocator alloc)
{
    if (self.previous) self.previous.free(alloc);

    if (--self.count > 0) return;

    self.vars.@each(; String key, Value val) {
        val.free(alloc);
    };
    self.vars.free();
    allocator::free(alloc, self);
}

fn Scope *Scope.dup(&self)
{
    self.count++;

    if (self.previous) self.previous.dup();

    return self;
}

fn void Value.free(&self, Allocator alloc)
{
    if (self.t == EXPRESSION) {
        self.v.e.free(alloc);
    } else if (self.t == LAMBDA) {
        self.v.l.params.free(alloc);
        self.v.l.body.free(alloc);
        self.v.l.captured_env.free(alloc);
    }
}
