module schem;

import std::io;
import schem::runtime;
import schem::types;

fn int main(String[] args)
{
    String code = `(+ 3 (+ 2 1))`;
    @pool() {
        Runtime rt;
        rt.tinit();
        display_value(rt.eval(code)!!);
        io::printn();
    };
	return 0;
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
        io::print(v.v.d);
    case STRING:
        io::printf("\"%s\"", v.v.s);
    case SYMBOL:
        io::print(v.v.s);
    case BOOLEAN:
        io::print(v.v.b ? "#t" : "#f");
    case EXPRESSION:
        display(v.v.e);
    default:
        io::eprintfn("Unknown value of type \"%s\"", Type.names[v.t.ordinal]);
    }
}
