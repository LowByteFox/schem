module schem;

import std::io;
import std::collections::list;
import schem::lexer;

fn int main(String[] args)
{
    String code = `(+ 1 2)`;
    Lexer lex = { code, 0 };

    List{ Token } tokens;
    tokens.init(mem);

    while (true) {
        Token? current = lexer::next(&lex);
        if (catch excuse = current) {
            if (excuse == lexer::NO_TOKEN) break;
            io::printfn("Got error: %s", excuse);
            break;
        } else {
            tokens.push(current);
        }
    }

    @pool() {
        Token[] toks = tokens.to_tarray();
        foreach (tok : toks) {
            io::printn(tok);
        }
    };
	return 0;
}
