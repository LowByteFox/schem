module schem;

import std::io;
import schem::runtime;
import schem::types;
import schem::debug;

fn int main(String[] args)
{
    String code = `
(begin
    (let bind
        (lambda (fn x)
            (lambda (y) (fn x y))
        )
    )
    (let add (lambda (x y)
                (+ x y))
    )
    (let bound (bind add 3))
    (bound 4)
)
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
