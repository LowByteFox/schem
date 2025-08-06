module schem;

import std::io;
import schem::runtime;
import schem::types;
import schem::debug;

fn int main(String[] args)
{
    String code = `
(begin
    (let twice 
        (lambda (fn arg)
            (fn (fn arg))))
    (twice (lambda (x) (+ x 3)) 7))
`;
    @pool() {
        Runtime rt;
        rt.tinit();
        debug::display_value(rt.eval(code)!!);
        io::printn();
    };
	return 0;
}
