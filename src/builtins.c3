module schem;

import std::io;
import schem::types;
import schem::runtime;

faultdef NOT_ENOUGH_ARGS, INCORRECT_TYPE;

NativeFunction[] builtins = {
    {"+", &plus},
    {"-", &minus},
    {"*", &multiply},
    {"/", &divide},
    {"%", &modulo},
    {"modulo", &modulo},
    {"fault", &crash},
};

NativeFunction[] builtin_macros = {
    {"lambda", &lambda},
    {"let", &let},
    {"begin", &begin},
};

fn Value? begin(Context *ctx)
{
    Value res;
    while (Value *arg = ctx.next_arg()) {
        res = ctx.rt.eval_expr(arg.v.e)!;
    }

    return res;
}

fn Value? let(Context *ctx)
{
    Value *name = ctx.next_arg();
    Value *expr = ctx.next_arg();

    if (name == null || expr == null) return NOT_ENOUGH_ARGS?;
    if (name.t != SYMBOL || expr.t != EXPRESSION) return INCORRECT_TYPE?;

    ctx.rt.current_scope.vars[name.v.s] = ctx.rt.eval_expr(expr.v.e)!;

    return types::to_bool(true);
}

fn Value? lambda(Context *ctx)
{
    Value ret;
    Value *params = ctx.next_arg();
    Value *body = ctx.next_arg();

    if (params == null || body == null) return NOT_ENOUGH_ARGS?;
    if (params.t != EXPRESSION || body.t != EXPRESSION) return INCORRECT_TYPE?;

    ret.t = LAMBDA;
    ret.v.l.params = params.v.e;
    ret.v.l.body = body.v.e;
    if (ctx.rt.current_scope.previous != null) {
        ret.v.l.parent_scope = ctx.rt.current_scope;
    }

    return ret;
}

fn Value? plus(Context *ctx)
{
    long res;

    while (Value *arg = ctx.next_arg()) {
        res += arg.v.n;
    }

    return types::to_num(res);
}

fn Value? minus(Context *ctx)
{
    long res;
    res = ctx.next_arg().v.n;

    while (Value *arg = ctx.next_arg()) {
        res -= arg.v.n;
    }

    return types::to_num(res);
}

fn Value? multiply(Context *ctx)
{
    long res;
    res = ctx.next_arg().v.n;

    while (Value *arg = ctx.next_arg()) {
        res *= arg.v.n;
    }

    return types::to_num(res);
}

fn Value? divide(Context *ctx)
{
    long res;
    res = ctx.next_arg().v.n;

    while (Value *arg = ctx.next_arg()) {
        res /= arg.v.n;
    }

    return types::to_num(res);
}

fn Value? modulo(Context *ctx)
{
    long res;
    res = ctx.next_arg().v.n;

    while (Value *arg = ctx.next_arg()) {
        res %= arg.v.n;
    }

    return types::to_num(res);
}

faultdef ERROR_TEST;

fn Value? crash(Context *ctx)
{
    return ERROR_TEST?;
}
