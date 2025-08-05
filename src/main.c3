module schem;

import std::io;
import schem::runtime;
import schem::types;
import schem::debug;

fn int main(String[] args)
{
    String code = `
(begin
    (let foo
        (lambda (x y)
            (begin
                (let abc (* y 2))
                (lambda () (begin
                    (display_stack)
                    (+ x abc))))))
    (display ((foo 3 4)))
    (newline)
    (display "Hello, World"))
`;
    @pool() {
        Runtime rt;
        rt.tinit();
        debug::display_value(rt.eval(code)!!);
        io::printn();
    };
	return 0;
}
