module schem::runtime;

import std::io;
import schem;
import schem::parser;
import schem::types;
import std::core::mem::allocator;

/* TODO: better naming */
faultdef RUNTIME_ERROR;

struct Runtime {
    Allocator alloc;
    Scope *current_scope;
}

struct Context {
    Expression *args;
    Runtime *rt;
}

fn void Runtime.init(&self, Allocator alloc)
{
    self.alloc = alloc;
    self.push_scope();
}

fn void Runtime.push_scope(&self, Scope *old = null)
{
    if (old != null) {
        self.current_scope = old;
        return;
    }
    Scope *scope = allocator::new(self.alloc, Scope);
    scope.previous = self.current_scope;
    scope.vars.init(self.alloc);
    self.current_scope = scope;
}

<*
 @require self.current_scope.previous != null : "Ensure the global scope is not being poped"
*>
fn void Runtime.pop_scope(&self) => self.current_scope = self.current_scope.previous;

fn void Runtime.tinit(&self) => self.init(tmem);

fn Value? Runtime.eval(&self, String code)
{
    Parser parse = parser::tokenize(code, self.alloc)!;
    Expression *expr = parse.parse()!;
    return self.eval_expr(expr);
}

fn Value? Runtime.get_value(&self, Value *val)
{
    switch (val.t) {
    case SYMBOL:
        return self.get_val(val.v.s)!;
    case EXPRESSION:
        return self.eval_expr(val.v.e)!;
    default:
        break;
    }

    return *val;
}

fn Value? Runtime.eval_expr(&self, Expression *expr)
{
    Context arg_iter = { expr, self };
    Value *fun = arg_iter.next_arg();
    if (fun == null) return RUNTIME_ERROR?;
    switch (fun.t) {
    case SYMBOL:
        String name = fun.v.s;
        foreach (&schem_macro : schem::builtin_macros) {
            if (schem_macro.name == name) return schem_macro.fun(&arg_iter);
        }

        foreach (&builtin : schem::builtins) {
            if (builtin.name == name) {
                Context args = { self.eval_args(arg_iter)!, self };
                return builtin.fun(&args)!;
            }
        }

        Value val = self.get_val(fun.v.s)!;
        return self.eval_lambda(arg_iter, val)!;
    case EXPRESSION:
        Value val = self.eval_expr(fun.v.e)!;
        if (val.t != LAMBDA) return RUNTIME_ERROR?;
        return self.eval_lambda(arg_iter, val)!;
    default:
        return RUNTIME_ERROR?;
    }
    return types::NIL;
}

fn Value? Runtime.eval_lambda(&self, Context arg_iter, Value val)
{
    if (val.v.l.parent_scope != null) self.push_scope(val.v.l.parent_scope);
    defer if (val.v.l.parent_scope != null) self.pop_scope();
    self.push_scope();
    defer self.pop_scope();

    Context params = { val.v.l.params, self };
    Context args = { self.eval_args(arg_iter)!, self };

    while (Value *current = params.next_arg()) {
        if (current.t == INVALID) break;
        if (current.t != SYMBOL) return RUNTIME_ERROR?;

        Value *arg = args.next_arg();
        if (arg == null) return schem::NOT_ENOUGH_ARGS?;

        self.current_scope.vars[current.v.s] = *arg;
    }
    return self.eval_expr(val.v.l.body);
}

fn Value? Runtime.get_val(&self, String name)
{
    Scope *iter = self.current_scope;

    while (iter != null) {
        if (try val = iter.vars[name]) return val;
        iter = iter.previous;
    }

    return NOT_FOUND?;
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
        } else if (current.t == SYMBOL) {
            iter.current = self.get_val(current.v.s)!;
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
