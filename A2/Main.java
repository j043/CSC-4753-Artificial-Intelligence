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
    public static final double LEARNING_RATE = 10.0; 
    public static final int MINI_BATCHES = 2; 
    public static final int TRAINING_SETS = 2;  
    public static final int EPOCHS = 6; 

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

        /*****************/
        
        Matrix[] inputs = {x1, x2, x3, x4}; 
        Matrix[] expectedOutputs = {y1, y2, y3, y4}; 

        // print initial weights and biases  
        System.out.println("Initial weights for intermediate layer: "); 
        w1.print(); 

        System.out.println("Initial weights for final layer: "); 
        w2.print(); 

        System.out.println("Initial biases for intermediate layer: "); 
        b1.print(); 

        System.out.println("Initial biases for final layer: "); 
        b2.print(); 

        for (int i = 1; i <= EPOCHS; i++) {
            System.out.println("-------------------------------");
            System.out.println("Epoch: " + i); 
            System.out.println("-------------------------------"); 

            for (int j = 1; j <= MINI_BATCHES; j++) {
                System.out.println("-------------------------------");
                System.out.println("Mini batch " + j);
                System.out.println("-------------------------------");
                
                // initialize total weight and bias gradients for each mini batch
                Matrix total_weights1 = new Matrix(3, 4); 
                Matrix total_weights2 = new Matrix(2, 3); 

                Matrix total_biases1 = new Matrix(3, 1); 
                Matrix total_biases2 = new Matrix(2, 1); 

                for (int k = 1; k <= TRAINING_SETS; k++) {
                    // starting position OF this batch + position WITHIN this batch
                    int training_index = (j-1)*TRAINING_SETS+(k-1);

                    System.out.println("-------------------------------");
                    System.out.println("Training set: " + (training_index+1)); 
                    System.out.println("-------------------------------");
                    
                    Matrix x = inputs[training_index]; 
                    System.out.println("Inputs: "); 
                    x.print(); 

                    Matrix y = expectedOutputs[training_index]; 
                    System.out.println("Expected Outputs: "); 
                    y.print(); 

                    // do num of layers - 1 forward passes 
                    Matrix intermediate_activations = forwardPass(w1, b1, x);  

                    Matrix final_activations = forwardPass(w2, b2, intermediate_activations); 
                    System.out.println("** Final Activations: **"); 
                    final_activations.print(); 

                    // calculate bias gradients with backprop functions
                    Matrix final_biasGradients = backProp_final(y, final_activations); 
                    System.out.println("Final Bias Gradients: "); 
                    final_biasGradients.print(); 

                    Matrix intermediate_biasGradients = backProp_intermediate(w2, final_biasGradients, intermediate_activations); 

                    // calculate weight gradients 
                    Matrix final_weightGradients = weightGradient(final_biasGradients, intermediate_activations); 
                    System.out.println("Final Weight Gradients: "); 
                    final_weightGradients.print(); 

                    Matrix intermediate_weightGradients = weightGradient(intermediate_biasGradients, x);  


                    // add all four gradients to gradients total 
                    total_weights1 = total_weights1.add(intermediate_weightGradients);  
                    total_weights2 = total_weights2.add(final_weightGradients); 
                    total_biases1 = total_biases1.add(intermediate_biasGradients);
                    total_biases2 = total_biases2.add(final_biasGradients); 
                }

                /* print out batch totals DEBUG
                System.out.println("Total weight gradients for intermediate layer: "); 
                total_weights1.print();

                System.out.println("Total weight gradients for final layer: "); 
                total_weights2.print(); 

                System.out.println("Total bias gradients for intermediate layer: "); 
                total_biases1.print(); 

                System.out.println("Total bias gradients for final layer: "); 
                total_biases2.print();
                */ 

                /* average gradient totals and multiply by the learning rate in one step, 
                   since the average is 1/training_sets 
                */
                double averageScalar = LEARNING_RATE / TRAINING_SETS; 

                total_weights1.scale(averageScalar); 
                total_weights2.scale(averageScalar); 
                total_biases1.scale(averageScalar); 
                total_biases2.scale(averageScalar); 
 
                // subtract amounts from weights and biases to update the network 
                w1 = w1.sub(total_weights1); 
                w2 = w2.sub(total_weights2); 
                b1 = b1.sub(total_biases1); 
                b2 = b2.sub(total_biases2); 

                // print out completed weight and bias updates
                System.out.println("Updated weights for intermediate layer: "); 
                w1.print(); 

                System.out.println("Updated weights for final layer: "); 
                w2.print();

                System.out.println("Updated biases for intermediate layer: "); 
                b1.print();

                System.out.println("Updated biases for final layer: "); 
                b2.print(); 
            }
        }
    }

    public static Matrix backProp_final(Matrix expectedOutputs, Matrix activations) {
        Matrix one_minus_activations = new Matrix(activations.rows, activations.columns); 

        for (int i = 0; i < activations.rows; i++) {
            for (int j = 0; j < activations.columns; j++) {
                one_minus_activations.insert(i, j, 1 - activations.data[i][j]); 
            }
        }
        /*  I need the Hadamard product here because (activations - expectedOutputs) is the same size as 
            the activations matrix, but they are not guaranteed to be squares. Further explanation in Matrix.java! 
        */
        return activations.sub(expectedOutputs).hadamard(activations).hadamard(one_minus_activations); 
    }

    public static Matrix backProp_intermediate(Matrix weights_final, Matrix biasGradients_final, Matrix activations) {
        Matrix one_minus_activations = new Matrix(activations.rows, activations.columns); 

        for (int i = 0; i < activations.rows; i++) {
            for (int j = 0; j < activations.columns; j++) {
                one_minus_activations.insert(i, j, 1 - activations.data[i][j]); 
            }
        }
        /*  I need the transpose here because the weights from the final later and the biasGradient of the final layer
            are the exact same dimension, but I need to perform a dot product on them instead of element-wise multiplication 
            like the Hadamard would give us. So we transpose the weights so that they can be multiplied normally! :) 
        */ 
        return weights_final.transpose().multiply(biasGradients_final).hadamard(activations).hadamard(one_minus_activations); 
    }

    public static Matrix weightGradient(Matrix biasGradients, Matrix previous_activations) {
        /*  The original function for weightGradient is previous_activations * biasGradients. However, looking at the Excel spreadsheet
            I realized that the dot product cannot be performed on these two matrices since previous_activations is n by 1, and 
            biasGradients is n-1 by z, and the resulting matrix is n-1 by n. So, we need to transpose previous_activations and flip
            the order of the multiplication in order to achieve n-1 by n! 
        */ 
        return biasGradients.multiply(previous_activations.transpose());
    }

    public static double sigmoid(double z) {
        return (1 / (1 + Math.pow(Math.E, -z)));
    }

    public static Matrix forwardPass(Matrix weights, Matrix biases, Matrix activations) {
        Matrix fp = weights.multiply(activations).add(biases); 

        // perform the sigmoid function on every element in the forward pass matrix
        for (int i = 0; i < fp.rows; i++) {
            for (int j = 0; j < fp.columns; j++) {
                fp.insert(i, j, sigmoid(fp.data[i][j])); 
            }
        }
        return fp; 
    }

}