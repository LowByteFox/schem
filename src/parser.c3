module schem::parser;

import std::collections::list;
import std::core::mem::allocator;
import schem::lexer;
import schem::types;

faultdef SYNTAX_ERROR;

struct Parser {
    Allocator alloc;
    Lexer lex;
    List{ Token } tokens;
    usz offset;
}

fn void Parser.free(&self)
{
    self.tokens.free();
}

fn Expression*? Parser.parse(&self)
{
    Token current = self.tokens.get(self.offset);
    switch (current.type) {
    case LBRACKET_TOKEN:
        self.offset++;
        return self.parse_expression();
    default:
    }

    return SYNTAX_ERROR?;
}

fn Expression*? Parser.parse_expression(&self) @local
{
    Token current = self.tokens.get(self.offset);
    if (current.type == RBRACKET_TOKEN) {
        self.offset++;
        return null;
    }

    Expression *expr = types::new_expression(self.alloc);
    Expression *iter;
    while (current.type != RBRACKET_TOKEN) {
        if (iter != null) {
            iter.next = types::new_expression(self.alloc);
            iter = iter.next;
        } else {
            iter = expr;
        }
        Value val = self.parse_value()!;
        iter.current = val;
        self.offset++;
        current = self.tokens.get(self.offset);
    }
    self.offset++;

    return expr;
}

fn Value? Parser.parse_value(&self) @local
{
    Value val;
    Token current = self.tokens.get(self.offset);
    String str = self.lex.buffer[current.offset:current.len];
    switch (current.type) {
    case LBRACKET_TOKEN:
        self.offset++;
        val.t = EXPRESSION;
        val.v.e = self.parse_expression()!;
        self.offset--;
    case RBRACKET_TOKEN:
        break;
    case IDENTIFIER_LITERAL:
        val.t = SYMBOL;
        val.v.s = str;
    case NUMBER_LITERAL:
        val.t = NUMBER;
        val.v.n = str.to_long()!;
    case FLOAT_LITERAL:
        val.t = DECIMAL;
        val.v.d = str.to_double()!;
    case STRING_LITERAL:
        val.t = STRING;
        val.v.s = str[1:^2]; /* TODO: unescape strings */
    case BOOLEAN_LITERAL:
        val.t = BOOLEAN;
        val.v.b = str[0] == 't' ? true : false;
    case QUOTE_TOKEN:
        self.offset++;
        val.t = EXPRESSION;
        val.v.e = types::new_expression(self.alloc);
        val.v.e.current.t = SYMBOL;
        val.v.e.current.v.s = "quote";
        current = self.tokens.get(self.offset);
        switch (current.type) {
        case LBRACKET_TOKEN:
            self.offset++;
            val.v.e.next = self.parse_expression()!;
            self.offset--;
        default:
            val.v.e.next = types::new_expression(self.alloc);
            val.v.e.next.current = self.parse_value()!;
        }
    default:
    }
    return val;
}

fn Parser? tokenize(String code, Allocator alloc)
{
    Parser p;
    p.alloc = alloc;
    p.lex.buffer = code;

    p.tokens.init(alloc);
    while (true) {
        Token? current = lexer::next(&p.lex);
        if (catch excuse = current) {
            if (excuse == lexer::NO_TOKEN) break;
            return excuse?;
        } else {
            p.tokens.push(current);
        }
    }

    return p;
}

fn Parser? ttokenize(String code) => tokenize(code, tmem);
