module schem;

import std::io;
import schem::runtime;
import schem::types;
import schem::debug;
import schem::gc;
import std::core::mem;

fn int main(String[] args)
{
    String code = `(display "Hello, World")`;
    Runtime rt;
    rt.init(mem);
    defer rt.free();

    Value? val = rt.eval(code);
    if (try val) {
        debug::display_value(val);
        io::printn();
    } else if (catch excuse = val) {
        if (excuse == runtime::RUN_ERROR) io::eprintfn("Recieved an error: %s",
                rt.error);
        val!!;
    }
	return 0;
}
