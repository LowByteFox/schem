module schem::lexer;

import std::core::ascii;

faultdef NO_TOKEN, BAD_TOKEN;

enum TokenType : char {
    NUMBER_LITERAL,
    FLOAT_LITERAL,
    STRING_LITERAL,
    BOOLEAN_LITERAL,
    IDENTIFIER_LITERAL,
    QUOTE_TOKEN,
    LBRACKET_TOKEN,
    RBRACKET_TOKEN
}

struct Token {
    TokenType type;
    int offset, len;
}

struct Lexer {
    String buffer;
    int offset;
}

fn Token? next(Lexer *lex)
{
    char current = next_char(lex)!;

    switch (current) {
    case '(':
        return (Token) { LBRACKET_TOKEN, lex.offset - 1, 1 };
    case ')':
        return (Token) { RBRACKET_TOKEN, lex.offset - 1, 1};
    case '\'':
        return (Token) { QUOTE_TOKEN, lex.offset - 1, 1};
    case '\"':
        return lex_string(lex);
    case ';':
        while (next_char(lex)! != '\n');
        return next(lex);
    default:
        if (ascii::is_space(current)) return next(lex);
        if IDENT: (ascii::is_digit(current) || current == '-') {
            if (current == '-' && !ascii::is_digit(peek(lex)!)) break IDENT;
            return lex_number(lex);
        }

        if IDENT: (current == '#') {
            char next = peek(lex)!;
            if (next != 't' && next != 'f') break IDENT;
            next_char(lex)!;
            return (Token) { BOOLEAN_LITERAL, lex.offset - 1, 1};
        }

        return lex_ident(lex);
    }
}

fn char? next_char(Lexer *lex) @local
{
    if (lex.offset == lex.buffer.len) return NO_TOKEN?;
    defer lex.offset++;

    return lex.buffer[lex.offset];
}

fn char? peek(Lexer *lex) @local
{
    if (lex.offset == lex.buffer.len) return NO_TOKEN?;
    return lex.buffer[lex.offset];
}

fn Token? lex_number(Lexer *lex) @local
{
    int start = lex.offset - 1;
    bool is_float = false;

    while (ascii::is_digit(peek(lex)!) ||
        (!is_float && peek(lex)! == '.' && (is_float = true))) lex.offset++;

    if (peek(lex)! == '.') return BAD_TOKEN?;

    return (Token) { is_float ? FLOAT_LITERAL : NUMBER_LITERAL, start,
        lex.offset - start };
}

fn Token? lex_ident(Lexer *lex) @local
{
    int start = lex.offset - 1;
    while (true) {
        char next = peek(lex)!;
        if (ascii::is_space(next) || next == ')') break;
        lex.offset++;
    }

    return (Token) { IDENTIFIER_LITERAL, start, lex.offset - start };
}

fn Token? lex_string(Lexer *lex) @local
{
    int start = lex.offset - 1;
    while (peek(lex)! != '"') {
        if (peek(lex)! == '\\') lex.offset++;
        lex.offset++;
    }
    next_char(lex)!;

    return (Token) { STRING_LITERAL, start, lex.offset - start };
}
