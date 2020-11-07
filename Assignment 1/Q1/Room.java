package sockssort;

import java.util.*;

class Room
{
    public static int numPairs ;
    public static int numArms ;  

    public static void main(String[] args) 
    {
        if(args.length != 2)
        {
            // Usage Error //
            System.out.println("Usage: java Room {Number of Sock Pairs} {Number of Robot Arms}");
            return ; 
        }
        
        numPairs = Integer.parseInt(args[0]) ;  
        numArms = Integer.parseInt(args[1]) ;  
        
        String colors[] = {"Green", "Blue", "Black", "White"} ; 
        List<Sock> socks = new ArrayList<Sock>() ; 
        Random r = new Random() ; 

        // Generate sock pairs //
        for(int i = 0 ; i < numPairs ; i++)
        {
            String color = colors[r.nextInt(4)] ; 
            Sock s1 = new Sock(color, 2*i) ;
            Sock s2 = new Sock(color, 2*i + 1) ; 
            socks.add(s1) ; 
            socks.add(s2) ;  
        }

        // Shuffle all the socks //
        java.util.Collections.shuffle(socks);

        Heap h = new Heap(socks) ;
        MatchMakingMachine machine = new MatchMakingMachine() ; 

        for(int i = 0 ; i < numArms ; i++)
        {
            RoboticArm rArm = new RoboticArm(i+1, h, machine) ;
            rArm.start() ;  
        }

        machine.start() ; 
    }
}

class RoboticArm extends Thread
{
    int idx ;
    Heap heap ;
    MatchMakingMachine matchMakingMachine ;   

    public RoboticArm(int num, Heap h, MatchMakingMachine m)
    {
        idx = num ; 
        heap = h ; 
        matchMakingMachine = m ; 
    }

    @Override
    public void run()
    {
        
        while(heap.remainingSocks() > 0)
        {
            try
            {
                Sock s = heap.selectASock() ; 
                if(s == null) continue ; 

                System.out.println("Sock #" + s.idx + " of color " + s.color + " picked up by Arm #" + idx) ;
                // Once I have a sock pass it to matchmaking machine //
                matchMakingMachine.addSock(s);

            }
            catch(Exception e)
            {
                e.printStackTrace() ;
            }
            finally
            {

            }
        }
    }
}

class Heap
{
    List<Sock> socks ;
    private int remainingSocks ;

    public Heap(List<Sock> s)
    {
        socks = s ; 
        remainingSocks = s.size() ; 
    }

    // Returns a sock object if picking up was successful //
    public Sock selectASock()
    {
        Random r = new Random() ; 
        int n = socks.size() ;
        int idxToSelect = r.nextInt(n) ;
        
        Sock s = socks.get(idxToSelect) ;
        boolean success = s.pickUp() ; 
        
        if(success)
        {
            synchronized(this)
            {
                remainingSocks-- ; 
            }
            return s ; 
        }

        return null ; 
    }
    
    public int remainingSocks()
    {
        return remainingSocks ; 
    }
}

class MatchMakingMachine extends Thread
{
    private int matchedPairs = 0 ; 

    // Stores the current 
    private Map<String, Integer> queue ; 

    public MatchMakingMachine()
    {
        queue = new HashMap<String,Integer>() ; 
        matchedPairs = 0 ; 
    }

    @Override
    public void run()
    {
        while(matchedPairs < Room.numPairs)
        {
            synchronized(this)
            {
                for(String color: queue.keySet())
                {
                    int numSocks = queue.get(color) ; 
                    while(numSocks > 1)
                    {
                        numSocks -= 2 ; 
                        System.out.println("Matcher matched socks of " + color + " color") ;
                        matchedPairs++ ; 
                    }

                    queue.put(color, numSocks) ; 
                }
            }
        }

        System.out.println("Total Matched Sock Pairs: " + matchedPairs);
    }
    
    public synchronized void addSock(Sock s)
    {
        int currCount = queue.getOrDefault(s.color, 0) ;  
        currCount++ ; 
        queue.put(s.color, currCount) ;
    }
}

class Sock
{
    Integer idx ; 
    String color ; 
    private boolean pickedUp ;

    public Sock(String c, Integer i)
    {
        color = c ; 
        idx = i ; 
        pickedUp = false ; 
    }

    public synchronized boolean pickUp()
    {
        if(pickedUp)
            return false ; 

        return (pickedUp = true) ; 
    }

    public boolean pickedUp()
    {
        return pickedUp ; 
    }
}