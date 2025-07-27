module schem::runtime;

import std::io;
import schem::parser;
import schem::types;
import schem;
import std::core::mem::allocator;

/* TODO: better naming */
faultdef RUNTIME_ERROR;

struct Runtime {
    Allocator alloc;
}

struct Context {
    Expression *args;
}

fn void Runtime.init(&self, Allocator alloc)
{
    self.alloc = alloc;
}

fn void Runtime.tinit(&self) => self.init(tmem);

fn Value? Runtime.eval(&self, String code)
{
    Parser parse = parser::tokenize(code, self.alloc)!;
    Expression *expr = parse.parse()!;
    return self.eval_expr(expr);
}

fn Value? Runtime.eval_expr(&self, Expression *expr) @local
{
    Context arg_iter = { expr };
    Value *fun = arg_iter.next_arg();
    if (fun == null) return RUNTIME_ERROR?;
    switch (fun.t) {
    case SYMBOL:
        String name = fun.v.s;
        foreach (&builtin : schem::builtins) {
            if (builtin.name == name) {
                Context args = { self.eval_args(arg_iter)! };
                return builtin.fun(&args)!;
            }
        }
        break;
    default:
        return RUNTIME_ERROR?;
    }
    return types::NIL;
}

fn Expression*? Runtime.eval_args(&self, Context args_iter) @local
{
    Expression *expr = allocator::new(self.alloc, Expression);
    Expression *iter;
    while (Value *current = args_iter.next_arg()) {
        if (iter != null) {
            iter.next = allocator::new(self.alloc, Expression);
            iter = iter.next;
        } else {
            iter = expr;
        }
        if (current.t == EXPRESSION) {
            iter.current = self.eval_expr(current.v.e)!;
        } else { iter.current = *current; }
    }

    return expr;
}

fn Value* Context.next_arg(&self)
{
    if (self.args == null) return null;
    defer self.args = self.args.next;
    return &self.args.current;
}
