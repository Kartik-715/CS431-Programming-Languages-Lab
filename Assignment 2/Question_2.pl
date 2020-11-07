% Computes the optimal path between source and destination
route(Start, End) :-

    % Optimize by Distance
	(findOptimalPath(Start, End, 'Distance') -> true ;
    	write('No path exists!'), false),
    
	% Optimize by Time
	(findOptimalPath(Start, End, 'Time') -> true ;
    	write('No path exists!'), false),

	% Optimize by Cost
	(findOptimalPath(Start, End, 'Cost') -> true ;
        write('No path exists!'), false).


% Base Case -> If all are visited, return the final costs and parents
dijkstra([], VisitedSet, _, VisitedSet, ParentList, ParentList).


/*
	This does the following:
	1. Find the vertex V with minWeight until now in the CurrentSet
	2. Find all neighbours of V
	3. Filter unvisited neighbours
	4. Relaxe the adjacent vertices of V and update the CurrentSet
	5. Recursively call for remaining vertices

*/
dijkstra(CurrentSet, VisitedSet, TypeOfOptimization, MinDist, ParentList, FinalParentList) :-
	findMinWeight(CurrentSet, V-D, RestCurrentSet), 
	findNeighbours(V, Neighbours, TypeOfOptimization), 
	filterUnvisitedNeighbours(Neighbours, VisitedSet, UpdatedNeighbours),  
	update(UpdatedNeighbours, RestCurrentSet, V, D, UpdatedCurrentSet, ParentList, NewParent, TypeOfOptimization), 
	dijkstra(UpdatedCurrentSet, [V-D|VisitedSet], TypeOfOptimization, MinDist, NewParent, FinalParentList). 



% BASE CASE -> If no vertex is left, return the remaining set of vertices
update([], CurrentSet, _, _, CurrentSet, ParentList, ParentList, _).

/*
	1. Find the waiting time at this vertex
	2. If TypeOfOptimization is Time:
		Add Waiting Time to the weight of edge
	3. Update all the neighbours of the V and update the CurrentSet

*/
update([V1-D1|T], CurrentSet, V, D, UpdatedCurrentSet, ParentList, FinalParentList, TypeOfOptimization) :-
    findWaitingTime(ParentList.get(V), V, V1, WaitingTime),
    (TypeOfOptimization == 'Time' ->
		% If Optimization Parameter is time, then compute the waiting time and add it
		( 
            removeFromList(CurrentSet, V1-D2, RestCurrentSet) -> 
            (D + D1 + WaitingTime < D2 -> 
                    NewWeight is D + D1 + WaitingTime, NewParent = ParentList.put(V1, V); 
                    NewWeight is D2, NewParent = ParentList);
            RestCurrentSet = CurrentSet, NewWeight is D + D1 + WaitingTime, NewParent = ParentList.put(V1, V)
        );
		( 
		removeFromList(CurrentSet, V1-D2, RestCurrentSet) -> 
            (D + D1 < D2 -> 
                    NewWeight is D + D1, NewParent = ParentList.put(V1, V); 
                    NewWeight is D2, NewParent = ParentList);
            RestCurrentSet = CurrentSet, NewWeight is D + D1, NewParent = ParentList.put(V1, V)
        )
    ),

    UpdatedCurrentSet = [V1-NewWeight|SubUpdatedCurrentSet],
    % Call this function recursively
	update(T, RestCurrentSet, V, D, SubUpdatedCurrentSet, NewParent, FinalParentList, TypeOfOptimization).

% Base Case: Waiting Time at Start will be 0
findWaitingTime('', _, _, WaitingTime) :-
	WaitingTime is 0.

% Waiting time is the time I have to wait before i hop onto the next bus
findWaitingTime(Parent, CurrentVertex, NextVertex, WaitingTime) :-
	bus(_, Parent, CurrentVertex, _, ArrivalTime, _, _),
	bus(_, CurrentVertex, NextVertex, DepartureTime, _, _, _),
	% Using DepartureTime - ArrivalTime as the total Waiting Time of this destination
	(DepartureTime > ArrivalTime -> WaitingTime is DepartureTime - ArrivalTime
			  ; WaitingTime is 24 + DepartureTime - ArrivalTime).


% Find all neighbours of U
findNeighbours(U, Neighbours, TypeOfOptimization) :-
	(setof(V-D, fetchEdgeData(U, V, D, TypeOfOptimization), TempNeighbours) *-> TempNeighbours = Neighbours; Neighbours = []).

filterUnvisitedNeighbours([], _, []).

% Remove Visited vertices from the list
filterUnvisitedNeighbours([H|T], VisitedSet, UpdatedNeighbours) :-
    H = V-_,
    (member(V-_, VisitedSet) -> UpdatedNeighbours = SubNewNeighbours ; UpdatedNeighbours = [H|SubNewNeighbours]),
    % Recursive call
	filterUnvisitedNeighbours(T, VisitedSet, SubNewNeighbours).


findMinWeightUtility(Cur, [], Cur, []). 

findMinWeightUtility(Cur, [H|T], MinV, [H2|RestCurrentSet]) :-
	H = _-D1, Cur = _-D,
    (D1 < D -> NextM = H, H2 = Cur ; NextM = Cur, H2 = H),
    % Call recursivly
	findMinWeightUtility(NextM, T, MinV, RestCurrentSet).

% Returns the vertex with minimum weight from VertexSet
findMinWeight([H|T], MinV, VertexSet) :-
	findMinWeightUtility(H, T, MinV, VertexSet).

% It calculates minimum travel weight sum from source to destination based on "Optimization Parameter"
findOptimalPath(Start, End, TypeOfOptimization) :-
	dict_create(ParentList, parent, [Start='']),
	dijkstra([Start-0], [], TypeOfOptimization, _, ParentList, NewParent), % Call Djikstra for  Source Vertex and return final parent as NewParent
	get_dict(End, NewParent, _), % Checks if Destination is reachable from Source Vertex or not

	% Prints optimal path along with minimum distance, time and cost
    write('Best Path for Optimum '), write(TypeOfOptimization), write(' is :\n'),
	printOptimalPath(Start, End, NewParent, Distance, Time, Cost), write('\n\n'),
	write('Distance for this Path = '), write(Distance), write('\n'),
	write('Time taken in this Path = '), write(Time),  write('\n'),
	write('Cost for this Path = '), write(Cost), write('\n\n').

% This is the base case, in the case when Start = End
printOptimalPath(Start, Start, _, 0, 0, 0) :-
	write(Start).
% Prints optimal path and computes minimum distance, time and cost
printOptimalPath(Start, End, Parent, Distance, Time, Cost) :-
	% Call printOptimalPath recursively for parent of End
	printOptimalPath(Start, Parent.get(End), Parent, D1, T1, C1),
	fetchEdgeData(Parent.get(End), End, B, D2, T2, C2),

	% Obtain the Waiting Time, If I'm at the Source then WaitingTime is 0
	(get_dict(Parent.get(End), Parent, _) -> findWaitingTime(Parent.get(Parent.get(End)), Parent.get(End), End, WaitingTime);
			WaitingTime is 0),
	Distance is D1 + D2, Time is T1 + T2 + WaitingTime, Cost is C1 + C2,
	write(','), write(B), write('->'), write(End).


% Puts Distance into EdgeWeight
fetchEdgeData(Vertex1, Vertex2, EdgeWeight, 'Distance') :-
	bus(_, Vertex1, Vertex2, _, _, EdgeWeight, _).

% Puts Time Taken into EdgeWeight
fetchEdgeData(Vertex1, Vertex2, EdgeWeight, 'Time') :-
	bus(_, Vertex1, Vertex2, DepartureTime, ArrivalTime, _, _),
	% Check for next day time differences
	(ArrivalTime > DepartureTime -> EdgeWeight is ArrivalTime - DepartureTime; 
		EdgeWeight is 24 + ArrivalTime - DepartureTime).

% Puts Cost of Trip into EdgeWeight
fetchEdgeData(Vertex1, Vertex2, EdgeWeight, 'Cost') :-
	bus(_, Vertex1, Vertex2, _, _, _, EdgeWeight).

% Returns all parameters with the Edge
fetchEdgeData(Vertex1, Vertex2, BusNumber, Distance, TimeDifference, Cost) :-
	bus(BusNumber, Vertex1, Vertex2, DepartureTime, ArrivalTime, Distance, Cost),
	(ArrivalTime > DepartureTime -> TimeDifference is ArrivalTime - DepartureTime ; 
		TimeDifference is 24 + ArrivalTime - DepartureTime).

% BASE CASE -> If current vertex is same as X, return the remaining list
removeFromList([X|T], X, T).

% Removes a vertex X from given list and returns the remaining list
removeFromList([H|T], X, [H|NT]) :- 

	H \= X,
	removeFromList(T, X, NT).


% Bus(Bus Number, Origin, Destination, Departure Time, Arrival Time, Distance, Cost)
% Change input buses here for trying different test cases
bus(1, 'A', 'B', 12, 12.5, 8, 20).
bus(2, 'B', 'C', 13, 13.25, 2, 10).
bus(3, 'C', 'E', 13.5, 15, 20, 50).
bus(4, 'B', 'D', 13.5, 14.5, 20, 40).
bus(5, 'D', 'F', 15, 16, 10, 50).
bus(6, 'E', 'F', 16, 16.25, 5, 10).
bus(7, 'F', 'A', 21, 23, 30, 100).