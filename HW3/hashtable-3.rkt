#lang dssl2

# HW3: Hash Table
# Due: Wednesday, Feb. 6 at 11:59 PM, via Canvas

# ** You must work on your own for this assignment. **

import cons
import sbox_hash

#IMPORT CONS is like saying:
#STRUCT CONS:
    #let car    HEAD
    #let cdr    NEXT

# The hash table stores its mappings as a linked list of associations:
struct assoc:
    let key
    let value
    
# A signature for the dictionary ADT. The contract parameters `K` and
# `V` are the key and value types of the dictionary, respectively.
interface DICT[K, V]:
    # Returns the number of key-value pairs in the dictionary.
    def len(self) -> nat?
    # Is the given key mapped by the dictionary?
    def mem?(self, key: K) -> bool?
    # Gets the value associated with the given key; calls `error` if the
    # key is not present.
    def get(self, key: K) -> V
    # Modifies the dictionary to associate the given key and value. If the
    # key already exists, its value is replaced.
    def put(self, key: K, value: V) -> VoidC
    # Modifes the dictionary by deleting the association of the given key.
    def del(self, key: K) -> VoidC
    
class LinkedList:
    let _head
    let _tail
    
    def __init__(self):
        self._head=nil()
        self._tail=nil()
        
    def insert(self,key,value):
        self._head=cons(assoc(key,value),self._head)
        if nil?(self._tail):self._tail=self._head
        
    def get_nth(self,key):
        let current=self._head
        while not nil?(current):
            if current.car.key==key:
                return current.car.value
            else:
                current=current.cdr
        error('key not found!')
        
    def set_nth(self,key,val):
        let current=self._head
        while not nil?(current):
            if current.car.key==key:
                current.car.value=val
                break
            else:
                current=current.cdr
                    
    def exists?(self,key):
        let current=self._head
        while not nil?(current):
            if current.car.key==key:
                return True
            else:
                current=current.cdr
        return False
        
                
    def remove(self,key):
        let current=self._head
        let prev=False
        while not nil?(current):
            if current.car==key:
                if prev==False:
                    self._head=current.cdr
                else:
                    prev.cdr=current.car
                if nil?(current.cdr):
                    self._tail=prev
            else:
                prev=current
                current=current.cdr
                

class HashTable[K, V] (DICT):
    let _hash
    let _size
    let _data

    def __init__(self, nbuckets: nat?, hash: HashFunctionC(K)):
        self._hash = hash
        self._size = 0
        self._data = [ LinkedList(); nbuckets ]

    def len(self):
          return self._size
#   ^ YOUR DEFINITION HERE (my method is 1 line)

    def mem?(self, key: K) -> bool?:
        let HashVal=self._hash(key) % self._data.len()
        return self._data[HashVal].exists?(key)
#   ^ YOUR DEFINITION HERE (my method is 6 lines)

    def get(self, key: K) -> V:
        let HashVal=self._hash(key) % self._data.len()
        return self._data[HashVal].get_nth(key)
#   ^ YOUR DEFINITION HERE (my method is 6 lines)

    def put(self, key: K, value: V) -> VoidC:
        if self._data.len()==0: error('empty hash!')
        else:
            let HashVal=self._hash(key) % self._data.len()
            if self._data[HashVal].exists?(key): self._data[HashVal].set_nth(key,value)
            else:
                self._data[HashVal].insert(key,value)
                self._size=self._size+1
#   ^ YOUR DEFINITION HERE (my method is 9 lines)

    def del(self, key: K) -> VoidC:
        if self._data.len()==0:pass
        else:
            let HashVal=self._hash(key) % self._data.len()
            if self._data[HashVal].exists?(key):
                self._data[HashVal].remove(key)
                self._size=self._size-1
#   ^ YOUR DEFINITION HERE (my method is 14 lines)


# A bad string hash function, useful for debugging because it's easily
# predictable.
def make_hash() -> HashFunctionC(str?):              #ADDED THESE TWO LINES. SAME TEMPLATE FROM THE ONE IN sbox_hash (from standard library)
    let sbox = [random_bits(64) for _ in 256 ]
    def first_char_hasher(s: str?) -> int?:
        if s.len() == 0:
            return 0
        else:
            return int(s[0])
    first_char_hasher       

test 'you need more tests':
    let h = HashTable(10, make_sbox_hash())
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.mem?('hello')
    assert_eq h.len(), 1
    assert_eq h.get('hello'), 5
    assert_error h.get('helloo')
    h.put('helloo', 6)
    assert_eq h.len(), 2
    assert_eq h.get('hello'), 5
    assert_eq h.get('helloo'), 6
    h.put('helloo', 10)
    assert_eq h.len(), 2
    assert_eq h.get('hello'), 5
    assert_eq h.get('helloo'), 10
    h.del('nothing')
    assert_eq h.len(), 2
    h.del('hello')
    assert_eq h.len(), 1
    h.del('helloo')
    assert_eq h.len(), 0
    
test 'anotherTest':
    let h = HashTable(15, make_sbox_hash())
    h.put('ZinedineZidane', 5)
    h.put('Mbappe',2)
    h.put('Canada',1)
    h.put('Cannes',12)
    h.put('MrBean',45)
    assert_eq h.get('Mbappe'),2
    assert_eq h.get('ZinedineZidane'),5
    assert_eq h.get('Cannes'),12
    assert_eq h.get('MrBean'),45
    assert_eq h.len(),5
    h.put('ZinedineZidane',10)
    assert_eq h.get('ZinedineZidane'),10
    h.del('Canada')        
    assert_eq h.len(),4
    
test 'stringHaShEr':
    let h=HashTable(10, make_hash())
    let b=HashTable(0,make_hash())
    let x=b
    h.put('apple',34)
    assert_eq h.len(),1
    h.put('zidane',354)
    assert_eq h.len(),2
    assert_eq h.get('apple'),34
    h.put('apple',12)
    assert_eq h.len(),2
    assert_eq h.get('apple'),12
    h.del('apple')
    assert_eq h.len(),1
    assert_error b.put('apps',1)
    assert_eq b,x