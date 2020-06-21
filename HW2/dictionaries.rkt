#lang dssl2

# HW2: Three Dictionaries
# Due: Wednesday, Jan. 30 at 11:59 PM, via Canvas

# ** You must work on your own for this assignment. **

###
### ACCOUNT DEFINITIONS
###

# The representation of an account.
struct Account:
    let id: nat?
    let owner: str?
    let balance: num?

# Example Accounts:
let ACCOUNT0 = Account(0,  "Alan Turing",    16384)
let ACCOUNT1 = Account(8,  "Grace Hopper",   32768)
let ACCOUNT2 = Account(16, "Ada Lovelace",   32)
let ACCOUNT3 = Account(24, "David Parnas",   2048)
let ACCOUNT4 = Account(32, "Barbara Liskov", 8192)
let ACCOUNT5 = Account(40, "Donald Knuth",   1024)
let ACCOUNT6 = Account(50, "Barack Obama",   102)

# Copies an account structure.
def account_clone(old_account: Account?) -> Account?:
    Account(old_account.id, old_account.owner, old_account.balance)

# Transfers the specified amount from the first account to the second.
def account_transfer(amount: num?, from: Account?, to: Account?) -> VoidC:
    assert(0 <= amount and amount <= from.balance)
    from.balance = from.balance - amount
    to.balance = to.balance + amount


# A LEDGER stores multiple accounts and allows looking up an account
# by ID number.
interface LEDGER:
    # How many accounts are in this ledger?
    def len(self) -> nat?
    # Looks up an account by ID, returning False if not found.
    def lookup(self, id: nat?) -> OrC(Account?, False)

###
### THE LINKED-LIST REPRESENTATION     #LIFO
###

# A BareList is one of:
# - nil()
# - node(Account, BareList)
# where the `account.id` values are unique.
struct nil:
    pass
struct node:
    let element: Account?                   #head
    let link: OrC(nil?, node?)              #next

# ListLedger is a LEDGER that stores the accounts in a linked list.
class ListLedger (LEDGER):
    let contents: OrC(nil?, node?)

    # Constructs the empty ListLedger.
    def __init__(self):
        self.contents = nil()

    # Adds an account to the back of this ListLedger.
    def push_back(self, account: Account?) -> VoidC:
        let new_node = node(account, nil())
        if nil?(self.contents):
            self.contents = new_node
        else:
            let current = self.contents
            while node?(current.link):
                current = current.link
            current.link = new_node

    # Returns the number of accounts in this ListLedger.
    def len(self) -> nat?:
        let current=self.contents
        let count=0
        if nil?(current):
            return count
        else:
            while node?(current):
                current=current.link          #current=current.next
                count=count+1
        return count
#   ^ YOUR DEFINITION HERE            

    # Adds an account to the front of this ListLedger.
    def push_front(self, account: Account?) -> VoidC:
        let newnode=node(account,nil())
        if nil?(self.contents):
            self.contents=newnode
        else:
            newnode.link=self.contents
            self.contents=newnode
#   ^ YOUR DEFINITION HERE            

    # Removes the first account from this ListLedger, or errors on empty.
    def pop_front(self) -> Account?:
        let current=self.contents
        if nil?(current):error('empty')
        elif current.element == current.link: 
            current.link=nil()
        else:
            self.contents=current.link
            return current.element
#   ^ YOUR DEFINITION HERE

    # Looks up an account by ID number, or returns False if not found.
    def lookup(self, id: nat?) -> OrC(Account?, False):
        let current=self.contents
        let match=0
        if nil?(current):return False
        else:
            while not nil?(current):
                if current.element.id==id:
                    match=match+1
                    break
                else:
                    current=current.link
            if match == 1:
                return current.element
            else:
                return False
#   ^ YOUR DEFINITION HERE

# Makes an example ListLedger of 6 accounts.
def _make_example_list_ledger() -> ListLedger?:
    let result = ListLedger()
    result.push_back(account_clone(ACCOUNT0))
    result.push_back(account_clone(ACCOUNT1))
    result.push_back(account_clone(ACCOUNT2))
    result.push_back(account_clone(ACCOUNT3))
    result.push_back(account_clone(ACCOUNT4))
    result.push_back(account_clone(ACCOUNT5))
    result

test 'ListLedger#len':
    assert_eq ListLedger().len(), 0
    assert_eq _make_example_list_ledger().len(), 6
    
test 'ListLedger#push_front':
    let ledger = ListLedger()
    ledger.push_front(ACCOUNT5)
    ledger.push_front(ACCOUNT4)
    ledger.push_front(ACCOUNT3)
    ledger.push_front(ACCOUNT2)
    ledger.push_front(ACCOUNT1)
    ledger.push_front(ACCOUNT0)
    assert_eq ledger, _make_example_list_ledger()
    
test 'ListLedger#pop_front':
    let ledger = _make_example_list_ledger()
    assert_eq ledger.pop_front(), ACCOUNT0
    assert_eq ledger.pop_front(), ACCOUNT1
    assert_eq ledger.pop_front(), ACCOUNT2
    assert_eq ledger.pop_front(), ACCOUNT3
    assert_eq ledger.pop_front(), ACCOUNT4
    assert_eq ledger.pop_front(), ACCOUNT5
    assert_error ledger.pop_front()
    
test 'ListLedger#lookup':
    let ledger = _make_example_list_ledger()
    assert_eq ledger.lookup(0), ACCOUNT0
    assert_eq ledger.lookup(8), ACCOUNT1
    assert_eq ledger.lookup(16), ACCOUNT2
    assert_eq ledger.lookup(24), ACCOUNT3
    assert_eq ledger.lookup(32), ACCOUNT4
    assert_eq ledger.lookup(40), ACCOUNT5
    assert_eq ledger.lookup(48), False
    assert_eq ledger.lookup(100), False

###
### THE BINARY SEARCH TREE REPRESENTATION
###

# A BareBst is one of
# - leaf()
# - branch(BareBst, Account, BareBst)
# where for a branch branch(l, acct, r), all the account.ids in
# l are less than acct.id, and all the account.ids in r are greater
# than acct.id. (This is the binary search tree property.)
struct leaf:
    pass
struct branch:
    let left: OrC(leaf?, branch?)
    let element: Account?
    let right: OrC(leaf?, branch?)

# A LEDGER that stores the accounts in a binary search tree.
class BstLedger (LEDGER):
    let contents: OrC(leaf?, branch?)

    def __init__(self):
        self.contents = leaf()

    def insert(self, account: Account?):
        let new_branch = branch(leaf(), account, leaf())
        if leaf?(self.contents):
            self.contents = new_branch
        else:
            let current = self.contents
            while True:
                if account.id < current.element.id:
                    if branch?(current.left):
                        current = current.left
                    else:
                        current.left = new_branch
                        return
                elif account.id > current.element.id:
                    if branch?(current.right):
                        current = current.right
                    else:
                        current.right = new_branch
                        return
                else: error('already present: %p', account.id)

    # Returns the number of accounts in the BST.
    def len(self) -> nat?: 
        if leaf?(self.contents):return 0            #BST is empty
        elif leaf?(self.contents.left) and leaf?(self.contents.right): return 1      #there is only the root node
        else:
            let count=0
            let current=self.contents
            let temp=self.contents
            if branch?(self.contents.left) and leaf?(self.contents.right):           #case where there are elements to the left but not right
                count=1
                while not leaf?(current):    
                    if branch?(current.left):
                        current=current.left
                        count=count+1
                    else:
                        return count
            elif branch?(self.contents.right) and leaf?(self.contents.left):       #case where there are elements to the right but not left
                count=1
                while not leaf?(temp):
                    if branch?(temp.right):
                        temp=temp.right
                        count=count+1
                    else:
                        return count
            else:
                current=current.right
                temp=temp.right
                if leaf?(current.right) and leaf?(current.left): return 3        #case where there are only three nodes 
                else:                              
                    current=self.contents
                    temp=self.contents
                    count=3                                                      #implies that there are more than three nodes
                    while not leaf?(current.left):                            #so we continue iterating throughout the tree
                        count=count+1
                        current=current.left        
                    
                    while not leaf?(temp.right):
                        count=count+1
                        temp=temp.right
            return count
#   ^ YOUR DEFINITION HERE


    # Looks up an account by ID in the BST, or returns False if not found.
    def lookup(self, id: nat?) -> OrC(Account?, False):
        let current=self.contents
        while not leaf?(current):
            if id<current.element.id:
                current=current.left
            elif id > current.element.id:
                current=current.right
            else:
                return current.element
        return False
#   ^ YOUR DEFINITION HERE


# Makes an example BstLedger of 6 accounts.
def _make_example_bst_ledger() -> BstLedger?:
    let result = BstLedger()
    result.insert(account_clone(ACCOUNT2))
    result.insert(account_clone(ACCOUNT0))
    result.insert(account_clone(ACCOUNT4))
    result.insert(account_clone(ACCOUNT1))
    result.insert(account_clone(ACCOUNT3))
    result.insert(account_clone(ACCOUNT5))
    result

test 'BstLedger#lookup':
    let ledger = _make_example_bst_ledger()
    assert_eq ledger.lookup(0), ACCOUNT0
    assert_eq ledger.lookup(8), ACCOUNT1
    assert_eq ledger.lookup(16), ACCOUNT2
    assert_eq ledger.lookup(24), ACCOUNT3
    assert_eq ledger.lookup(32), ACCOUNT4
    assert_eq ledger.lookup(40), ACCOUNT5
    assert_eq ledger.lookup(48), False
    
test 'BstLedger#len':
    assert_eq BstLedger().len(), 0
    assert_eq _make_example_bst_ledger().len(), 6
    
test 'BST':
    let result=BstLedger()
    result.insert(account_clone(ACCOUNT2))
    result.insert(account_clone(ACCOUNT0))
    result.insert(account_clone(ACCOUNT4))
    result.insert(account_clone(ACCOUNT1))
    result.insert(account_clone(ACCOUNT3))
    assert_eq result.len(), 5
    
test 'OneNode':
    let ledge=BstLedger()
    ledge.insert(account_clone(ACCOUNT2))
    assert_eq ledge.len(), 1
    
test 'length':
    let ledge=BstLedger()
    ledge.insert(account_clone(ACCOUNT2))
    ledge.insert(account_clone(ACCOUNT0))
    assert_eq ledge.len(), 2
    
test 'length1':
    let ledge=BstLedger()
    ledge.insert(account_clone(ACCOUNT0))
    ledge.insert(account_clone(ACCOUNT1))
    ledge.insert(account_clone(ACCOUNT4))
    assert_eq ledge.lookup(32), ACCOUNT4
    assert_eq ledge.len(), 3    
    
test 'length2':
    let ledge=BstLedger()
    ledge.insert(account_clone(ACCOUNT2))
    ledge.insert(account_clone(ACCOUNT0))
    ledge.insert(account_clone(ACCOUNT4))
    assert_eq ledge.len(), 3

def _another_example() -> BstLedger?:
    let result=BstLedger()
    result.insert(account_clone(ACCOUNT0))
    result.insert(account_clone(ACCOUNT1))
    result.insert(account_clone(ACCOUNT2))
    result
    
###
### THE SORTED VECTOR REPRESENTATION
###

# A Ledger that stores the accounts sorted by ID in a vector.
class VecLedger (LEDGER):
    let contents: VecC[Account?]

    # Constructs a new VecLedger from an already-sorted vector of accounts.
    def __init__(self, vec: VecC[Account?]):
        self._assert_sorted(vec)
        self.contents = vec


    # Returns the number of accounts in the ledger.
    def len(self) -> nat?:
        self.contents.len()
        
    # Asserts that the given vector of accounts is sorted by ID; errors
    # if not.
    def _assert_sorted(self, vec):
        let n=1                   #to avoid the initial vec[0-1] bounds error
        for i in vec.len()-1:           #to avoid out-of-bounds error
            if vec[n-1].id>vec[i+1].id:       
                error('not sorted!')
            else:
                n=n+1         #increment the previous element
#   ^ YOUR DEFINITION HERE
       
    
           
    # Looks up an account by ID in the ledger, returning False if not found.
    def lookup(self, id: nat?) -> OrC(Account?, False):
        let current=self.contents
        for i in current.len():
            if current[i].id==id:
                return current[i]
            else:
                pass
        return False
#   ^ YOUR DEFINITION HERE
    
# Makes an example VecLedger of 6 accounts.
def _make_example_vec_ledger() -> VecLedger?:
    VecLedger([ACCOUNT0, ACCOUNT1, ACCOUNT2,
               ACCOUNT3, ACCOUNT4, ACCOUNT5].map(account_clone))
               
                              
test 'VecLedger#lookup':
    let ledger = _make_example_vec_ledger()
    assert_eq ledger.lookup(0), ACCOUNT0
    assert_eq ledger.lookup(8), ACCOUNT1
    assert_eq ledger.lookup(16), ACCOUNT2
    assert_eq ledger.lookup(24), ACCOUNT3
    assert_eq ledger.lookup(32), ACCOUNT4
    assert_eq ledger.lookup(40), ACCOUNT5
    assert_eq ledger.lookup(48), False


###
### WORKING WITH THE LEDGER ADT
###


# Transfers `amount` from account number `from_id` to account number
# `to_id`. Calls `error` if either account isn't found.
def ledger_transfer(amount: num?,
                    from_id: nat?,
                    to_id: nat?,
                    ledger: LEDGER!):
    if not ledger.lookup(from_id) or not ledger.lookup(to_id):      #since if not true, will return false
        error('one or both accounts not found!')
    elif amount<0:                                               #check negative balance
        error('negative amount!')
    else:
        let account1=ledger.lookup(from_id)
        let account2=ledger.lookup(to_id)
        if account1.balance<amount:
            error('amount exceeds account_from balance!')            #check that amount doesn't exceed balance
        else:
            account1.balance=account1.balance-amount
            account2.balance=account2.balance+amount
#   ^ YOUR DEFINITION HERE


test 'ledger_transfer on BstLedger':
    let actual = _make_example_list_ledger()
    ledger_transfer(2000, 32, 24, actual)
    let expected = _make_example_list_ledger()
    expected.lookup(24).balance = 4048
    expected.lookup(32).balance = 6192
    assert_eq actual, expected

test 'ledger_transfer on BstLedger':
   let actual = _make_example_bst_ledger()
   ledger_transfer(2000, 32, 24, actual)
   let expected = _make_example_bst_ledger()
   expected.lookup(24).balance = 4048
   expected.lookup(32).balance = 6192
   assert_eq actual, expected

test 'ledger_transfer on VecLedger':
    let actual = _make_example_vec_ledger()
    ledger_transfer(2000, 32, 24, actual)
    let expected = VecLedger([
        ACCOUNT0,
        ACCOUNT1,
        ACCOUNT2,
        Account(24, "David Parnas", 4048),
        Account(32, "Barbara Liskov", 6192),
        ACCOUNT5
    ])
    assert_eq actual, expected
    
test 'ledger_transfer':
    let actual = _make_example_vec_ledger()
    ledger_transfer(1000, 32, 24, actual)
    let expected = VecLedger([
        ACCOUNT0,
        ACCOUNT1,
        ACCOUNT2,
        Account(24, "David Parnas", 3048),
        Account(32, "Barbara Liskov", 7192),
        ACCOUNT5
    ])
    assert_eq actual, expected
    
test 'big balance':                                      #tests for when input balance is too large
    let ledge=BstLedger()
    ledge.insert(account_clone(ACCOUNT2))
    ledge.insert(account_clone(ACCOUNT0))
    ledge.insert(account_clone(ACCOUNT4))
    assert_error ledger_transfer(20000,0,32)
    assert_error ledger_transfer(-20,0,32)


test 'unsorted_VecLedger':
    assert_error VecLedger([ACCOUNT1, ACCOUNT0, ACCOUNT3])        #checks for unsorted vector. Errors if unsorted, which should pass test
    assert_error VecLedger([ACCOUNT1, ACCOUNT2, ACCOUNT0])







