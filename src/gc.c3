module schem::gc;

import std::io;
import schem::types;
import std::core::mem;
import std::core::mem::allocator;
import std::core::mem::mempool;

alias MarkFn = fn bool(void *data);
alias FreeFn = fn void(void *data);

struct TrackedObject {
    void *data;
    MarkFn mark_fun;
    FreeFn free_fun;
    bool marked;
    char screaming; /* if screaming is 0xAA, it's unused space */
}

struct Gc {
    Allocator allocator;
    FixedBlockPool allocs;
}

fn void Gc.init(&self, Allocator alloc)
{
    self.allocator = alloc;
    self.allocs.init_for_type(self.allocator, TrackedObject);
}

fn void Gc.free(&self) => self.allocs.free();

<*
 @require $defined($Type.gc_ref)
*>
macro Gc.alloc(&self, $Type, MarkFn mark_fun, FreeFn free_fun)
{
    TrackedObject *obj = self.allocs.alloc();
    $Type *ptr = allocator::new(self.allocator, $Type);
    ptr.gc_ref = obj;
    obj.data = ptr;
    obj.mark_fun = mark_fun;
    obj.free_fun = free_fun;
    obj.marked = false;
    obj.screaming = 0;

    return ptr;
}

<*
 @require $defined($typeof(*#ptr).gc_ref)
*>
macro Gc.@mark(&self, #ptr)
{
    var $Type = $typeof(#ptr);
    $Type ptr = #ptr;
    ptr.gc_ref.mark();
}

fn void Gc.collect(&self)
{
    self.allocs.@each(; TrackedObject *obj) {
        if (obj.screaming != 0xAA) {
            if (!obj.marked) {
                obj.free_fun(obj.data);
                allocator::free(self.allocator, obj.data);
                self.allocs.dealloc(obj);
            }
        }
    };
}

fn void TrackedObject.mark(&self)
{
    if (self == null) return;
    if (!self.marked) self.marked = self.mark_fun(self.data);
}

module std::core::mem::mempool;

macro FixedBlockPool.@each(&self; @body(obj))
{
	FixedBlockPoolNode *iter = &self.head;

	while (iter)
	{
		void *end = iter.buffer + (iter.capacity * self.block_size);
        void *start = iter.buffer;
        for (;start < end; start += self.block_size) {
            if (iter == self.tail && start >= self.next_free) break;
            @body(start);
        }
		iter = iter.next;
	}
}
