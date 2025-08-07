module schem::debug;

import std::io;
import schem::runtime;
import schem::types;

fn void Runtime.print_stack(&self, Scope *env)
{
    Scope *iter = env;

    while (iter != null) {
        if (!iter.vars.is_empty()) {
            io::printn("=== Stack Frame ===");
            iter.vars.@each(; String key, Value val) {
                io::printf("  | %s => ", key);
                display_value(val);
                io::printn();
            };
        }
        iter = iter.previous;
    }
}

fn void display(Expression *e)
{
    io::print("(");
    Expression *iter = e;
    while (iter != null) {
        display_value(iter.current);
        iter = iter.next;
        if (iter != null) io::print(" ");
    }
    io::print(")");
}

fn void display_value(Value v)
{
    switch (v.t) {
    case NUMBER:
        io::print(v.v.n);
    case DECIMAL:
        io::printf("%.17f", v.v.d);
    case STRING:
        io::printf("\"%s\"", v.v.s);
    case SYMBOL:
        io::print(v.v.s);
    case BOOLEAN:
        io::print(v.v.b ? "#t" : "#f");
    case EXPRESSION:
        display(v.v.e);
    case LAMBDA:
        io::print("(lambda ");
        display(v.v.l.params);
        io::print(" ");
        display(v.v.l.body);
        io::print(")");
    case INVALID:
        io::print("nil");
        break;
    default:
        io::eprintfn("Unknown value of type \"%s\"", Type.names[v.t.ordinal]);
    }
}
