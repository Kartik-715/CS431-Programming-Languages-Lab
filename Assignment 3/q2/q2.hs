import Data.List
import Data.Maybe
import System.Directory
import System.IO.Unsafe
import Data.IORef
import System.Random

-- Prints all fixtures of teams
fixture "all" = do
    g <- newStdGen
    let newSeed = fst(randomR (1, 100000) g)
    let permutationOfTeams = permutations ["BS","CM","CH","CV","CS","DS","EE","HU","MA","ME","PH","ST"]!!newSeed
    let leftHalf = take totalMatches permutationOfTeams
    let rightHalf = drop totalMatches permutationOfTeams
    let fixtures = zip leftHalf rightHalf

    writeg permutationOfTeams
    helperForFixtures 0 fixtures

fixture team = do
    permutationOfTeams <- readg
    let leftHalf = take totalMatches permutationOfTeams
    let rightHalf = drop totalMatches permutationOfTeams
    let fixtures = zip leftHalf rightHalf

    if null permutationOfTeams then
        putStrLn "Fixtures have not been initialized yet."
    else
        case elemIndex team permutationOfTeams of
            Just id -> if id < totalMatches then printFixtureDetails id fixtures else printFixtureDetails (id-totalMatches) fixtures
            Nothing -> putStrLn "Input Team doesn't exist"

-- Prints the nth fixture
printFixtureDetails n fixtures = putStrLn ((fst(fixtures!!n))++" vs "++(snd(fixtures!!n))++"     "++(fst (times!!n))++"     "++(snd(times!!n)))

helperForFixtures i fixtures = if i == totalMatches then return() else do
    printFixtureDetails i fixtures
    helperForFixtures (i+1) fixtures

-- Prints next match details given date and time
nextMatch day time = do
    permutationOfTeams <- readg
    let leftHalf = take totalMatches permutationOfTeams
    let rightHalf = drop totalMatches permutationOfTeams
    let fixtures = zip leftHalf rightHalf

    if null permutationOfTeams then
        putStrLn "Fixtures have not been initialized yet."
    else if day < 1 || day > 31 then
        putStrLn "Day inputted isn't valid"
    else if time < 0 || time > 23.99 then
        putStrLn "Time isn't valid"
    else
        case day of
            1 -> if time <= 9.5 then printFixtureDetails 0 fixtures else if time <= 19.5 then printFixtureDetails 1 fixtures else printFixtureDetails 2 fixtures
            2 -> if time <= 9.5 then printFixtureDetails 2 fixtures else if time <= 19.5 then printFixtureDetails 3 fixtures else printFixtureDetails 4 fixtures
            3 -> if time <= 9.5 then printFixtureDetails 4 fixtures else if time <= 19.5 then printFixtureDetails 5 fixtures else putStrLn("No match ahead!")
            otherwise -> putStrLn("No match in future")


times = [("1-12-2020","9:30AM"),("1-12-2020","7:30PM"),("2-12-2020","9:30AM"),("2-12-2020","7:30PM"),("3-12-2020","9:30AM"),("3-12-2020","7:30PM")]
totalMatches = length times
numberOfTeams = totalMatches*2

listg :: IORef [[Char]]
listg = unsafePerformIO (newIORef [])

readg :: IO [[Char]]
readg = readIORef listg

writeg :: [[Char]] -> IO ()
writeg value = writeIORef listg value
