module schem;

import schem::types;
import schem::runtime;

NativeFunction[] builtins = {
    {"+", &plus},
    {"-", &minus},
    {"*", &multiply},
    {"/", &divide},
    {"%", &modulo},
    {"modulo", &modulo},
    {"fault", &crash},
};

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
