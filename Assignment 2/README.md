# Assignment 2 - Prolog
#### Name: Kartik Gupta
#### Roll no. 170101030


## Question - 1

#### How to run
```shell
swipl -l Question_1.pl
```
#### 1.1 - UNCLE

#### Examples
```prolog
?- uncle(A, B). % Finds all A,B such that A is the uncle of B
A = kattappa,
B = avantika ;
false.
```


#### 1.2 - HALF SISTER


#### Examples
```prolog
?- halfsister(A, B). % Finds all A,B such that A is the half-sister of B
A = avantika,
B = shivkami ;
A = shivkami,
B = avantika ;
false.
```
---

## Question - 2

To insert more buses and routes and run your test cases, open the file Question_2.pl and scroll to the bottom
and add buses appropriately according to the syntax:
```prolog
% A Few Buses and Routes have already been added in the file, Check the file to see those
bus(Bus Number, Origin, Destination, Departure Time, Arrival Time, Distance, Cost).
```

#### How to run
```shell
swipl -l Question_2.pl
```

#### Examples
```prolog

?- route('A','B').
Best Path for Optimum Distance is :
A,1->B

Distance for this Path = 8
Time taken in this Path = 0.5
Cost for this Path = 20

Best Path for Optimum Time is :
A,1->B

Distance for this Path = 8
Time taken in this Path = 0.5
Cost for this Path = 20

Best Path for Optimum Cost is :
A,1->B

Distance for this Path = 8
Time taken in this Path = 0.5
Cost for this Path = 20

```

---

## 3 - Question - 3

To run your own input, open the file Question_3.pl and scroll to the bottom
and add your input accordingly
```prolog
weights('SRC', 'DEST', WeightOfEdge). % Define edges between two nodes
source('SRC'). % Define Start Point
end('DEST'). % Define Ending Point

```

#### How to run
```shell
swipl -l Question_3.pl
```

#### Examples
```prolog

?- valid(['G3','G6','G12','G14','G17']). % Will print whether this path is valid or not
true.

?- paths(). % Will print all the possible paths

?- optimal(). % Will print the most optimal paths to escape
The following paths are the shortest:
Path: G3 -> G6 -> G12 -> G14 -> G17
Weight of Path: 19
```
