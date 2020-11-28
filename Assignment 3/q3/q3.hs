possibleDimensionsOfbathroom = findPossibleDimensions (4,5) (8,9)
possibleDimensionsOfbalcony = findPossibleDimensions (5,5) (10,10)
possibleDimensionsOfgarden = findPossibleDimensions (10,10) (20,20)
possibleDimensionsOfbedroom = findPossibleDimensions (10,10) (15,15)
possibleDimensionsOfhall = findPossibleDimensions (15,10) (20,15)
possibleDimensionsOfkitchen = findPossibleDimensions (7,5) (15,13)
numberOfGarden = 1
numberOfBalconies = 1

zipLists1 as bs = [(a, b) | a <- as, b <- bs]

zipLists2 as cs = [(a, b, c) | (a,b) <- as, c <- cs]

zipLists3 as ds = [(a, b, c, d) | (a,b,c) <- as, d <- ds]

zipLists4 as es = [(a, b, c, d, e) | (a,b,c,d) <- as, e <- es]

zipLists5 as fs = [(a, b, c, d, e, f) | (a,b,c,d,e) <- as, f <- fs]


----------- Call this function, this outputs the final design -----------------------
design :: Integer -> Integer -> Integer -> IO()
design area numberOfBedrooms numberOfHalls = do
    
    let numberOfBathrooms = numberOfBedrooms + 1
    let numberOfKitchens = ceiling(fromIntegral numberOfBedrooms/3)::Integer

    -- Obtain (Bedroom x Hall)
    let firstComb = zipLists1 possibleDimensionsOfbedroom possibleDimensionsOfhall
    let new_firstComb = filter (\(x,y) -> fst(x)*snd(x)*numberOfBedrooms+fst(y)*snd(y)*numberOfHalls <= area) firstComb

    -- Combine previous and kitchen dimensions to form combination tuple: (bedroom, hall, kitchen)
    let secondComb = zipLists2 new_firstComb possibleDimensionsOfkitchen
    let filter_secondComb = filter (\(x,y,z) -> fst(x)*snd(x)*numberOfBedrooms+fst(y)*snd(y)*numberOfHalls+fst(z)*snd(z)*numberOfKitchens <= area) secondComb
    let new_secondComb = filter (\(x,y,z) -> fst(z) <= fst(x) && fst(z) <= fst(y) && snd(z) <= snd(x) && snd(z) <= snd(y)) filter_secondComb

    -- Combine previous and bathroom dimensions to form combination tuple: (bedroom, hall, kitchen, bathroom)
    let thirdComb = zipLists3 new_secondComb possibleDimensionsOfbathroom
    let filter_thirdComb = filter (\(x,y,z,p) -> fst(x)*snd(x)*numberOfBedrooms+fst(y)*snd(y)*numberOfHalls+fst(z)*snd(z)*numberOfKitchens+fst(p)*snd(p)*numberOfBathrooms <= area) thirdComb
    -- dimension of a bathroom must not be larger than that of a kitchen
    let filter2_thirdComb = filter (\(_,_,z,p) -> fst(p) <= fst(z) && snd(p) <= snd(z)) filter_thirdComb
    let new_thirdComb = removeRedundant3 filter2_thirdComb [] numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms

    let fourthComb = zipLists4 new_thirdComb possibleDimensionsOfgarden
    let filter_fourthComb = filter (\(x,y,z,p,q) -> fst(x)*snd(x)*numberOfBedrooms+fst(y)*snd(y)*numberOfHalls+fst(z)*snd(z)*numberOfKitchens+fst(p)*snd(p)*numberOfBathrooms+fst(q)*snd(q)*numberOfGarden <= area) fourthComb
    let new_fourthComb = removeRedundant4 filter_fourthComb [] numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms numberOfGarden
    
    let finalComb = zipLists5 new_fourthComb possibleDimensionsOfbalcony
    let filter_finalComb = filter (\(x,y,z,p,q,r) -> fst(x)*snd(x)*numberOfBedrooms+fst(y)*snd(y)*numberOfHalls+fst(z)*snd(z)*numberOfKitchens+fst(p)*snd(p)*numberOfBathrooms+fst(q)*snd(q)*numberOfGarden+fst(r)*snd(r)*numberOfBalconies <= area) finalComb
    let new_finalComb = removeRedundant5 filter_finalComb [] numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms numberOfGarden numberOfBalconies
    
    -- Find the tuple with maximum area
    let answer = maximumArea new_finalComb numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms numberOfGarden numberOfBalconies
    
    -- Filter the combos with maximum area
    let output = filter (\(x,y,z,p,q,r) -> fst(x)*snd(x)*numberOfBedrooms+fst(y)*snd(y)*numberOfHalls+fst(z)*snd(z)*numberOfKitchens+fst(p)*snd(p)*numberOfBathrooms+fst(q)*snd(q)*numberOfGarden+fst(r)*snd(r)*numberOfBalconies == answer) new_finalComb
    
    if null output then do
        putStrLn "Design is not possible for the given constraints"
    else do
        let (x,y,z,p,q,r) = output!!0 -- Take the first possible combo
        putStrLn("Bedroom: " ++ show(numberOfBedrooms) ++ " (" ++ show(fst(x)) ++ " X " ++ show(snd(x)) ++ ")")
        putStrLn("Hall: " ++ show(numberOfHalls) ++ " (" ++ show(fst(y)) ++ " X " ++ show(snd(y)) ++ ")")
        putStrLn("Kitchen: " ++ show(numberOfKitchens) ++ " (" ++ show(fst(z)) ++ " X " ++ show(snd(z)) ++ ")")
        putStrLn("Bathroom: " ++ show(numberOfBathrooms) ++ " (" ++ show(fst(p)) ++ " X " ++ show(snd(p)) ++ ")")
        putStrLn("Garden: " ++ show(numberOfGarden) ++ " (" ++ show(fst(q)) ++ " X " ++ show(snd(q)) ++ ")")
        putStrLn("Balcony: " ++ show(numberOfBalconies) ++ " (" ++ show(fst(r)) ++ " X " ++ show(snd(r)) ++ ")")
        putStrLn("Unused Space: " ++ show(area-answer))

-- Helper to findPossibleDimensions
findPossibleDimensionsHelper from to =
    if snd from == snd to then
        [from]
    else
        from : findPossibleDimensionsHelper new_from to
    where new_from = (fst from, snd from + 1)

-- Finds all possible dimensions given smallest dimension (a1, b1) and largest dimension (a2, b2)
findPossibleDimensions from to =
    if fst from == fst to then
        findPossibleDimensionsHelper from to
    else
        findPossibleDimensionsHelper from to ++ findPossibleDimensions new_from to
    where
        new_from = (fst from + 1, snd from)

-- Base case for maximumArea: Return 0 if input list is empty
maximumArea [] _ _ _ _ _ _ = 0
-- Returns maximum total area from the list of combinations
maximumArea ((x,y,z,p,q,r):new_finalComb) numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms numberOfGarden numberOfBalconies =
    maximum [fst(x)*snd(x)*numberOfBedrooms+fst(y)*snd(y)*numberOfHalls+fst(z)*snd(z)*numberOfKitchens
        +fst(p)*snd(p)*numberOfBathrooms+fst(q)*snd(q)*numberOfGarden+fst(r)*snd(r)*numberOfBalconies,
        maximumArea new_finalComb numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms numberOfGarden
        numberOfBalconies]


-- Base case for removeRedundant3: Return empty list if input list is empty
removeRedundant3 [] _ _ _ _ _ = []
-- Removes the combinations having the same total area
removeRedundant3 ((x,y,z,p):thirdComb) unique numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms =
    if elem (fst(x)*snd(x)*numberOfBedrooms+fst(y)*snd(y)*numberOfHalls+fst(z)*snd(z)*numberOfKitchens
        +fst(p)*snd(p)*numberOfBathrooms) unique then
        
        removeRedundant3 thirdComb unique numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms
    else
        (x,y,z,p) : removeRedundant3 thirdComb (fst(x)*snd(x)*numberOfBedrooms+fst(y)*snd(y)*numberOfHalls
            +fst(z)*snd(z)*numberOfKitchens+fst(p)*snd(p)*numberOfBathrooms:unique) numberOfBedrooms
            numberOfHalls numberOfKitchens numberOfBathrooms

removeRedundant4 [] _ _ _ _ _ _ = []
-- Removes removeRedundant combinations with same total area
removeRedundant4 ((x,y,z,p,q):fourthComb) unique numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms numberOfGarden =
    if elem (fst(x)*snd(x)*numberOfBedrooms+fst(y)*snd(y)*numberOfHalls+fst(z)*snd(z)*numberOfKitchens
        +fst(p)*snd(p)*numberOfBathrooms+fst(q)*snd(q)*numberOfGarden) unique then
        
        removeRedundant4 fourthComb unique numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms numberOfGarden
    else
        (x,y,z,p,q) : removeRedundant4 fourthComb (fst(x)*snd(x)*numberOfBedrooms+fst(y)*snd(y)*numberOfHalls
            +fst(z)*snd(z)*numberOfKitchens+fst(p)*snd(p)*numberOfBathrooms+fst(q)*snd(q)*numberOfGarden
            :unique) numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms numberOfGarden

-- Base case for removeRedundant5: Return empty list if input list is empty
removeRedundant5 [] _ _ _ _ _ _ _ = []
-- Removes removeRedundant combinations with same total area
removeRedundant5 ((x,y,z,p,q,r):finalComb) unique numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms numberOfGarden numberOfBalconies =
    if elem (fst(x)*snd(x)*numberOfBedrooms+fst(y)*snd(y)*numberOfHalls+fst(z)*snd(z)*numberOfKitchens
        +fst(p)*snd(p)*numberOfBathrooms+fst(q)*snd(q)*numberOfGarden+fst(r)*snd(r)*numberOfBalconies)
        unique then
        
        removeRedundant5 finalComb unique numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms numberOfGarden
            numberOfBalconies
    else
        (x,y,z,p,q,r) : removeRedundant5 finalComb (fst(x)*snd(x)*numberOfBedrooms+fst(y)*snd(y)*numberOfHalls
            +fst(z)*snd(z)*numberOfKitchens+fst(p)*snd(p)*numberOfBathrooms+fst(q)*snd(q)*numberOfGarden
            +fst(r)*snd(r)*numberOfBalconies:unique) numberOfBedrooms numberOfHalls numberOfKitchens numberOfBathrooms
            numberOfGarden numberOfBalconies