# Assignment 3 - Haskell
#### Name: Kartik Gupta
#### Roll no. 170101030


## Q1: Implement Haskell Functions for Basic Set Operations

#### How to run
```shell
ghci q1/q1.hs
```
#### Examples

```haskell

*Main> unionSet [1,2] [1,2,5]
[1,2,5]
*Main> unionSet [1,2,3,4] [1,2,5,7]
[3,4,1,2,5,7]
*Main> isEmpty []
True
*Main> isEmpty [2]
False
*Main> subtraction [1,2,3,4] [1,2,3]
[4]
*Main> intersection [1,2,3,4] [1,2,3]
[1,2,3]
```

-----

## 2 - IITG Football League

#### Steps to run
```shell
cabal install random --lib # Required for system.random library
ghci q2/q2.hs
```

#### Examples
```haskell

*Main> fixture "all"
CS vs MA     1-12-2020     9:30AM
CV vs DS     1-12-2020     7:30PM
HU vs BS     2-12-2020     9:30AM
CH vs ME     2-12-2020     7:30PM
CM vs PH     3-12-2020     9:30AM
EE vs ST     3-12-2020     7:30PM

*Main> fixture "all"
HU vs CV     1-12-2020     9:30AM
CM vs MA     1-12-2020     7:30PM
DS vs BS     2-12-2020     9:30AM
CH vs ME     2-12-2020     7:30PM
CS vs PH     3-12-2020     9:30AM
EE vs ST     3-12-2020     7:30PM

*Main> fixture "DS"
DS vs BS     2-12-2020     9:30AM

*Main> nextMatch 2 15.00
CH vs ME     2-12-2020     7:30PM
*Main> nextMatch 2 8.00
DS vs BS     2-12-2020     9:30AM

```

---

## Q3: House Planner

#### Steps to run
```shell
ghci q3/q3.hs
```

#### Examples
```haskell
-- Note: The design function takes a while to run, it could run for 15-20 seconds depending on the PC
*Main> design 2000 3 2
Bedroom: 3 (11 X 15)
Hall: 2 (20 X 15)
Kitchen: 1 (9 X 13)
Bathroom: 4 (8 X 9)
Garden: 1 (20 X 20)
Balcony: 1 (10 X 10)
Unused Space: 0

*Main> design 990 3 2
Bedroom: 3 (10 X 10)
Hall: 2 (15 X 10)
Kitchen: 1 (7 X 5)
Bathroom: 4 (4 X 5)
Garden: 1 (12 X 20)
Balcony: 1 (5 X 7)
Unused Space: 0
```