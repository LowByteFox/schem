module schem;

import std::io;
import schem::runtime;
import schem::types;
import schem::debug;

fn int main(String[] args)
{
    String code = `
(begin
    (let fib
        (lambda (n)
            (if (<= 2 n)
                (+ (fib (- n 1)) (fib (- n 2)))
                n)))
    (fib 10))
`;
    @pool() {
        Runtime rt;
        rt.tinit();

        Value? val = rt.eval(code);
        if (try val) {
            debug::display_value(val);
            io::printn();
        } else if (catch excuse = val) {
            if (excuse == runtime::RUN_ERROR) io::eprintfn("Recieved an error: %s",
                rt.error);
            val!!;
        }
    };
	return 0;
}
