/* halfsister(A, B) :- A is half-sister of B */
halfsister(A, B) :-
    /*  
        For this predicate to be true, 
        A and B should only have one common parent  
    */ 
    parent(C, B),
    parent(C, A),
    parent(F, B),
    parent(E, A),
    % Check whether other parent is different
    Cnt1 is 0,
    (not(E = C) -> X = E, Cnt2 is 0; Cnt2 is Cnt1+1),
    (not(F = C) -> Y = F, Cnt3 is 0; Cnt3 is Cnt2+1),
    (Cnt3 =:= 2 -> not(X == Y), true),
    not(A = B),
    % A should be female
    female(A).

% uncle(A, B) :- A is uncle of B
uncle(A, B) :-
    % Parent of A and grandparent of B should be common
    parent(C, B),
    parent(D, C),
    parent(D, A),
    not(parent(A, B)),
    male(A). % A should be a male


/* parent(A, B) :- A is parent of B */
/* Define all the existing data */
parent(jatin,avantika).
parent(jolly,jatin).
parent(jolly,kattappa).
parent(manisha,avantika).
parent(manisha,shivkami).
parent(bahubali,shivkami).

male(kattappa).
male(jolly).
male(bahubali).

female(shivkami).
female(avantika).
