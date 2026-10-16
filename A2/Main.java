/* 
    Name: Jennifer Wright
    CWID: 10396439
    Date: 10/12/2026
    Assignment: 2, part 1 
    Description: 
        This is a neural network program that uses Stochastic Gradient Descent and backpropagation to learn 
        on a provided training set. The initial weights, biases, number of mini batches, and learning rate are given. 
*/ 

public class Main {
    // constants 
    public double LEARNING_RATE = 10.0; 
    public int MINI_BATCHES = 2; 
    public int EPOCHS = 6; 

    public static void main(String[] args){
        // initialize weights and biases 
        Matrix w1 = new Matrix(3, 4);
        Matrix w2 = new Matrix(2, 3);

        Matrix b1 = new Matrix(3, 1);
        Matrix b2 = new Matrix(2, 1);

        // fill weights
        w1.insert(0, 0, -0.21);
        w1.insert(0, 1, 0.72);
        w1.insert(0, 2, -0.25);
        w1.insert(0, 3, 1);

        w1.insert(1, 0, -0.94);
        w1.insert(1, 1, -0.41);
        w1.insert(1, 2, -0.47);
        w1.insert(1, 3, 0.63);

        w1.insert(2, 0, 0.15);
        w1.insert(2, 1, 0.55);
        w1.insert(2, 2, -0.49);
        w1.insert(2, 3, -0.75);


        w2.insert(0, 0, 0.76);
        w2.insert(0, 1, 0.48);
        w2.insert(0, 2, -0.73);

        w2.insert(1, 0, 0.34);
        w2.insert(1, 1, 0.89);
        w2.insert(1, 2, -0.23);

        // fill biases 
        b1.insert(0, 0, 0.1);
        b1.insert(1, 0, -0.36);
        b1.insert(2, 0, -0.31);

        b2.insert(0, 0, 0.16);
        b2.insert(1, 0, -0.46);

        // initialize inputs, two for each minibatch
        Matrix x1 = new Matrix(4, 1);
        Matrix x2 = new Matrix(4, 1);
        Matrix x3 = new Matrix(4, 1);
        Matrix x4 = new Matrix(4, 1);

        // initialize expected outputs 
        Matrix y1 = new Matrix(2, 1);
        Matrix y2 = new Matrix(2, 1);
        Matrix y3 = new Matrix(2, 1);
        Matrix y4 = new Matrix(2, 1);

        // fill inputs 
        x1.insert(0, 0, 0); 
        x1.insert(1, 0, 1);
        x1.insert(2, 0, 0);
        x1.insert(3, 0, 1);

        x2.insert(0, 0, 1); 
        x2.insert(1, 0, 0);
        x2.insert(2, 0, 1);
        x2.insert(3, 0, 0);

        x3.insert(0, 0, 0); 
        x3.insert(1, 0, 0);
        x3.insert(2, 0, 1);
        x3.insert(3, 0, 1);

        x4.insert(0, 0, 1); 
        x4.insert(1, 0, 1);
        x4.insert(2, 0, 0);
        x4.insert(3, 0, 0);

        // fill expected outputs
        y1.insert(0, 0, 0); 
        y1.insert(1, 0, 1);

        y2.insert(0, 0, 1); 
        y2.insert(1, 0, 0);

        y3.insert(0, 0, 0); 
        y3.insert(1, 0, 1);

        y4.insert(0, 0, 1); 
        y4.insert(1, 0, 0);
    }
}