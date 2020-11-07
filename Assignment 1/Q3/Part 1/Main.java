package q3a; 

import java.awt.Color;
import java.util.ArrayList;
import java.util.List;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;

import javax.swing.*;
import java.util.Stack;

public class Main extends JFrame implements KeyListener
{
    public DisplayArea dA ; 
    public NumberArea nA ;
    public FunctionArea fA ; 

    // Indexes of the current number and functions to be highlighted
    public int currNumber ; 
    public int currFuncSelected ; 
    private int numEnterPressed ; 

    public void keyPressed(KeyEvent e) 
    {
        if(e.getKeyCode() == KeyEvent.VK_ENTER)
        {    
            if(numEnterPressed == 0 || numEnterPressed == 2)
            {   
                char c = (char) (currNumber + '0') ; 
                System.out.println("Added " + c + " to the buffer"); 
                dA.addToBuffer(c) ;
            }
            else if(numEnterPressed == 1)
            {
                // Pressed space
                char c = fA.fKeys.get(currFuncSelected).getText().charAt(0) ; 
                System.out.println("Added " + c + " to the buffer");
                dA.addToBuffer(c) ;
            }

            numEnterPressed++ ;
            if(numEnterPressed == 3)
            {
                computeResult() ;
                numEnterPressed = 1 ; 
            }
        }
        else if(e.getKeyCode() == KeyEvent.VK_SPACE)
        {
            
        }
        else if(e.getKeyCode() == KeyEvent.VK_R)
        {
            // Pressed R
            // computeResult() ;
        }
        else if(e.getKeyCode() == KeyEvent.VK_C)
        {
            // Pressed C
            dA.clearBuffer() ;
        }

        this.repaint() ;
    }
    
    public void keyReleased(KeyEvent e) 
    {
        
    }
    
    public void keyTyped(KeyEvent e) 
    {
        
    }

    public void incrementHighlight()
    {
        nA.highlight(currNumber, false);
        fA.highlight(currFuncSelected, false);

        if((numEnterPressed % 2) == 0)
        {
            currNumber++ ; 
            currNumber %= 10 ; 
            nA.highlight(currNumber, true);
        }
        
        if((numEnterPressed % 2) == 1)
        {
            currFuncSelected++ ; 
            currFuncSelected %= 4 ; 
            fA.highlight(currFuncSelected, true);
        }
        
    }

    private void computeResult()
    {
        SwingWorker sw = new SwingWorker()
        {
            @Override
            protected String doInBackground()  
            { 
                String expression = dA.getBuffer() ;

                try
                {
                    int x = evaluateExpression(expression) ;
                    dA.setAnswer(Integer.toString(x)) ;
                }
                catch(Exception e)
                {
                    dA.setAnswer("Invalid Syntax") ;
                    e.printStackTrace() ;
                }
                  
                dA.result.repaint();

                return "Finished Execution" ; 
            }
        } ; 

        sw.execute() ; 
    }

    private int evaluateExpression(String s) throws Exception
    {       
        return EvaluateString.evaluate(s) ; 
    }

    public Main()
    {
        super("Calculator");
        this.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        this.getContentPane().setLayout(null);
        this.setBounds(100, 100, 180, 140);
        addKeyListener(this);

        currNumber = -1 ; 
        currFuncSelected = -1 ; 

        dA = new DisplayArea() ; 
        nA = new NumberArea() ;
        fA = new FunctionArea() ; 
        
        this.add(dA.result) ; 

        for(JLabel j: nA.nums)
        {
            this.add(j) ; 
        }

        for(JLabel j: fA.fKeys)
        {
            this.add(j) ; 
        }

        this.setSize(220, 300) ;
        this.setVisible(true) ;
    }

    public static void main(String[] args)
    {
        Main frame = new Main() ; 
        SwingWorker sw = new SwingWorker()
        {
            @Override
            protected String doInBackground()
            {
                while(true)
                {
                    try
                    {
                        frame.incrementHighlight() ;
                        frame.repaint() ; 
                        Thread.sleep(1000) ; 
                    }
                    catch(Exception e)
                    {
                        e.printStackTrace() ; 
                        break ; 
                    }
                }
                return "Finished Execution" ; 
            }
        } ; 

        sw.execute() ;
    }
}

class DisplayArea
{
    JLabel result ; 

    public DisplayArea()
    {
        result = new JLabel("") ;
        result.setHorizontalAlignment(SwingConstants.CENTER);
        result.setVerticalAlignment(SwingConstants.CENTER);
        result.setSize(200, 20); ; 
        result.setLocation(10, 5);
    }

    public void addToBuffer(char c)
    {
        String x = result.getText() ;
        
        if(c >= '0' && c <= '9')
        {
            x += c ; 
        }
        else
        {
            x += (" " + c + " ") ; 
        } 
        result.setText(x);
    }

    public void clearBuffer()
    {
        result.setText("") ;
        result.repaint() ;
    }

    public void setAnswer(String x)
    {
        result.setText(x);
    }

    public String getBuffer()
    {
        return result.getText() ; 
    }

}

class NumberArea
{
    public List<JLabel> nums ; 

    private int XPosition(int num)
    {
        if(num == 9)
            return 100 ; 

        return 50 + 50 * (num % 3) ; 
    }

    private int YPosition(int num)
    {
        return 50 + 50 * (num / 3) ; 
    }

    public NumberArea()
    {
        nums = new ArrayList<JLabel>() ;
        for(int i = 0 ; i < 10  ; i++)
        {
            JLabel l = new JLabel(Integer.toString(i)) ; 
            l.setBackground(Color.YELLOW);
            l.setSize(l.getPreferredSize()) ; 
            l.setLocation(XPosition(i), YPosition(i));
            nums.add(l) ; 
        }
    }

    public void highlight(int num, boolean highlight)
    {
        if(num < 0 || num > 9)
            return ; 

        nums.get(num).setOpaque(highlight); 
    }

}

class FunctionArea
{
    public List<JLabel> fKeys ; 

    public FunctionArea()
    {
        fKeys = new ArrayList<JLabel>() ; 
        String keys[] = {"+","-","/","*"} ; 

        for(int i = 0 ; i < 4 ; i++)
        {
            JLabel l = new JLabel(keys[i]) ;
            l.setSize(l.getPreferredSize()) ;
            l.setBackground(Color.YELLOW); 
            l.setLocation(50 * i + 30, 250);
            fKeys.add(l) ; 
        }
    }

    public void highlight(int idx, boolean highlight)
    {
        if(idx < 0 || idx > 3)
            return ; 

        fKeys.get(idx).setOpaque(highlight); 
    }
}

class EvaluateString 
{ 
    public static int evaluate(String expression) 
    { 
        char[] tokens = expression.toCharArray(); 
  
         // Stack for numbers: 'values' 
        Stack<Integer> values = new Stack<Integer>(); 
  
        // Stack for Operators: 'ops' 
        Stack<Character> ops = new Stack<Character>(); 
        boolean isNeg = false;

        for (int i = 0; i < tokens.length; i++) 
        { 
             // Current token is a whitespace, skip it 
            if (tokens[i] == ' ') 
            {
                isNeg = false ; 
                continue; 
            }
  
            // Current token is a number, push it to stack for numbers 
            if(tokens[i] == '-' && i+1 < tokens.length && (tokens[i+1] >= '0' && tokens[i+1] <= '9'))
            {
                isNeg = true;
            }
            else if (tokens[i] >= '0' && tokens[i] <= '9') 
            { 
                StringBuffer sbuf = new StringBuffer(); 
                // There may be more than one digits in number 
                while (i < tokens.length && tokens[i] >= '0' && tokens[i] <= '9') 
                    sbuf.append(tokens[i++]); 

                int toPush = Integer.parseInt(sbuf.toString()) ; 
                toPush = (isNeg ? -toPush : toPush) ; 
                values.push(toPush); 
                 
            } 
            // Current token is an opening brace, push it to 'ops' 
            else if (tokens[i] == '(') 
                ops.push(tokens[i]); 
  
            // Closing brace encountered, solve entire brace 
            else if (tokens[i] == ')') 
            { 
                while (ops.peek() != '(') 
                  values.push(applyOp(ops.pop(), values.pop(), values.pop())); 
                ops.pop(); 
            } 
  
            // Current token is an operator. 
            else if (tokens[i] == '+' || tokens[i] == '-' || 
                     tokens[i] == '*' || tokens[i] == '/') 
            { 
                // While top of 'ops' has same or greater precedence to current 
                // token, which is an operator. Apply operator on top of 'ops' 
                // to top two elements in values stack 
                while (!ops.empty() && hasPrecedence(tokens[i], ops.peek())) 
                  values.push(applyOp(ops.pop(), values.pop(), values.pop())); 
  
                // Push current token to 'ops'. 
                ops.push(tokens[i]); 
            } 
        } 
  
        // Entire expression has been parsed at this point, apply remaining 
        // ops to remaining values 
        while (!ops.empty()) 
            values.push(applyOp(ops.pop(), values.pop(), values.pop())); 
  
        // Top of 'values' contains result, return it 
        return values.pop(); 
    } 
  
    // Returns true if 'op2' has higher or same precedence as 'op1', 
    // otherwise returns false. 
    public static boolean hasPrecedence(char op1, char op2) 
    { 
        if (op2 == '(' || op2 == ')') 
            return false; 
        if ((op1 == '*' || op1 == '/') && (op2 == '+' || op2 == '-')) 
            return false; 
        else
            return true; 
    } 
  
    // A utility method to apply an operator 'op' on operands 'a'  
    // and 'b'. Return the result. 
    public static int applyOp(char op, int b, int a) 
    { 
        switch (op) 
        { 
        case '+': 
            return a + b; 
        case '-': 
            return a - b; 
        case '*': 
            return a * b; 
        case '/': 
            if (b == 0) 
                throw new
                UnsupportedOperationException("Cannot divide by zero"); 
            return a / b; 
        } 
        return 0; 
    } 
}