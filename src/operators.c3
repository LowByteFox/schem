module schem::types;

fn Value Value.add(&self, Value val) @operator(+)
{
    if (self.t != DECIMAL && self.t != NUMBER) return
        to_error("+ expected a number or decimal");

    if (val.t != DECIMAL && val.t != NUMBER) return
        to_error("+ expected a number or decimal");

    if (self.t == DECIMAL) {
        if (val.t == DECIMAL) {
            return to_dec(self.v.d + val.v.d);
        } else {
            return to_dec(self.v.d + (double) val.v.n);
        }
    } else {
        if (val.t == DECIMAL) {
            return to_dec((double) self.v.n + val.v.d);
        } else {
            return to_num(self.v.n + val.v.n);
        }
    }
}

fn Value Value.sub(&self, Value val) @operator(-)
{
    if (self.t != DECIMAL && self.t != NUMBER) return
        to_error("- expected a number or decimal");

    if (val.t != DECIMAL && val.t != NUMBER) return
        to_error("- expected a number or decimal");

    if (self.t == DECIMAL) {
        if (val.t == DECIMAL) {
            return to_dec(self.v.d - val.v.d);
        } else {
            return to_dec(self.v.d - (double) val.v.n);
        }
    } else {
        if (val.t == DECIMAL) {
            return to_dec((double) self.v.n - val.v.d);
        } else {
            return to_num(self.v.n - val.v.n);
        }
    }
}

fn Value Value.mult(&self, Value val) @operator(*)
{
    if (self.t != DECIMAL && self.t != NUMBER) return
        to_error("* expected a number or decimal");

    if (val.t != DECIMAL && val.t != NUMBER) return
        to_error("* expected a number or decimal");

    if (self.t == DECIMAL) {
        if (val.t == DECIMAL) {
            return to_dec(self.v.d * val.v.d);
        } else {
            return to_dec(self.v.d * (double) val.v.n);
        }
    } else {
        if (val.t == DECIMAL) {
            return to_dec((double) self.v.n * val.v.d);
        } else {
            return to_num(self.v.n * val.v.n);
        }
    }
}

fn Value Value.divide(&self, Value val) @operator(/)
{
    if (self.t != DECIMAL && self.t != NUMBER) return
        to_error("/ expected a number or decimal");

    if (val.t != DECIMAL && val.t != NUMBER) return
        to_error("/ expected a number or decimal");

    if (self.t == DECIMAL) {
        if (val.t == DECIMAL) {
            return to_dec(self.v.d / val.v.d);
        } else {
            return to_dec(self.v.d / (double) val.v.n);
        }
    } else {
        if (val.t == DECIMAL) {
            return to_dec((double) self.v.n / val.v.d);
        } else {
            return to_num(self.v.n / val.v.n);
        }
    }
}

fn Value Value.modulo(&self, Value val) @operator(%)
{
    if (self.t != DECIMAL && self.t != NUMBER) return
        to_error("% expected a number or decimal");

    if (val.t != DECIMAL && val.t != NUMBER) return
        to_error("% expected a number or decimal");

    if (self.t == DECIMAL) {
        if (val.t == DECIMAL) {
            return to_dec(self.v.d % val.v.d);
        } else {
            return to_dec(self.v.d % (double) val.v.n);
        }
    } else {
        if (val.t == DECIMAL) {
            return to_dec((double) self.v.n % val.v.d);
        } else {
            return to_num(self.v.n % val.v.n);
        }
    }
}

fn Value Value.eql(&self, Value val)
{
    if (self.t != DECIMAL && self.t != NUMBER) return
        to_error("= expected a number or decimal");

    if (val.t != DECIMAL && val.t != NUMBER) return
        to_error("= expected a number or decimal");

    if (self.t == DECIMAL) {
        if (val.t == DECIMAL) {
            return to_bool(self.v.d == val.v.d);
        } else {
            return to_bool(self.v.d == (double) val.v.n);
        }
    } else {
        if (val.t == DECIMAL) {
            return to_bool((double) self.v.n == val.v.d);
        } else {
            return to_bool(self.v.n == val.v.n);
        }
    }
}

fn Value Value.lt(&self, Value val)
{
    if (self.t != DECIMAL && self.t != NUMBER) return
        to_error("< expected a number or decimal");

    if (val.t != DECIMAL && val.t != NUMBER) return
        to_error("< expected a number or decimal");

    if (self.t == DECIMAL) {
        if (val.t == DECIMAL) {
            return to_bool(self.v.d < val.v.d);
        } else {
            return to_bool(self.v.d < (double) val.v.n);
        }
    } else {
        if (val.t == DECIMAL) {
            return to_bool((double) self.v.n < val.v.d);
        } else {
            return to_bool(self.v.n < val.v.n);
        }
    }
}

fn Value Value.lte(&self, Value val)
{
    if (self.t != DECIMAL && self.t != NUMBER) return
        to_error("<= expected a number or decimal");

    if (val.t != DECIMAL && val.t != NUMBER) return
        to_error("<= expected a number or decimal");

    if (self.t == DECIMAL) {
        if (val.t == DECIMAL) {
            return to_bool(self.v.d <= val.v.d);
        } else {
            return to_bool(self.v.d <= (double) val.v.n);
        }
    } else {
        if (val.t == DECIMAL) {
            return to_bool((double) self.v.n <= val.v.d);
        } else {
            return to_bool(self.v.n <= val.v.n);
        }
    }
}

fn Value Value.gt(&self, Value val)
{
    if (self.t != DECIMAL && self.t != NUMBER) return
        to_error("> expected a number or decimal");

    if (val.t != DECIMAL && val.t != NUMBER) return
        to_error("> expected a number or decimal");

    if (self.t == DECIMAL) {
        if (val.t == DECIMAL) {
            return to_bool(self.v.d > val.v.d);
        } else {
            return to_bool(self.v.d > (double) val.v.n);
        }
    } else {
        if (val.t == DECIMAL) {
            return to_bool((double) self.v.n > val.v.d);
        } else {
            return to_bool(self.v.n > val.v.n);
        }
    }
}

fn Value Value.gte(&self, Value val)
{
    if (self.t != DECIMAL && self.t != NUMBER) return
        to_error(">= expected a number or decimal");

    if (val.t != DECIMAL && val.t != NUMBER) return
        to_error(">= expected a number or decimal");

    if (self.t >= DECIMAL) {
        if (val.t == DECIMAL) {
            return to_bool(self.v.d >= val.v.d);
        } else {
            return to_bool(self.v.d >= (double) val.v.n);
        }
    } else {
        if (val.t == DECIMAL) {
            return to_bool((double) self.v.n >= val.v.d);
        } else {
            return to_bool(self.v.n >= val.v.n);
        }
    }
}

