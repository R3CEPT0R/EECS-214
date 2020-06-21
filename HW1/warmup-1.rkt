#lang dssl2

# HW1: DSSL2 Warmup
# Due: Wednesday, January 16 at 11:59 PM, via Canvas

# ** You must work on your own for this assignment. **

###
### ACCOUNTS
###

# An AccountId is a Natural

# An Account is Account(AccountId, String, Number)
class Account:
    let id
    let owner
    let balance

    # Account: AccountId String Number -> Account
    # Constructs an account with the given ID number, owner name, and
    # balance. The balance cannot be negative.
    def __init__(self, id, owner, balance):
        if balance < 0: error('Account: negative balance')
        self.id = id
        self.owner = owner
        self.balance = balance
        
    # clone: -> Account
    # Copies an account structure. This is useful for testing, since
    # you will want to clone any of your example accounts before modifying
    # them; otherwise, the modifications will affect subsequent tests.
    def clone(self):
        Account(self.id, self.owner, self.balance)

    # get_balance: -> Number
    def get_balance(self):
        self.balance

    # get_id: -> AccountId
    def get_id(self): self.id

    # get_owner: -> String
    def get_owner(self): self.owner

    # deposit: Number -> Void
    # Deposits `amount` in the account. `amount` must be non-negative.
    def deposit(self, amount):
        if amount < 0: error('deposit: negative amount')
        self.balance = self.balance + amount

    # withdraw: Number -> Void
    # Withdraws `amount` from the account. `amount` must be non-negative
    # and must not exceed the balance.
    def withdraw(self, amount):
        if amount < 0: error('amount is negative!')
        elif amount > self.balance: error('amount exceeds balance!')
        else: self.balance=self.balance-amount

    #Account.__eq__: Account -> Boolean
    #compares two accounts for equality
    #by comparing their three fields.
    def __eq__(self, other):
        if self.id != other.get_id(): return False
        elif self.owner != other.get_owner(): return False
        elif self.balance != other.get_balance(): return False
        else: return True
            

# Examples:
let ACCOUNT0 = Account(0, "Alan Turing",    16384)
let ACCOUNT1 = Account(1, "Grace Hopper",   32768)
let ACCOUNT2 = Account(2, "Ada Lovelace",   32)
let ACCOUNT3 = Account(3, "David Parnas",   2048)
let ACCOUNT4 = Account(4, "Barbara Liskov", 8192)

test 'Account#withdraw':
    let account = ACCOUNT2.clone()
    assert_eq account.get_balance(), 32
    account.withdraw(10)
    assert_eq account.get_balance(), 22
    assert_error account.withdraw(-10)
    assert_eq account.get_balance(), 22
    assert_error account.withdraw(30)
    assert_eq account.get_balance(), 22
    account.withdraw(22)
    assert_eq account.get_balance(), 0

test 'Account#__eq__':
    assert Account(5, "five", 500) == Account(5, "five", 500)
    assert Account(5, "five", 500) != Account(6, "five", 500)
    assert Account(5, "five", 500) != Account(5, "f1ve", 500)
    assert Account(5, "five", 500) != Account(5, "five", 501)


# account_transfer : Number Account Account -> Void
# Transfers the specified amount from the first account to the second.
# That is, it subtracts `amount` from the `from` account’s balance and
# adds `amount` to the `to` account’s balance.
def account_transfer(amount, from, to): 
        from.withdraw(amount)    #no need for negative balance or big amount check
        to.deposit(amount)       #as withdraw() and deposit() methods alredy check for that 
    
test 'account_transfer':
    let parnas = ACCOUNT3.clone()
    let liskov = ACCOUNT4.clone()
    account_transfer(1000, parnas, liskov)
    assert_eq parnas, Account(3, "David Parnas", 1048)
    assert_eq liskov, Account(4, "Barbara Liskov", 9192)
    
test 'account_transfer_negative':
    let parnas = ACCOUNT3.clone()
    let liskov = ACCOUNT4.clone()
    assert_error account_transfer(-100, parnas, liskov)      #errors because of the negative amount
    
test 'account_transfer_amount_greater_than_balance':
    let parnas = ACCOUNT3.clone()
    let liskov = ACCOUNT4.clone()
    assert_error account_transfer(2049, parnas, liskov)     #errors because amount exceeds available balance in from (parnas)
    
test 'empty_from':
    let parnas = ACCOUNT3.clone()
    let liskov = ACCOUNT4.clone()
    assert_error account_transfer(2048,"" ,liskov)         #empty "from" field
    
test 'empty_to':
    let parnas = ACCOUNT3.clone()
    let liskov = ACCOUNT4.clone()
    assert_error account_transfer(2048,parnas,"")          #empty "to" field
    
test 'empty':
    let parnas = ACCOUNT3.clone()
    let liskov = ACCOUNT4.clone()
    assert_error account_transfer(2048,"","")              #empty "from" & "to" fields
    
test 'no_amount':
    let parnas = ACCOUNT3.clone()
    let liskov = ACCOUNT4.clone()
    assert_error account_transfer("",parnas,liskov)       #empty "amount" field


###
### VECTORS
###

# vec_swap : VecC[X] Natural Natural -> Void
# Swaps the elements with the given indices.
def vec_swap(vec, i, j):
    if vec.len()==0: error('vector is empty!')                          #checks for an empty vector
    elif vec.len()==1 and i>0: error('there is only one element!')      #checks if only 1 element and go out of bounds
    elif vec.len()==1 and j>0: error('there is only one element!')      #same but for j
    elif i>vec.len() or i<0: error('bad i index!')                      #checks for proper indices
    elif j>vec.len() or j<0: error('bad j index!')                      #same but for j
    else:
        let temp=vec[i]
        vec[i]=vec[j]
        vec[j]=temp
    
test 'vec_swap':
    let vec = [ 2, 3, 4, 5, 6 ]
    vec_swap(vec, 1, 3)
    assert_eq vec, [ 2, 5, 4, 3, 6 ]
    vec_swap(vec, 2, 2)
    assert_eq vec, [ 2, 5, 4, 3, 6 ]
    
test 'bad indices':
    let vec=[10,20,30]
    let vec1=[1]
    assert_error vec_swap(vec,20,0)
    assert_error vec_swap(vec,-12,1)         #errors occurs because of a bad index/indices
    assert_error vec_swap(vec,20,-10)
    assert_error vec_swap(vec,0,4)
    assert_error vec_swap(vec,0,-1)
    assert_error vec_swap(vec,-1,-2) 
    assert_error vec_swap(vec1,0,1)
    assert_error vec_swap(vec1,1,0)
    
    
test 'empty_vec_swap':
    let vec=[]
    assert_error vec_swap(vec,1,1)       #errors because of vector is empty


# VecC[X] -> VecC[X]
# Copies a vector.
def vec_copy(vec):
     if vec.len()==0: error('vector is empty!')            #checks for an empty vector
     else:
         return [n for n in vec]

test 'vec_copy':
    let v = [ 2, 3, 4 ]
    let w = vec_copy(v)
    assert_eq v, w
    assert v is not w
    v[0] = 9
    assert_eq v, [ 9, 3, 4 ]
    assert_eq w, [ 2, 3, 4 ]
    
test 'vec_copy_empty':
    assert_error vec_copy([])                 


# vec_copy_resize : Natural VecC[X] -> VecC[X]
# Copies a vector into a new vector of the given length. If the new
# vector is shorter, elements are discarded; if longer, new elements
# are filled with False.
def vec_copy_resize(size, vec):
    if vec.len()==0: return [False for n in size]
    elif size<0: error('size is negative!')
    elif size<vec.len(): 
        let copy=[1*n for i, n in vec if i<size]
        return copy                        
    else:                                  #else if size>vec.len()
        let other=[0;size]
        for i, n in other:
            if i<vec.len(): other[i]=vec[i]
            else: other[i]=False
        return other

test 'vec_copy_resize':
    assert_eq vec_copy_resize(5, [2, 3, 4, 5, 6, 7, 8]), [2, 3, 4, 5, 6]
    assert_eq vec_copy_resize(5, [2, 3, 4]), [2, 3, 4, False, False]
    assert_eq vec_copy_resize(3, [2, 3, 4]), [2, 3, 4]
    assert_eq vec_copy_resize(4, [2, 3, 4]), [2, 3, 4, False]
    assert_eq vec_copy_resize(6, [1,2,3,4,5,6,7,8,9]),[1,2,3,4,5,6]
    
test 'vec_copy_resize_inputs':
    assert_error vec_copy_resize(-1,[1,2,3])
    assert_eq vec_copy_resize(5,[]), [False, False, False, False, False]
    

###
### VECTORS OF ACCOUNTS
###

# find_largest_account : VecC[Account] -> Account
# Finds the account with the largest balance in a non-empty vector of
# accounts. (Don’t worry about ties, and assume the vector is non-empty.)
def find_largest_account(accounts):
    let max=accounts[0]
    for i in accounts:
        if max.get_balance()<i.get_balance():max=i
    return max
    

test 'find_largest_account':
    let f = find_largest_account
    let account1=Account("5","Barack Obama",0)
    let account2=Account("6","f1rstpers0n",1)
    assert_eq f([ACCOUNT0,ACCOUNT1,ACCOUNT2,ACCOUNT3,ACCOUNT4]), ACCOUNT1
    assert_eq f([ACCOUNT4,ACCOUNT3,ACCOUNT2,ACCOUNT1,ACCOUNT0]), ACCOUNT1
    assert_eq f([ACCOUNT0,ACCOUNT2]), ACCOUNT0
    assert_eq f([account1,account2]),account2
    





