module schem;

import schem::types;
import schem::runtime;

NativeFunction[] builtins = {
    {"+", &add},
};

fn Value add(Context *ctx)
{
    long res;

    while (Value *arg = ctx.next_arg()) {
        res += arg.v.n;
    }

    return types::to_num(res);
}
