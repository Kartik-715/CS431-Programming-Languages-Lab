:-dynamic(bestPathCost/1).
:-dynamic(bestPaths/1).
bestPathCost(999999).
:-dynamic(isVisited/1).

/* Check if the given path is valid */
valid(List):-
	[H|_] = List,
	source(H),
	verifyPath(List),
	!.

valid(_):-
	write("No Path Found"),
	fail.

/*
    Start from C and traverse all paths and print the ones which end at
    a destination
*/
paths():-
	source(C),
	asserta(isVisited(C)),
	\+ helper(C,[]),
	retract(isVisited(C)),
	fail.

/*
    1. Verify If the database is correct and doesn't contain negative edges
    2. Perform DFS to find all paths
    3. Print Best Paths
*/
optimal:-
	\+ verifyInputDatabase,
	\+ dfs,
	write("The following paths are the shortest:"),
	nl,
	\+ printPaths,
	bestPathCost(Z),
	print_weight(Z).

% Checks if the list is empty or not
is_empty([]).

/* Returns whether there exists an edge between X and Y */ 
edge(X,Y):- weights(X,Y,_).
undirected_edge(X,Y):- weights(X,Y,_).
undirected_edge(X,Y):- weights(Y,X,_).

findWeight(X,Y,Z):- weights(X,Y,Z).
findWeight(Y,X,Z):- weights(X,Y,Z).

/* Verify whether the given path is correct */
verifyPath(List):-
	[H|T] = List, % Case where there is only 1 vertex in the list
	is_empty(T),
	end(H). % Check whether the path ends correctly

verifyPath(List):-
	[X1,X2|_] = List,
	undirected_edge(X1,X2),
	[_|T] = List,
	verifyPath(T).

printPath(_,[]).

printPath(Prefix,[H|T]):-
	is_empty(T), % Only 1 element left
	write(Prefix),
	write(H),
	nl.	

printPath(Prefix,[H|T]):-
	\+ is_empty(T), % Some elements are left in list
	format("~w~w -> ",[Prefix,H]),
	printPath("",T).

helper(C,Path):-
	end(C),
	append(Path,[C],NewPath),
	printPath("",NewPath),
	fail.

helper(C,Path):-
	\+ end(C),
	append(Path,[C],NewPath),
	undirected_edge(C, R),
	\+ isVisited(R),
	asserta(isVisited(R)),	
	\+ helper(R,NewPath),
	retract(isVisited(R)),
	fail.

% Y is the maximum sum until now and Sum is the current Paths sum
update(Y,Sum,Path):-
	Y > Sum, /* Update Y to sum and delete all previous paths store the current path. */
	retract(bestPathCost(Y)),
	asserta(bestPathCost(Sum)),
	retractall(bestPaths(_)),
	assertz(bestPaths(Path)).

update(Y,Sum,Path):-
	Y =:= Sum,
	assertz(bestPaths(Path)).


dfsHelper(_,Sum,_):-
	bestPathCost(Y),
	Sum >= Y, % If current path sum is greater than observed max then just continue 
	fail.

dfsHelper(C,Sum,Path):-
	end(C),
	append(Path,[C],NewPath),	
	bestPathCost(Y),
	update(Y,Sum,NewPath),
	fail.

dfsHelper(C,Sum,Path):-
	\+ end(C),	
	append(Path,[C],NewPath),
    % Edge between C and R
	undirected_edge(C, R),
	findWeight(C,R,Y),
	\+ isVisited(R),
	asserta(isVisited(R)),
    % Update Path Length
	NextSum is Sum+Y,	
	\+ dfsHelper(R,NextSum,NewPath),
	retract(isVisited(R)),
	fail.

dfs:-
    % Start from all the possible sources
	source(C),	
	asserta(isVisited(C)),
	\+ dfsHelper(C,0,[]),
	retract(isVisited(C)),
	fail.

% Prints all the best paths
printPaths:-
	bestPaths(Y),
	printPath("Path: ",Y),
	fail.

% print_weight checks if there is any path. If there is it prints the result.  
print_weight(Z):-
	Z =:= 999999,
	print("No paths found from given start to end").

print_weight(Z):-
	format("Weight of Path: ~w ~n",[Z]).

% Checking if there are any negative weights in the database
verifyInputDatabase:-
	weights(_,_,X) , X < 0,
	print("Negative Edges Found"),
	nl.

/* Defining all the edges defined in the question */
% Weights of all the edges/paths from X to Y containing W weight.
weights('G1','G5',4).
weights('G2','G5',6).
weights('G3','G5',8).
weights('G4','G5',9).
weights('G1','G6',10).
weights('G2','G6',9).
weights('G3','G6',3).
weights('G4','G6',5).
weights('G5','G7',3).
weights('G5','G10',4).
weights('G5','G11',6).
weights('G5','G12',7).
weights('G5','G6',7).
weights('G5','G8',9).
weights('G6','G8',2).
weights('G6','G12',3).
weights('G6','G11',5).
weights('G6','G10',9).
weights('G6','G7',10).
weights('G7','G10',2).
weights('G7','G11',5).
weights('G7','G12',7).
weights('G7','G8',10).
weights('G8','G9',3).
weights('G8','G12',3).
weights('G8','G11',4).
weights('G8','G10',8).
weights('G10','G15',5).
weights('G10','G11',2).
weights('G10','G12',5).
weights('G11','G15',4).
weights('G11','G13',5).
weights('G11','G12',4).
weights('G12','G13',7).
weights('G12','G14',8).
weights('G15','G13',3).
weights('G13','G14',4).
weights('G14','G17',5).
weights('G14','G18',4).
weights('G17','G18',8).

source('G1').
source('G2').
source('G3').
source('G4').

end('G17').