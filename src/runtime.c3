module schem::runtime;

import std::io;
import schem;
import schem::parser;
import schem::types;
import schem::gc;
import std::core::mem::allocator;
import std::collections::list;

/* TODO: better naming */
faultdef RUNTIME_ERROR, RUN_ERROR;

struct Runtime {
    Allocator alloc;
    Scope global_scope;
    String error;
    Gc gc;
}

struct Context {
    Expression *args;
    Runtime *rt;
    Scope *env;
}

TrackedObject fake @local;

fn void Runtime.init(&self, Allocator alloc)
{
    self.alloc = alloc;
    self.global_scope.vars.init(alloc);
    self.gc.init(self.alloc);
    fake.marked = true;
    self.global_scope.gc_ref = &fake;
}

fn void Runtime.free(&self)
{
    self.gc.collect();
    self.gc.free();
    self.global_scope.vars.free();
}

fn Scope *Runtime.push_scope(&self, Scope *current = &self.global_scope)
{
    Scope *scope = self.gc.alloc(Scope, &types::mark_scope,
        &types::free_scope);
    scope.previous = current;
    scope.vars.init(self.alloc);
    return scope;
}

fn void Runtime.tinit(&self) => self.init(tmem);

fn Value? Runtime.eval(&self, String code)
{
    Parser parse = parser::tokenize(code, self.alloc)!;
    Expression *expr = parse.parse(&self.gc)!;
    parse.free();
    Value v = {EXPRESSION, {.e = expr}};
    return self.eval_value(&v, &self.global_scope);
}

fn Value? Runtime.eval_value(&self, Value *val, Scope *env)
{
    switch (val.t) {
    case ERROR:
        self.error = val.v.s;
        return RUN_ERROR?;
    case SYMBOL:
        return self.get_value(val.v.s, env)!;
    case EXPRESSION:
        Value v = self.eval_expr(val.v.e, env)!;
        return self.eval_value(&v, env);
    default:
        break;
    }

    return *val;
}

fn Value? Runtime.eval_expr(&self, Expression *expr, Scope *env)
{
    defer self.gc.collect();
    defer self.gc.@mark(env);

    Context arg_iter = { expr, self, env };
    Value *fun = arg_iter.next_arg();
    fun.mark();
    if (fun == null) return RUNTIME_ERROR?;
    switch (fun.t) {
    case SYMBOL:
        String name = fun.v.s;
        foreach (&schem_macro : schem::builtin_macros) {
            if (schem_macro.name == name) {
                Value v = schem_macro.fun(&arg_iter)!;
                v.mark();
                return v;
            }
        }

        foreach (&builtin : schem::builtins) {
            if (builtin.name == name) {
                Context args = { self.eval_args(arg_iter, env)!, self, env };
                Value v = builtin.fun(&args)!;
                v.mark();
                return v;
            }
        }

        Value val = self.get_value(fun.v.s, env)!;
        Value v = self.eval_lambda(arg_iter, val, env)!;
        v.mark();
        return v;
    case EXPRESSION:
        Value val = self.eval_expr(fun.v.e, env)!;
        if (val.t != LAMBDA) return RUNTIME_ERROR?;
        Value v = self.eval_lambda(arg_iter, val, env)!;
        v.mark();
        return v;
    default:
        return RUNTIME_ERROR?;
    }
}

fn Value? Runtime.eval_lambda(&self, Context arg_iter, Value val, Scope *env)
{
    Scope *lambda_scope = val.v.l.captured_env;
    Scope *params_scope = self.push_scope(lambda_scope);

    Context params = { val.v.l.params, self, env };
    Context args = { self.eval_args(arg_iter, env)!, self, env };

    while (Value *current = params.next_arg()) {
        if (current.t == INVALID) break;
        if (current.t != SYMBOL) return RUNTIME_ERROR?;

        Value *arg = args.next_arg();
        if (arg == null) return schem::NOT_ENOUGH_ARGS?;

        params_scope.vars[current.v.s] = *arg;
    }

    return self.eval_expr(val.v.l.body, params_scope);
}

fn Value? Runtime.get_value(&self, String name, Scope *env)
{
    Scope *iter = env;

    while (iter != null) {
        if (try val = iter.vars[name]) return val;
        iter = iter.previous;
    }

    return types::NIL;
}

fn Expression*? Runtime.eval_args(&self, Context args_iter, Scope *env) @local
{
    if (args_iter.args == null) return null;

    Expression *expr = self.gc.alloc(Expression, &types::mark_expression,
        &types::free_expression);
    Expression *iter;
    while (Value *current = args_iter.next_arg()) {
        if (iter != null) {
            iter.next = self.gc.alloc(Expression, &types::mark_expression,
                &types::free_expression);
            iter = iter.next;
        } else {
            iter = expr;
        }

        iter.current = self.eval_value(current, env)!;
    }

    return expr;
}

fn Value* Context.next_arg(&self)
{
    if (self.args == null) return null;
    defer self.args = self.args.next;
    return &self.args.current;
}

fn Value? Context.eval_value(&self, Value *val)
{
    return self.rt.eval_value(val, self.env);
}
