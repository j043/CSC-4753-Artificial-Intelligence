/* 
    Name: Jennifer Wright
    CWID: 10396439
    Date: 10/25/2026
    Assignment: 2, part 2
    Description: 
        This is a neural network program that uses Stochastic Gradient Descent and backpropagation to learn 
        on a provided training set. This is a 784 x 100 x 10 network training on the MNIST data set. 
*/ 

import java.io.File; 
import java.io.FileNotFoundException; 
import java.util.Scanner; 

public class Main {
    // constants 
    public static final double LEARNING_RATE = 5.0; 
    public static final int BATCH_SIZE = 10;  
    public static final int EPOCHS = 30; 
    public static final int HIDDEN_LAYER_SIZE = 100; // wanted to easily adjust this 

    public static void main(String[] args) throws FileNotFoundException {

        // allocate the training and testing sets 
        Matrix[] trainingInputs = new Matrix[60000]; 
        Matrix[] trainingOutputs = new Matrix[60000]; 

        Matrix[] testingInputs = new Matrix[10000]; 
        Matrix[] testingOutputs = new Matrix[10000]; 

        // allocate a new network
        Network network = new Network(784, HIDDEN_LAYER_SIZE, 10); 

        // load the training and testing sets from a CSV file 
        network.loadData("mnist_train.csv", trainingInputs, trainingOutputs); 
        network.loadData("mnist_test.csv", testingInputs, testingOutputs); 

        Scanner scanner = new Scanner(System.in); 
        boolean TRAINED = false; // network 
        boolean RUNNING = true; // system

        while (RUNNING) {
            // print the main menu 
            System.out.println(); 
            System.out.println("1. Train the network");
            System.out.println("2. Load a pre-trained network from 'network.txt'");
            System.out.println("3. Display network accuracy on training data");
            System.out.println("4. Display network accuracy on testing data");
            System.out.println("5. Run network on testing data showing images and labels");
            System.out.println("6. Display the misclassified testing images");
            System.out.println("7. Save the network state to 'network.txt'");
            System.out.println("0. Exit");
            System.out.println("\n Please enter a number 0-7. 3-7 are only available after using 1. or 2.\n");
            String userIn = scanner.next();
            System.out.println();

            // switch cases based on user input
            switch (userIn) { // invalid input
                default:
                    System.out.println("Please enter a number from 0 to 7. :)"); 
                    break;

                case "0": // quit
                    System.out.println("Bye bye!"); 
                    scanner.close();
                    RUNNING = false; 
                    break; 

                case "1": // train a new network
                    network = new Network(784, HIDDEN_LAYER_SIZE, 10);
                    network.train(trainingInputs, trainingOutputs, EPOCHS, BATCH_SIZE, LEARNING_RATE); 
                    TRAINED = true; 
                    break; 

                case "2": // load network
                    network = network.loadNetwork("network.txt"); 
                    TRAINED = true; 
                    break; 

                case "3": // display training accuracy 
                    if (TRAINED) {
                        network.evaluateCorrectness(trainingInputs, trainingOutputs); 
                    }
                    else {
                        System.out.println("Please train or load a network first.");
                    }
                    break; 

                case "4": // display testing accuracy 
                    if (TRAINED) {
                        network.evaluateCorrectness(testingInputs, testingOutputs); 
                    }
                    else {
                        System.out.println("Please train or load a network first.");
                    }
                    break; 

                case "5": // run network on testing data with images and labels 
                    if (TRAINED) {
                        network.displayTestingResults(network, testingInputs, testingOutputs, scanner, false); 
                    }
                    else {
                        System.out.println("Please train or load a network first.");
                    }
                    break; 

                case "6": // display only misclassified images 
                    if (TRAINED) {
                        network.displayTestingResults(network, testingInputs, testingOutputs, scanner, true); 
                    }
                    else {
                        System.out.println("Please train or load a network first.");
                    }
                    break;

                case "7": // save network 
                    if (TRAINED) {
                        network.saveNetwork("network.txt"); 
                    }
                    else {
                        System.out.println("Please train or load a network first.");
                    }
                    break; 
            }
        }
    }
}