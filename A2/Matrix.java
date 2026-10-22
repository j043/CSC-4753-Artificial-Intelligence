/* 
    AUTHOR'S NOTES: 

    This Matrix class houses all of the properties and functions necessary for the neural-network's computations. 
    - The class contains 3 public fields: rows, columns, and data. 
    - On an individual matrix, 4 functions can be performed: insert, transpose, scale, and print.
    - On two matrices, 4 functions can be performed: add, subtract, multiply, and hadamard. 
    
    The reason I include a Hadamard function as well as a multiply function is due to the fact that we cannot guarantee
    that the activation matrix will be a square, and you can only multiply two matrices of the same dimension together 
    if they are both squares. Therefore, we need a method to logically multiply each value in these same-size matrices, 
    and the Hadamard product (or element-wise product) allows us to do so! 

    - Jenny :) 
*/ 

public class Matrix {
    // fields 
    public int rows; 
    public int columns; 
    public double[][] data; 

    // ctor 
    public Matrix(int rows, int columns) {
        this.rows = rows; 
        this.columns = columns; 
        this.data = new double[rows][columns];
    }

    // functions on individual matrices
    public void insert(int row, int column, double value) {
        if (row < 0 || row >= this.rows || column < 0 || column >= this.columns) {
            return;
        }
        else { 
            this.data[row][column] = value; 
        }
    }

    public Matrix transpose() {
        Matrix t = new Matrix(this.columns, this.rows); 

        for (int i = 0; i < this.columns; i++) {
            for (int j = 0; j < this.rows; j++) {
                t.data[i][j] = this.data[j][i]; 
            }
        }
        return t;
    }

    public void scale(double scalar) {
        for (int i = 0; i < this.rows; i++) {
            for (int j = 0; j < this.columns; j++) {
                this.data[i][j] *= scalar; 
            }
        }
    }

    public void print() {
        for (int i = 0; i < this.rows; i++) {
            for (int j = 0; j < this.columns; j++) {
                System.out.print(this.data[i][j] + " ");
            }
            System.out.println();
        }
        System.out.println();
    }

    // functions on two matrices 
    public Matrix add(Matrix other) {
        if (this.rows != other.rows || this.columns != other.columns) {
            return null;
        }
        else {
            Matrix s = new Matrix(this.rows, other.columns);

            for (int i = 0; i < this.rows; i++) { 
                for (int j = 0; j < this.columns; j++) {
                    double sum = this.data[i][j] + other.data[i][j]; 
                    s.insert(i, j, sum);
                }
            }
            return s; 
        }
    }

    public Matrix sub(Matrix other) {
        if (this.rows != other.rows || this.columns != other.columns) {
            return null;
        }
        else {
            Matrix d = new Matrix(this.rows, other.columns);

            for (int i = 0; i < this.rows; i++) { 
                for (int j = 0; j < this.columns; j++) {
                    double difference = this.data[i][j] - other.data[i][j]; 
                    d.insert(i, j, difference);
                }
            }
            return d; 
        }
    }

    // this * other, specifically
    public Matrix multiply(Matrix other) {
        if (this.columns != other.rows) {
            return null;
        }
        else {
            Matrix p = new Matrix(this.rows, other.columns);

            for (int i = 0; i < this.rows; i++) { 
                for (int j = 0; j < other.columns; j++) {
                    double dotProduct = 0; 
                    for (int k = 0; k < this.columns; k++) {
                        // dot product of first matrix's rows and second matrix's columns 
                        dotProduct += this.data[i][k] * other.data[k][j]; 
                    }
                    p.insert(i, j, dotProduct);
                }
            }
            return p; 
        }
    }

    public Matrix hadamard(Matrix other) {
        if (this.rows != other.rows || this.columns != other.columns) {
            return null;
        }
        else {
            Matrix h = new Matrix(this.rows, other.columns);

            for (int i = 0; i < this.rows; i++) { 
                for (int j = 0; j < this.columns; j++) {
                    double hadamardProduct = this.data[i][j] * other.data[i][j]; 
                    h.insert(i, j, hadamardProduct);
                }
            }
            return h; 
        }
    }
}