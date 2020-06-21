#lang dssl2

# HW4: Graph
# Due: Wednesday, Feb. 27 at 11:59 PM, via Canvas

# ** You must work on your own for this assignment. **

import cons

###
### REPRESENTATION
###

# A Vertex is a Natural.
let Vertex? = nat?

# A VertexList is a ListOf[Vertex]
let VertexList? = Cons.ListC[Vertex?]

# A Weight is a Number.
let Weight? = num?

# A OptWeight is one of:
# - Weight
# - False
let OptWeight? = OrC(Weight?, False)

# A WEdge is WEdge(Vertex, Vertex, Weight)
struct WEdge:
    let u: Vertex?
    let v: Vertex?
    let w: Weight?

# A WEdgeList is a ListOf[WEdge]
let WEdgeList? = Cons.ListC[WEdge?]

interface WU_GRAPH:
    # Returns the number of vertices in the graph. (The vertices
    # are numbered 0, 1, ..., k - 1.)
    def len(self) -> nat?
    # Sets the weight of the edge between u and v to be w. Passing
    # False for w removes the edge.
    def set_edge(self, u: Vertex?, v: Vertex?, w: OptWeight?) -> VoidC
    # Gets the weight of the edge between u and v, or False if there
    # is no edge.
    def get_edge(self, u: Vertex?, v: Vertex?) -> OptWeight?
    # Gets a list of all vertices adjacent to v. (The order of the
    # list is unspecified.)
    def get_adjacent(self, v: Vertex?) -> VertexList?
    # Gets a list of all edges in the graph, in unspecified order.
    # This should only include one direction for each edge. For
    # example, if there is an edge with weight 10 between vertices
    # 1 and 3, then either WEdge(1, 3, 10) or WEdge(3, 1, 10) should
    # be in the result list, but not both.
    def get_all_edges(self) -> WEdgeList?

class WuGraph (WU_GRAPH):
    #IN MY CASE, I CHOSE TO GO WITH AN ADJACENCY MATRIX REPRESENTATION
    let master_matrix: VecC
    
    def __init__(self, size: nat?):
        self.master_matrix=[0;size]
        for i in size:
            let vec=[False;size]                   #INITIALLY SET TO FALSE
            self.master_matrix[i]=vec
            
### ^ YOUR CODE HERE
#FUNCTIONS FOR THE ADJACENCY MATRIX

    def len(self):
        return self.master_matrix.len()

    def set_edge(self, u, v, weight):            
        self.master_matrix[u][v]=weight
        self.master_matrix[v][u]=weight
            
    def get_edge(self, u, v):
        return self.master_matrix[u][v]             #SIMPLY RETURN THE EDGE. NO NEED TO CHECK IF IT EXISTS SINCE IF IT DOESN'T, IT WILL BE FALSE BY DEFAULT

    def get_adjacent(self, v):
        let list=nil()            #MAKE A LIST
        let i=0
        while(i <self.master_matrix[v].len()):
            if self.master_matrix[v][i]:
                list=cons(i,list)               #ADD i (the neighbor) TO THE LIST 
            i=i+1                               #INCREMENT (GO TO THE NEXT ONE)
        return list     

    def get_all_edges(self):
        let list=nil()
        let i=0
        while(i<self.master_matrix.len()):
            let j=0
            while(j<self.master_matrix[i].len()):
                if (i<=j and self.master_matrix[i][j]):            #AVOIDS REDUNDANT EDGES
                    list=cons(WEdge(i,j,self.master_matrix[i][j]),list)
                j=j+1
            i=i+1
        return list                

###
### GRAPH EXAMPLES
###

def EX_GRAPH1() -> WuGraph?:
    let result = WuGraph(4)  # 4-vertex graph from the assignment
    let add = result.set_edge
    add(0, 1, 2)
    add(1, 2, 3)
    add(2, 3, 4)
    add(3, 0, 5)
    result

## FILL THIS IN:
def EX_GRAPH2() -> WuGraph?:
    let result = WuGraph(6)  # 6-vertex graph from the assignment
    let add = result.set_edge
    add(0, 1, 5)
    add(1, 2, 1)
    add(1, 3, 3)
    add(2, 4, 2)
    add(2, 5, 7)
    add(3, 4, 4)
    add(3, 5, 6)
    result


###
### List helpers
###

# For testing functions that return lists, we provide a function for
# constructing a list from a vector, and functions for sorting (since
# the orders of returned lists are not determined).

# list : VecOf[X] -> ListOf[X]
# Makes a linked list from a vector.
def list(vec: vec?) -> Cons.list?:
    Cons.from_vec(vec)

# sort_vertices : ListOf[Vertex] -> ListOf[Vertex]
# Sorts a list of numbers.
def sort_vertices(lst: Cons.list?) -> Cons.list?:
    Cons.sort[Vertex?](λ u, v: u < v, lst)

# sort_edges : ListOf[WEdge] -> ListOf[WEdge]
# Sorts a list of weighted edges, lexicographically
def sort_edges(lst: Cons.list?) -> Cons.list?:
    def edge_lt?(e1, e2):
        e1.u < e2.u or (e1.u == e2.u and e1.v < e2.v)
    Cons.sort[WEdge?](edge_lt?, lst)

###
### DFS
###

# dfs : WU_GRAPH Vertex [Vertex -> Void] -> Void
# Performs a depth-first search starting at `start`, applying `f`
# to each vertex once as it is discovered by the search.
def dfs(graph: WU_GRAPH!, start: Vertex?, f: FunC[Vertex?, VoidC]) -> VoidC:
    let length=graph.len()
    let preds=[False; length]
    def visit(v):
        if (preds[v]==False):
            preds[v]=True
            f(v)
            let adj=sort_vertices(graph.get_adjacent(v))
            while adj != nil():
                visit(adj.car)
                adj=adj.cdr
    visit(start)

# dfs_to_list : WU_GRAPH Vertex -> ListOf[Vertex]
# Performs a depth-first search starting at `start` and returns a
# list of all reachable vertices.
#
# This function uses your `dfs` function to build a list in the
# order of the search. It will pass the tests below if your dfs visits
# each reachable vertex once, regardless of the order in which it calls
# `f` on them. However, you should test it more thoroughly than that
# to make sure it is calling `f` (and thus exploring the graph) in
# a correct order.
def dfs_to_list(graph: WU_GRAPH!, start: Vertex?) -> VertexList?:
    let builder = ConsBuilder()
    dfs(graph, start, builder.snoc)
    builder.take()

###
### TESTING
###

## You should test your code thoroughly. Here are some tests to get you
## started:

test 'len':
    assert_eq EX_GRAPH1().len(), 4
    assert_eq EX_GRAPH2().len(), 6
    let empty=WuGraph(0)
    assert_eq empty.len(),0

test 'get_edge':
    assert_eq EX_GRAPH1().get_edge(0, 1), 2
    assert_eq EX_GRAPH2().get_edge(0, 2), False

test 'get_adjacent':
    # We sort the result, since the ADT does not define the order of the list.
    assert_eq sort_vertices(EX_GRAPH1().get_adjacent(0)), list([1, 3])
    assert_eq sort_vertices(EX_GRAPH2().get_adjacent(3)), list([1, 4, 5])

test 'set_edge':
    let graph = WuGraph(5)
    graph.set_edge(1, 3, 10)
    assert_eq graph.get_edge(1, 3), 10
    assert_eq graph.get_edge(3, 1), 10
    assert_eq graph.get_edge(4, 1), False
    graph.set_edge(1,3,11)                          #if edge exists, weight is updated
    assert_eq graph.get_edge(1,3),11
    assert_eq graph.get_edge(3,1),11
    graph.set_edge(0,1,False)
    assert_eq graph.get_edge(1,0),False
    assert_eq graph.get_edge(0,1),False             #if it is false, removed and set to false

test 'get_all_edges':
    # We sort the result, since the ADT does not define the order of the list.
    assert_eq sort_edges(EX_GRAPH1().get_all_edges()), list([
        WEdge(0, 1, 2),
        WEdge(0, 3, 5),
        WEdge(1, 2, 3),
        WEdge(2, 3, 4)
    ])

test 'dfs_to_list(EX_GRAPH1())':
    assert_eq sort_vertices(dfs_to_list(EX_GRAPH1(), 0)), list([0, 1, 2, 3])

test 'dfs_to_list(EX_GRAPH2())':
    let expected = list([0, 1, 2, 3, 4, 5])
    assert_eq sort_vertices(dfs_to_list(EX_GRAPH2(), 0)), expected

test 'dfs_to_list order':
    let graph = WuGraph(3)
    graph.set_edge(0, 2, 10)
    assert_eq dfs_to_list(graph, 0), list([0, 2])


#MORE TESTS (A graph with a cycle, a graph with a self edge, and a disconnected graph)
def CycleGraph() -> WuGraph?: 
    let result = WuGraph(4)
    let add = result.set_edge
    add(0, 1, 10)
    add(1, 2, 12)
    add(1, 3, 34)
    add(3, 0, 17)
    result

def SelfEdge() -> WuGraph?:
    let result = WuGraph(1) 
    let add = result.set_edge
    add(0, 0, 1)
    result
    
def Disconnected() -> WuGraph?:
    let result = WuGraph(9)
    let add = result.set_edge
    add(1, 6, 100)
    add(0, 1, 13)
    add(5, 6, 19)
    add(6, 8, 2)
    add(3, 2, 3)
    add(4, 3, 7)
    result
    
test 'GraphWithCycle': #Case where the graph has a cycle
    let expected = list([0,1,2,3])
    assert_eq sort_vertices(dfs_to_list(CycleGraph(), 0)), expected

test 'GraphWithSelfEdge':  #Case where the graph has a self edge 
    let expected = list([0])
    assert_eq sort_vertices(dfs_to_list(SelfEdge(), 0)), expected

test 'DisconnectedGraph': #Case where the graph has multiple subgraphs
    let expected1 = list([0, 1, 5, 6, 8])
    assert_eq sort_vertices(dfs_to_list(Disconnected(), 0)), expected1
    let expected2 = list([2, 3, 4])
    assert_eq sort_vertices(dfs_to_list(Disconnected(), 2)), expected2
    let expected3 = list([7])
    assert_eq sort_vertices(dfs_to_list(Disconnected(), 7)), expected3
