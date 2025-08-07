module schem;

import std::io;
import schem::debug;
import schem::types;
import schem::runtime;
import std::collections::list;

faultdef NOT_ENOUGH_ARGS, INCORRECT_TYPE;

NativeFunction[] builtins = {
    {"+", &plus},
    {"-", &minus},
    {"*", &multiply},
    {"/", &divide},
    {"%", &modulo}, {"modulo", &modulo},
    {"=", &eql},
    {"<", &lt},
    {"<=", &lte},
    {">", &gt},
    {">=", &gte},
    {"error", &error},
    {"newline", fn Value?(Context *ctx) {
            io::printn();
            return types::NIL;
        }
    },
    {"display", &display},
    {"display_stack", fn Value?(Context *ctx) {
            ctx.rt.print_stack(ctx.env);
            return types::NIL;
        }
    },
};

NativeFunction[] builtin_macros = {
    {"lambda", &lambda}, {"λ", &lambda},
    {"let", &let}, {"set!", &let},
    {"begin", &begin},
    {"if", &cond}, {"cond", &cond},
};

fn Value? cond(Context *ctx) @export("_gdb")
{
    @pool() {
        List{Value*} args;
        args.tinit();

        while (Value *val = ctx.next_arg()) {
            args.push(val);
        }
        usz i = 0;
        usz nargs = args.len();

        if (nargs < 2) return types::NIL;

        for (; i + 1 < nargs; i += 2) {
            Value cond = ctx.eval_value(args.get(i))!;
            if (cond.t != BOOLEAN) {
                break;
            } else {
                if (cond.v.b) return ctx.eval_value(args.get(i + 1));
            }
        }

        if (nargs - i == 1) return ctx.eval_value(args.get(i));
    };

    return types::NIL;
}

fn Value? eql(Context *ctx)
{
    Value res = types::to_bool(true);
    Value *current = ctx.next_arg();

    while (current != null) {
        if (Value *next = ctx.next_arg()) {
            res = current.eql(*next);
            current = next;
            if (res.t == ERROR) return res;
            if (res.v.b == false) return res;
        } else {
            current = null;
        }
    }

    return res;
}

fn Value? lt(Context *ctx)
{
    Value res = types::to_bool(true);
    Value *current = ctx.next_arg();

    while (current != null) {
        if (Value *next = ctx.next_arg()) {
            res = current.lt(*next);
            current = next;
            if (res.t == ERROR) return res;
            if (res.v.b == false) return res;
        } else {
            current = null;
        }
    }

    return res;
}

fn Value? lte(Context *ctx)
{
    Value res = types::to_bool(true);
    Value *current = ctx.next_arg();

    while (current != null) {
        if (Value *next = ctx.next_arg()) {
            res = current.lte(*next);
            current = next;
            if (res.t == ERROR) return res;
            if (res.v.b == false) return res;
        } else {
            current = null;
        }
    }

    return res;
}

fn Value? gt(Context *ctx)
{
    Value res = types::to_bool(true);
    Value *current = ctx.next_arg();

    while (current != null) {
        if (Value *next = ctx.next_arg()) {
            res = current.gt(*next);
            current = next;
            if (res.t == ERROR) return res;
            if (res.v.b == false) return res;
        } else {
            current = null;
        }
    }

    return res;
}

fn Value? gte(Context *ctx)
{
    Value res = types::to_bool(true);
    Value *current = ctx.next_arg();

    while (current != null) {
        if (Value *next = ctx.next_arg()) {
            res = current.gte(*next);
            current = next;
            if (res.t == ERROR) return res;
            if (res.v.b == false) return res;
        } else {
            current = null;
        }
    }

    return res;
}

fn Value? display(Context *ctx)
{
    if (Value *v = ctx.next_arg()) debug::display_value(*v);
    return types::NIL;
}

fn Value? error(Context *ctx)
{
    if (Value *v = ctx.next_arg()) {
        if (v.t != STRING) return types::to_error("error expected a string");
        Value res = *v;
        res.t = ERROR;
        return res;
    }
    return types::to_error("error expected 1 argument");
}

fn Value? begin(Context *ctx)
{
    Value res = types::NIL;
    while (Value *arg = ctx.next_arg()) {
        res = ctx.eval_value(arg)!;
    }

    return res;
}

fn Value? let(Context *ctx)
{
    Value *name = ctx.next_arg();
    Value *expr = ctx.next_arg();

    if (name == null || expr == null) return
        types::to_error("let expected 2 arguemnts");
    if (name.t != SYMBOL) return 
        types::to_error("let expected 1st argument to be a symbol");

    ctx.env.vars[name.v.s] = ctx.eval_value(expr)!;

    return types::to_bool(true);
}

fn Value? lambda(Context *ctx)
{
    Value ret;
    Value *params = ctx.next_arg();
    Value *body = ctx.next_arg();

    if (params == null || body == null) return
        types::to_error("lambda expected 2 arguments");
    if (params.t != EXPRESSION || body.t != EXPRESSION) {
        if (params.t != EXPRESSION) return
            types::to_error("lambda expected 1st argument to be params");

        if (body.t != EXPRESSION) return
            types::to_error("lambda expected 2nd argument to be expresison");
    }

    ret.t = LAMBDA;
    ret.v.l.params = params.v.e;
    ret.v.l.body = body.v.e;
    ret.v.l.captured_env = ctx.env;

    return ret;
}

fn Value? plus(Context *ctx)
{
    Value res = types::to_num(0);

    while (Value *arg = ctx.next_arg()) {
        res += *arg;
    }

    return res;
}

fn Value? minus(Context *ctx)
{
    if (Value *v = ctx.next_arg()) {
        Value res = *v;

        while (Value *arg = ctx.next_arg()) {
            res -= *arg;
        }

        return res;
    }

    return types::to_num(0);
}

fn Value? multiply(Context *ctx)
{
    if (Value *v = ctx.next_arg()) {
        Value res = *v;

        while (Value *arg = ctx.next_arg()) {
            res *= *arg;
        }

        return res;
    }

    return types::to_num(0);
}

fn Value? divide(Context *ctx)
{
    if (Value *v = ctx.next_arg()) {
        Value res = *v;

        while (Value *arg = ctx.next_arg()) {
            res /= *arg;
        }

        return res;
    }

    return types::to_num(0);
}

fn Value? modulo(Context *ctx)
{
    if (Value *v = ctx.next_arg()) {
        Value res = *v;

        while (Value *arg = ctx.next_arg()) {
            res %= *arg;
        }

        return res;
    }

    return types::to_num(0);
}
