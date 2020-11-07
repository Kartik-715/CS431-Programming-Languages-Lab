package evalsystem;

import java.io.*;
import java.util.*;
import java.util.concurrent.locks.ReentrantLock;

class Constants
{
    public final static String IPFILE = "./stud_info.txt" ; 
    public final static String CC = "CC" ; 
    public final static String TA1 = "TA1" ; 
    public final static String TA2 = "TA2" ; 
    public final static String FINAL_FILE = "./out.txt" ;
    public final static String FINAL_FILE_SORTED_ROLL = "./Sorted_Roll.txt" ;
    public final static String FINAL_FILE_SORTED_NAME = "./Sorted_Name.txt" ; 
}

class EvaluationSystem 
{
    private Map<String, ArrayList<String>> data ; //Roll no. -> [name, email, marks, last_updated_by]
    private Map<String, ReentrantLock> locks ; 
    private ArrayList<ArrayList<String>> ipBuffer ;
    private final static Scanner scanner = new Scanner(System.in);  // For reading input

    public EvaluationSystem()
    {
        data = new HashMap<>() ; 
        ipBuffer = new ArrayList<>() ; 
        locks = new HashMap<>() ; 
    }

    public void updateDataOfStudent(String rollNumber, int marksDelta, String updater) throws Exception
    {
        if(!locks.containsKey(rollNumber))
            throw new Exception("This Roll Number doesn't have a lock associated with it.") ; 

        ReentrantLock rLock = locks.get(rollNumber) ; 
        rLock.lock() ;
        try
        {
            if(UpdateMarks(data.get(rollNumber), marksDelta, updater))
            {
                System.out.println(updater + " updated the marks of " + rollNumber + " to " + data.get(rollNumber).get(2)); 
            }
        }
        finally
        {
            rLock.unlock() ; 
        }
    }

    private boolean UpdateMarks(ArrayList<String> arrayList, int marksDelta, String updater) 
    {
        if(arrayList == null)
        {
            System.out.println("Data for this roll doesn't exist");
            return false ; 
        }

        String lastUpdater = arrayList.get(3) ; 
        if(lastUpdater.equals("CC") && !updater.equals("CC"))
        {
            System.out.println(updater + " trying to update marks of a student which has been modified by instructor.");
            return false ; 
        }

        int prevMarks = Integer.parseInt(arrayList.get(2)) ; 
        prevMarks += marksDelta ; 
        arrayList.set(2, Integer.toString(prevMarks)) ; 
        arrayList.set(3, updater) ;
        
        return true ; 
    }

    public void readDataFromFile() throws IOException
    {
        BufferedReader br = new BufferedReader(new FileReader(Constants.IPFILE));
        String line;
        while ((line = br.readLine()) != null) 
        {
            // use comma as separator
            String[] data = line.split(",");
            ArrayList<String> newEntry = new ArrayList<>();
            newEntry.add(data[1]);
            newEntry.add(data[2]);
            newEntry.add(data[3]);
            newEntry.add(data[4]);
            this.data.put(data[0], newEntry);
            this.locks.put(data[0], new ReentrantLock()) ; 
        }
        br.close(); 
    }

    public static void main(String[] args) throws IOException
    {
        EvaluationSystem es = new EvaluationSystem() ; 
        es.readDataFromFile() ;


        while(true)
        {
            int choice ; 
            System.out.println("Choose Option: \n"
                             + "1. Update Marks \n"
                             + "2. Start Execution \n"
                             + "3. Exit") ; 

            choice = scanner.nextInt() ; 

            switch (choice) 
            {
                case 1:
                    es.TakeInput();
                    break;
                case 2:
                    es.StartExecution();
                    break;
                default:
                    return ; 
            }
        }

    }

    private void GenerateFinalFile()
    {
        WriteOutputFile();
        WriteSortedRoll();
        WriteSortedName();
    }

    private void WriteSortedRoll() 
    {
        BufferedWriter writer2 = null ; 

        try 
        {
            writer2 = new BufferedWriter(new FileWriter(Constants.FINAL_FILE_SORTED_ROLL)) ;
        } 
        catch (IOException e) 
        {
            e.printStackTrace() ;
        }

        assert(writer2 != null);

        ArrayList<String> sortedRoll = new ArrayList<>(data.keySet()) ;
        Collections.sort(sortedRoll) ;

        try 
        {
            for(String roll: sortedRoll)
            {
                writer2.append(roll) ; 

                for (String value : data.get(roll)) 
                {
                    writer2.append(',');
                    writer2.append(value);
                }

                writer2.append('\n');
            }

            writer2.flush();
            writer2.close();

        } 
        catch (Exception e) 
        {
            e.printStackTrace() ; 
        }
    }

    private void WriteSortedName() 
    {
        BufferedWriter writer2 = null ; 

        try 
        {
            writer2 = new BufferedWriter(new FileWriter(Constants.FINAL_FILE_SORTED_NAME)) ;
        } 
        catch (IOException e) 
        {
            e.printStackTrace() ;
        }

        assert(writer2 != null);

        final Comparator<ArrayList<String>> NameComparator = new Comparator<ArrayList<String>>(){
            public int compare(ArrayList<String> a1, ArrayList<String> a2){
                String name1 = a1.get(1);
                String name2 = a2.get(1);
                return name1.compareTo(name2);
            }
        };

        ArrayList<ArrayList<String>> sortedName = new ArrayList<>() ;
        for(Map.Entry<String, ArrayList<String>> entry : this.data.entrySet())
        {
            ArrayList<String> newEntry = new ArrayList<>();
            newEntry.add(entry.getKey());
            for(String value : entry.getValue())
            {
                newEntry.add(value);
            }

            sortedName.add(newEntry);
        }

        Collections.sort(sortedName, NameComparator) ;

        try 
        {
            for(ArrayList<String> entry: sortedName)
            {
                writer2.append(entry.get(0)) ; 

                for(int i = 1; i < 5; i++)
                {
                    writer2.append(',') ;
                    writer2.append(entry.get(i)) ;
                }

                writer2.append('\n');
            }

            writer2.flush() ;
            writer2.close() ;

        } 
        catch (Exception e) 
        {
            e.printStackTrace() ; 
        }
    }

    private void WriteOutputFile() 
    {
        BufferedWriter writer = null ; 

        try 
        {
            writer = new BufferedWriter(new FileWriter(Constants.FINAL_FILE)) ; 
        } 
        catch (Exception e) 
        {
            e.printStackTrace() ;
        }

        assert(writer != null) ; 

        for (Map.Entry<String, ArrayList<String>> entry : data.entrySet()) 
        {
            try 
            {
                writer.append(entry.getKey());
                for (String value : entry.getValue()) 
                {
                    writer.append(',');
                    writer.append(value);
                }
                writer.append('\n');
            } catch (IOException e) 
            {
                e.printStackTrace();
            }
        }

        // Write Sorted Files now //
        try 
        {
            writer.flush() ;
            writer.close() ;
        } 
        catch (IOException e) 
        {
            e.printStackTrace() ;
        }
    }

    private void StartExecution() 
    {
        Teacher ta1 = new Teacher("TA1", this, Thread.NORM_PRIORITY) ; 
        Teacher ta2 = new Teacher("TA2", this, Thread.NORM_PRIORITY) ; 
        Teacher instructor = new Teacher("CC", this, Thread.MAX_PRIORITY) ; 


        for(ArrayList<String> entry: ipBuffer)
        {
            String teacher = entry.get(0) ; 
            String rollNumber = entry.get(1) ; 
            String marksDelta = entry.get(2) ; 

            switch(teacher)
            {
                case Constants.TA1:
                    ta1.addInput(rollNumber, marksDelta);
                    break ; 
                case Constants.TA2:
                    ta2.addInput(rollNumber, marksDelta); 
                    break ; 
                case Constants.CC: 
                    instructor.addInput(rollNumber, marksDelta) ; 
                    break ;
                default:
                    break ; 
            }
        }

        ipBuffer.clear() ; 

        ta1.start(); 
        ta2.start() ; 
        instructor.start() ; 
        
        try
        {
            instructor.join();
            ta1.join() ; 
            ta2.join() ; 
        }
        catch(Exception e)
        {
            e.printStackTrace() ;
        }

        GenerateFinalFile() ;
    }

    private void TakeInput() 
    {
        String teacher = GetTeacherName() ;
        String rollNum = GetRollNumber() ; 
        String updateMarks = GetMarksUpdate() ;  

        ArrayList<String> ip = new ArrayList<>() ; 
        ip.add(teacher) ; 
        ip.add(rollNum) ; 
        ip.add(updateMarks) ; 

        ipBuffer.add(ip) ; 
    }

    private String GetMarksUpdate() 
    {
        System.out.println("How many marks you want to increase/decrease(Input -ve if you want to decrease)?");
        String s = Integer.toString(scanner.nextInt()) ; 
        return s ; 
    }

    private String GetRollNumber() 
    {
        System.out.println("Enter Roll Number :- ") ;
        String s = scanner.next() ;

        if(data.containsKey(s))
            return s ; 
        
        System.out.println("Invalid Roll Number, Not in the database, Try Again");
        return GetRollNumber() ; 
    }

    private String GetTeacherName() 
    {
        System.out.println("Enter Teacher's Alias: ");
        String s = scanner.next() ; 

        if(s.equals("CC") || s.equals("TA1") || s.equals("TA2"))
            return s ; 

        System.out.println("Invalid Teacher's name, Try Again");
        return GetTeacherName() ; 
    }
}

class Teacher extends Thread
{
    String teacherAlias ; 
    EvaluationSystem evaluationSystem ; 
    private ArrayList<ArrayList<String>> ipBuffer ;

    public Teacher(String alias, EvaluationSystem es, int priority)
    {
        teacherAlias = alias ;
        evaluationSystem = es ; 
        this.setName(alias) ;
        this.setPriority(priority) ;
        ipBuffer = new ArrayList<>() ; 
    }

    void addInput(String RollNumber, String marksUpdate)
    {
        ArrayList<String> ip = new ArrayList<>() ; 
        ip.add(RollNumber) ; 
        ip.add(marksUpdate) ; 
        ipBuffer.add(ip) ; 
    }

    @Override
    public void run()
    {
        while(!ipBuffer.isEmpty())
        {
            ArrayList<String> ip = ipBuffer.get(0) ;
            assert(ip.size() == 2) ; 
            try
            {
                evaluationSystem.updateDataOfStudent(ip.get(0), Integer.parseInt(ip.get(1)), teacherAlias);
                ipBuffer.remove(0) ; 
            }
            catch(Exception e)
            {
                e.printStackTrace() ; 
            }
        }
    }
}