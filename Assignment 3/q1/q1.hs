import Data.List

isEmpty list = null list

add [] _ = []
add _ [] = []
add (x:list1) (y:list2) = unionSet [x+y] (unionSet (add (x:list1) list2) (add list1 (y:list2))) 

unionSet list1 list2 = removeDuplicates (list1 ++ list2)

removeDuplicates [] = []
removeDuplicates (x:list) = if elem x list then
        removeDuplicates list
    else
        x : removeDuplicates list

intersection [] _ = []
intersection (x:list1) list2 = if elem x list2 then
        unionSet [x] (intersection list1 list2)
    else
        intersection list1 list2

subtraction [] _ = []
subtraction (x:list1) list2 = if elem x list2 then
        subtraction list1 list2
    else
        unionSet [x] (subtraction list1 list2)