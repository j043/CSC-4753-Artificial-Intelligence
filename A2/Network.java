/* 
    AUTHOR'S NOTES: 

    This Network class contains the majority of the logic that previously existsed in 
    my Main class for Part 1, as well as some additional functions.

    - The class contains 7 public fields: weights matrices, bias matrices, input nodes, 
      intermediate layer nodes, and output nodes. 

    - The Network can perform the following functions: backpropagation, forward pass, 
      calculate the weight and bias gradients, calculate the sigmoid function, train, 
      make predictions, evaluate the correctness of the predictions, load a network from
      a file, save the network to a file, display individual digits, and display digits with their 
      classifications. 

    - Jenny :) 
*/ 

import java.io.PrintWriter; 
import java.io.FileNotFoundException;
import java.io.File; 
import java.util.Scanner;  

public class Network {
    // weights and biases  
    public Matrix w1; 
    public Matrix w2; 
    public Matrix b1; 
    public Matrix b2; 

    // number of nodes in each layer 
    public int inputSize; 
    public int intermediateSize; 
    public int outputSize; 

    // ctor
    public Network(int inputSize, int intermediateSize, int outputSize) {
        this.inputSize = inputSize; 
        this.intermediateSize = intermediateSize; 
        this.outputSize = outputSize; 

        this.w1 = new Matrix(intermediateSize, inputSize); 
        this.w2 = new Matrix(outputSize, intermediateSize); 
        this.b1 = new Matrix(intermediateSize, 1); 
        this.b2 = new Matrix(outputSize, 1); 

        // fill weights and biases with random values from -1 to 1
        w1.fillRandom(); 
        w2.fillRandom(); 
        b1.fillRandom(); 
        b2.fillRandom(); 
    }

    // NETWORK MATH FUNCTIONS ///////////////////////////////////////////////////////////////////////////////////

    public Matrix backProp_final(Matrix expectedOutputs, Matrix activations) {
        Matrix one_minus_activations = new Matrix(activations.rows, activations.columns); 

        for (int i = 0; i < activations.rows; i++) {
            for (int j = 0; j < activations.columns; j++) {
                one_minus_activations.insert(i, j, 1 - activations.data[i][j]); 
            }
        }
        /*  I need the Hadamard product here because I need point-wise multiplication instead of the dot product! 
        */
        return activations.sub(expectedOutputs).hadamard(activations).hadamard(one_minus_activations); 
    }

    public Matrix backProp_intermediate(Matrix weights_final, Matrix biasGradients_final, Matrix activations) {
        Matrix one_minus_activations = new Matrix(activations.rows, activations.columns); 

        for (int i = 0; i < activations.rows; i++) {
            for (int j = 0; j < activations.columns; j++) {
                one_minus_activations.insert(i, j, 1 - activations.data[i][j]); 
            }
        }
        /*  I need the transpose here because the final weight matrix is 10 x 30 and the final bias gradient matrix is 
            10 x 1, and we want a 30 x 1 as our result. Transpose allows us to multiply a 30 x 10 to a 10 x 1 to get this
            desired size. The hadamard is then used to multiply each intermediate neuron's bias gradients by its own sigmoid 
            derivative (point-wise multiplication) :) 
        */ 
        return weights_final.transpose().multiply(biasGradients_final).hadamard(activations).hadamard(one_minus_activations); 
    }

    public Matrix weightGradient(Matrix biasGradients, Matrix previous_activations) {
        /*  Each weight gradient is the next neuron's bias gradient multiplied by the previous neuron's activation. 
            I used the transpose here to allow that multiplcation to happen in one "action" so to speak, and to 
            ensure the result has the same dimensions as the weight matrix. 
        */ 
        return biasGradients.multiply(previous_activations.transpose());
    }

    public double sigmoid(double z) {
        return (1 / (1 + Math.pow(Math.E, -z)));
    }

    public Matrix forwardPass(Matrix weights, Matrix biases, Matrix activations) {
        Matrix fp = weights.multiply(activations).add(biases); 

        // perform the sigmoid function on every element in the forward pass matrix
        for (int i = 0; i < fp.rows; i++) {
            for (int j = 0; j < fp.columns; j++) {
                fp.insert(i, j, sigmoid(fp.data[i][j])); 
            }
        }
        return fp; 
    }

    // NETWORK TRAINING AND TESTING FUNCTIONS /////////////////////////////////////////////////////////////////////////////////////////////

    // train the network 
    public void train(Matrix[] inputs, Matrix [] expectedOutputs, int epochs, int batchSize, double learningRate) {
        // calculate number of mini batches (60,000 / 10)
        int numOfBatches = inputs.length / batchSize; 

        for (int i = 1; i <= epochs; i++) {
            // shuffle inputs and expectedOutputs using the Fisher-Yates algorithm
            for (int l = inputs.length - 1; l > 0; l--) {
                // walking backwards through the arrays, select a position from 0 to l and swap them
                // (need to cast this since Math.random() returns a double)
                int randomIndex = (int) (Math.random() * (l + 1)); 
                
                // swap! 
                Matrix tempInput = inputs[l]; 
                inputs[l] = inputs[randomIndex];
                inputs[randomIndex] = tempInput; 

                Matrix tempOutput = expectedOutputs[l];
                expectedOutputs[l] = expectedOutputs[randomIndex];
                expectedOutputs[randomIndex] = tempOutput;
            }

            for (int j = 1; j <= numOfBatches; j++) {
                // initialize total weight and bias gradients for each mini batch
                Matrix total_weights1 = new Matrix(w1.rows, w1.columns); 
                Matrix total_weights2 = new Matrix(w2.rows, w2.columns); 

                Matrix total_biases1 = new Matrix(b1.rows, b1.columns); 
                Matrix total_biases2 = new Matrix(b2.rows, b2.columns); 

                for (int k = 1; k <= batchSize; k++) {
                    // starting position OF this batch + position WITHIN this batch
                    int trainingIndex = (j-1)*batchSize+(k-1); 
                    
                    Matrix x = inputs[trainingIndex]; 
                    Matrix y = expectedOutputs[trainingIndex]; 

                    // do num of layers - 1 forward passes 
                    Matrix intermediate_activations = forwardPass(w1, b1, x);  
                    Matrix final_activations = forwardPass(w2, b2, intermediate_activations); 

                    // calculate bias gradients with backprop functions
                    Matrix final_biasGradients = backProp_final(y, final_activations); 
                    Matrix intermediate_biasGradients = backProp_intermediate(w2, final_biasGradients, intermediate_activations); 

                    // calculate weight gradients 
                    Matrix final_weightGradients = weightGradient(final_biasGradients, intermediate_activations); 
                    Matrix intermediate_weightGradients = weightGradient(intermediate_biasGradients, x);  

                    // add all four gradients to gradients total 
                    total_weights1 = total_weights1.add(intermediate_weightGradients);  
                    total_weights2 = total_weights2.add(final_weightGradients); 
                    total_biases1 = total_biases1.add(intermediate_biasGradients);
                    total_biases2 = total_biases2.add(final_biasGradients); 
                }

                double averageScalar = learningRate / batchSize; 

                total_weights1.scale(averageScalar); 
                total_weights2.scale(averageScalar); 
                total_biases1.scale(averageScalar); 
                total_biases2.scale(averageScalar); 
 
                // subtract amounts from weights and biases to update the network 
                w1 = w1.sub(total_weights1); 
                w2 = w2.sub(total_weights2); 
                b1 = b1.sub(total_biases1); 
                b2 = b2.sub(total_biases2); 
            }
            evaluateCorrectness(inputs, expectedOutputs); 
        }
    }

    // make a prediction of what digit the network sees 
    public int predict(Matrix inputs) {
        // do num of layers - 1 forward passes 
        Matrix intermediate_activations = forwardPass(w1, b1, inputs);  
        Matrix final_activations = forwardPass(w2, b2, intermediate_activations);

        // find the position of the prediction using argmax 
        int predictedIndex = 0; 
        for (int i = 1; i < final_activations.rows; i++) {
            if (final_activations.data[i][0] > final_activations.data[predictedIndex][0]) {
                predictedIndex = i; 
            }
        }
        return predictedIndex; 
    }

    // evaluate and print how well the network did 
    public void evaluateCorrectness(Matrix[] inputs, Matrix[] expectedOutputs) {
        // keep track of correct predictions 
        int[] totalExamples = new int[10]; 
        int[] correctPredictions = new int[10]; 
        int totalCorrect = 0; 

        for (int i = 0; i < inputs.length; i++) {
            int predictedIndex = predict(inputs[i]); 
            int actualIndex = -1; // not yet found 

            // for our current example, find the 1 row 
            for (int j = 0; j < expectedOutputs[i].rows; j++) {
                if (expectedOutputs[i].data[j][0] == 1.0) {
                    actualIndex = j; 
                    break; 
                }
            }
            
            totalExamples[actualIndex] += 1; 

            // if our prediction is correct, incremement correct counter 
            if (predictedIndex == actualIndex) {
                correctPredictions[actualIndex] += 1; 
                totalCorrect += 1; 
            }
        }

        // after we've gone through every example, print results
        for (int i = 0; i < 10; i++) {
            System.out.println(i + " = " + correctPredictions[i] + "/" + totalExamples[i]); 
        }
        double accuracy = 100.0 * totalCorrect / inputs.length; 
        System.out.println("Accuracy = " + totalCorrect + "/" + inputs.length + " = " + accuracy + "%"); 
    }

    // save network to a file 
    public void saveNetwork(String filepath) throws FileNotFoundException {
        // used PrintWriter instead of FileWriter because I wanted to use println() 
        try (PrintWriter writer = new PrintWriter(filepath)) {
            writer.println(inputSize + " " + intermediateSize + " " + outputSize); 
            // print each weight and bias matrix to the chosen file 
            for (int i = 0; i < w1.rows; i++) {
                for (int j = 0; j < w1.columns; j++) {
                    writer.print(w1.data[i][j] + " ");
                }
                writer.println();
            }
            for (int i = 0; i < w2.rows; i++) {
                for (int j = 0; j < w2.columns; j++) {
                    writer.print(w2.data[i][j] + " ");
                }
                writer.println();
            }
            for (int i = 0; i < b1.rows; i++) {
                for (int j = 0; j < b1.columns; j++) {
                    writer.print(b1.data[i][j] + " ");
                }
                writer.println();
            }
            for (int i = 0; i < b2.rows; i++) {
                for (int j = 0; j < b2.columns; j++) {
                    writer.print(b2.data[i][j] + " ");
                }
                writer.println();
            }
        }
    }

    // load weights and biases from a file
    public void loadData(String filepath, Matrix[] inputs, Matrix[] expectedOutputs) throws FileNotFoundException { 
        try (Scanner reader = new Scanner(new File(filepath))) {
            for (int i = 0; i < inputs.length; i++) {
                String[] data = reader.nextLine().split(","); 
                Matrix input = new Matrix(784, 1); 
                // for each row of pixels in the CSV
                for (int p = 0; p < 784; p++) {
                    // parse because each data is a String, and normalize because we need values from 0-1
                    // start at 0 but skip it because field 0 is the label
                    double pixel = Integer.parseInt(data[p+1]) / 255.0; 
                    input.insert(p, 0, pixel); 
                }
                
                // place a 1 at the row corresponding to the label 
                int label = Integer.parseInt(data[0]); 
                Matrix correctOutput = new Matrix(10, 1); 
                correctOutput.insert(label, 0, 1.0); 

                inputs[i] = input; 
                expectedOutputs[i] = correctOutput; 
            }
        }
    }

    // load network from a file 
    public Network loadNetwork(String filepath) throws FileNotFoundException {
        try (Scanner reader = new Scanner(new File(filepath))) {
            // grab network dimensions 
            int inputSize = reader.nextInt(); 
            int intermediateSize = reader.nextInt();
            int outputSize = reader.nextInt(); 

            Network network = new Network(inputSize, intermediateSize, outputSize); 

            // fill matrices in the same order as saveNetwork 
            for (int i = 0; i < network.w1.rows; i++) {
                for (int j = 0; j < network.w1.columns; j++) {
                    // double bc weights and bias values are doubles 
                    network.w1.insert(i, j, reader.nextDouble());
                }
            }
            for (int i = 0; i < network.w2.rows; i++) {
                for (int j = 0; j < network.w2.columns; j++) {
                    network.w2.insert(i, j, reader.nextDouble());
                }
            }
            for (int i = 0; i < network.b1.rows; i++) {
                for (int j = 0; j < network.b1.columns; j++) { 
                    network.b1.insert(i, j, reader.nextDouble());
                }
            }
            for (int i = 0; i < network.b2.rows; i++) {
                for (int j = 0; j < network.b2.columns; j++) { 
                    network.b2.insert(i, j, reader.nextDouble());
                }
            }

            return network; 
        }
    }

    // display individual digits with ASCII art
    public void displayDigit(Matrix input) {
        // simple bitmap for pixel greyscale values  
        String greyscale = " .:-=+*#%@"; 
        for (int i = 0; i < 28; i++) {
            for (int j = 0; j < 28; j++) {
                // what is the index of the current pixel
                int pixelIndex = i*28+j; 
                double pixel = input.data[pixelIndex][0]; 

                int shade = (int) (pixel*(greyscale.length()-1)); 
                System.out.print(greyscale.charAt(shade)); 
            }
            System.out.println(); 
        }
    }

    // display the digits with their classifications
    public void displayTestingResults(Network network, Matrix[] inputs, Matrix[] expectedOutputs, Scanner scanner, boolean ONLY_MISCLASSIFIED) {
        // same logic as evaluateCorrectness()
        for (int i = 0; i < inputs.length; i++) {
            int predictedDigit = network.predict(inputs[i]); 
            int actualDigit = -1; // not yet found 

            // for our current example, find the 1 row 
            for (int j = 0; j < expectedOutputs[i].rows; j++) {
                if (expectedOutputs[i].data[j][0] == 1.0) {
                    actualDigit = j; 
                    break; 
                }
            }

            // after finding the correct digit 
            if (ONLY_MISCLASSIFIED && predictedDigit == actualDigit) {
                continue; // skip the rest of the current example and move on; show only mistakes 
            }

            // display the results 
            System.out.print("Testing case #" + (i+1) + ": Correct classification = " + actualDigit + " Network Output = " + predictedDigit); 
            if (actualDigit == predictedDigit) {
                System.out.println(" Correct.");
            }
            else {
                System.out.println(" Incorrect.");
            }

            // display current example
            network.displayDigit(inputs[i]); 
            
            // user either moves on to next image or quits 
            System.out.println("Enter '1' to continue. All other values return to the main menu."); 
            String userIn = scanner.next(); 

            if (!userIn.equals("1")) {
                return; 
            }
        }
    }
}