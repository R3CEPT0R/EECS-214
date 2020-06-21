#lang dssl2

# HW5: Binary Heaps
# Due: Wednesday, Mar. 6, at 11:59 PM, on Canvas

# ** You must work on your own for this assignment. **

interface PRIORITY_QUEUE[X]:
    # Returns the number of elements in the priority queue.
    def len(self) -> nat?
    # Returns the smallest element; error if empty.
    def find_min(self) -> X
    # Removes the smallest element; error if empty.
    def remove_min(self) -> VoidC
    # Inserts an element; error if full.
    def insert(self, element: X) -> VoidC

# Class implementing the PRIORITY_QUEUE ADT as a binary heap.
class BinHeap[X] (PRIORITY_QUEUE):
    let data: VecC[OrC(X, False)]
    let size: nat?
    let lt?:  FunC[X, X, bool?]

    # Constructs a new binary heap with the given capacity and
    # less-than function for type X.
    def __init__(self, capacity, lt?):
        if capacity <0:error('negative capacity!')                    #test for negative capacity
        else:
            self.data=[False;capacity]
            self.lt?=lt?
            self.size=0                  #size here means how many are actually filled in      
#### my method is 4 lines ####

    def len(self):
        return self.size
        
    def capacity(self):                #lets us know of the PQ's capacity
        let count=0
        for i in self.data:
            count=count+1
        return count
#### my method is 2 lines ####

    def insert(self, new_element):
        if(self.size==self.capacity()): error('not enough space!')
        else:
            self.data[self.size]=new_element              #add element
            self.size=self.size+1                         #increase the size
            if self.size>1:
                let index=self.size-1
                let parent=self.parent(index)
                while self.lt?(self.data[index],self.data[parent]):
                    self.swap(index,parent)
                    index=parent
                    if parent !=0:parent=self.parent(index)                    #restore heap invariant 
            
#### my method is 5 lines (not counting helpers) ####

    def find_min(self):
        if self.size==0:error('Priority Queue empty!')
        else: return self.data[0]                      #exploits fact that first element = root = minimum element (in min heap)                         
#### my method is 3 lines ####

    def remove_min(self):
        if self.size==0: error('Priority Queue empty!')
        else:
           self.size=self.size-1
           self.data[0]=False
           self._percolate_down(0)
#### my method is 6 lines (not counting helpers) ####



######################HELPER FUNCTIONS#######################

    # Restores the invariant by moving the element at index
    # i down, if necessary.
    def _percolate_down(self, i: nat?) -> VoidC:
        self.swap(i,self.size)
        let child=self._find_smaller_child(i)
        if child != i:
            while self.lt?(self.data[child],self.data[i]):
                self.swap(i,child)
                i=child
                child=self._find_smaller_child(i)
                if child==i:break
                
#### my method is 5 lines (not counting additional helpers) ####

    # If the element at index i has any children smaller than itself,
    # returns the index of the smallest child; if i has no children,
    # or none of the children is smaller than the element at i,
    # returns i
    def _find_smaller_child(self, i: nat?) -> nat?:
        if self.leftChild(i)>=self.size:return i
        else:
            if self.rightChild(i)>=self.size:return self.leftChild(i)
            else:
                if self.lt?(self.data[self.leftChild(i)], self.data[self.rightChild(i)]):
                    return self.leftChild(i)
                else: return self.rightChild(i)
#### my method is 8 lines (not counting additional helpers) ####


    def swap(self,i,j):
        let k=self.data[j]
        self.data[j]=self.data[i]
        self.data[i]=k


    def heap_lt_?(self,i,j):
        return self.data[i]<self.data[j]
        
    def leftChild(self,i):
        return (i*2)+1
        
    def rightChild(self,i):
        return (i*2)+2
        
    def parent(self,i):
        return (i-1)/2
   

#### my method is 6 lines (not counting additional helpers) ####

    def get_data(self):
        return self.data
        
def length(v):                     #return length of vector
    let count=0
    for i in v:
        count=count+1
    return count


# Sorts a vector of X, given a less-than function for X.
#
# This function performs a heap sort by inserting all of the
# elements of v into a fresh heap, then removing them in
# order and placing them back in v.
def heap_sort[X](v: VecC[X], lt?: FunC[X, X, bool?]) -> VoidC:
    if length(v)==0: return                           #check for empty vector
    else:
        let heap=BinHeap(length(v),lt?)
        for x in v: heap.insert(x)
        let count=0
        for x in heap.get_data():
            v[count]=heap.find_min()
            count=count+1
            heap.remove_min()

#### my function is 7 lines ####

test 'heap sort ascending':
    let v = [3, 6, 0, 2, 1]
    heap_sort(v, λ x, y: x < y)
    assert_eq v, [0, 1, 2, 3, 6]

test 'heap sort descending':
    let v = [3, 6, 0, 2, 1]
    heap_sort(v, λ x, y: x > y)
    assert_eq v, [6, 3, 2, 1, 0]

test 'heap sort strings':
    let v = ['foo', 'bar', 'baz', 'qux', 'quux', 'z']
    heap_sort(v, λ x, y: x < y)
    assert_eq v, ['bar', 'baz', 'foo', 'quux', 'qux', 'z']
    
test 'descending strings':
    let v = ['foo', 'bar', 'baz', 'qux', 'quux', 'z']
    heap_sort(v, λ x, y: x > y)
    assert_eq v, ['z', 'qux', 'quux', 'foo', 'baz', 'bar']
    
test 'empty heap':
    let v=[]
    assert_eq v,[]



#TESTS#
test 'insert, insert, remove_min':
    let h = BinHeap[nat?](10, λ x, y: x < y)
    h.insert(1)
    assert_eq h.find_min(), 1
    h.insert(2)
    assert_eq h.find_min(), 1
    h.remove_min()
    assert_eq h.find_min(), 2

test 'insert 10 elements, then remove':
    let h = BinHeap[nat?](10, λ x, y: x < y)
    for x in [1, 6, 8, 2, 5, 3, 4, 2, 2, 1]: h.insert(x)
    assert_eq h.len(), 10
    assert_eq h.find_min(), 1
    h.remove_min()
    assert_eq h.len(), 9
    assert_eq h.find_min(), 1
    h.remove_min()
    assert_eq h.find_min(), 2
    h.remove_min()
    assert_eq h.find_min(), 2
    h.remove_min()
    assert_eq h.find_min(), 2
    h.remove_min()
    assert_eq h.find_min(), 3
    h.remove_min()
    assert_eq h.find_min(), 4
    h.remove_min()
    assert_eq h.find_min(), 5
    h.remove_min()
    assert_eq h.find_min(), 6
    h.remove_min()
    assert_eq h.find_min(), 8
    h.remove_min()
    assert_eq h.len(), 0
    assert_error h.remove_min()             #removing from empty PQ
    
test 'FULL HEAP':                            #case where we try to insert to an already full heap
    let h = BinHeap[nat?](10, λ x, y: x < y)
    for x in [1, 10, 18, 1, 5, 3, 4, 2, 2, 1]: h.insert(x)
    assert_error h.insert(19)
    
test 'insert':
    let heap = BinHeap[nat?](3, λ x, y: x < y)
    let heap2 = BinHeap[nat?](1, λ x, y: x < y)
    assert_eq heap.get_data(), [False, False, False]
    heap.insert(5)
    assert_eq heap.get_data(), [5, False, False]
    heap.insert(3)
    assert_eq heap.get_data(), [3, 5, False]
    heap.insert(4)
    assert_eq heap.get_data(), [3, 5, 4]
    assert_error heap.insert(2)
    assert_error heap2.insert(-1)            #in our case we wanted natural numbers, so this fails (-1)
    assert_eq heap2.get_data(), [False]
    heap2.insert(1000)
    assert_eq heap2.get_data(), [1000]
    
test 'strings':                                             #test for strings
    let heap = BinHeap[str?](5, λ x, y: x < y)
    heap.insert("s")
    heap.insert("a")
    assert_eq heap.get_data(), ["a", "s", False, False, False]
    heap.insert("as")
    heap.insert("as1")
    assert_eq heap.get_data(), ["a", "as1", "as", "s", False]
    heap.insert("as")
    assert_eq heap.get_data(), ["a", "as", "as", "s", "as1"] 
    
test 'francechampionsdumonde':
    let leschampions=BinHeap[str?](3, λ x, y: x < y)
    leschampions.insert("pavard")
    assert_eq leschampions.get_data(), ["pavard", False, False]
    leschampions.insert("mbappe")
    leschampions.insert("pogba")
    assert_eq leschampions.get_data(), ["mbappe", "pavard", "pogba"]
    
test 'negativeCapacity':
    assert_error BinHeap(-10, λ x,y:x<y)              #test for negative capacity

test 'remove':                                             #test for removals
    let heap = BinHeap[nat?](7, λ x, y: x < y)
    assert_error heap.remove_min()
    heap.insert(5)
    heap.insert(7)
    heap.insert(3)
    heap.insert(6)
    heap.remove_min()
    assert_eq heap.get_data(), [5, 6, 7, False, False, False, False]
    heap.remove_min()
    assert_eq heap.get_data(), [6, 7, False, False, False, False, False]
    heap.remove_min()
    assert_eq heap.get_data(), [7, False, False, False, False, False, False]
    heap.remove_min()
    assert_eq heap.get_data(), [False; 7]            
    assert_error heap.remove_min()
    
test 'negatives':
    let negatives=BinHeap(5, λ x,y: x<y)
    negatives.insert(-5)
    negatives.insert(-1)
    negatives.insert(0)
    assert_eq negatives.get_data(), [-5,-1,0,False,False]
    assert_eq negatives.leftChild(0),1
    assert_eq negatives.rightChild(0),2
    
    