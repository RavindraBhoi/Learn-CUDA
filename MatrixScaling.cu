#include <iostream>
#include<cuda_runtime.h>
#include<cstring>
#define BLOCK_SIZE 2
using namespace std;
//CUDA Kernel
__global__ void matrixScaling(float * A,float *C,float k, int N) {
    int indexX = threadIdx.x + blockIdx.x*blockDim.x;
    int indexY = threadIdx.y + blockIdx.y*blockDim.y;
    // Only calculate if the thread is inside the matrix bounds
    if (indexX < N && indexY < N) {
        int index = indexY * N + indexX;
        C[index] = A[index] * k;
    }
}
//Matrix output printing.
void printMatrix(float *C, int N) {
    for (int i =0;i<N;i++) {
        for (int j=0;j<N;j++) {
            cout<<C[i*N + j]<<"\t";
        }
        cout << "\n";//This is for 2D grid
    }
    cout << "------------\n";
}
int main() {
    float *Ah, *Ad,*Ch, *Cd;
    int N = 0 ;
    float k = 0.0f;
    //int threadsperBlock = 0, numOfThreads = 0; USED FOR vector addition
    char command[6];
    cout<< "Enter Dimension of the matrix: "<<endl;
    cin>>N;//CAN BE replaced by scanf("%d",&N);
    cout<<"Enter Scaling Factor: "<<endl;
    cin>>k;
    memset(command, '\0', sizeof(command));
    cout<< "Enter the command: "<<endl;
    cin>>command;
    int size = (N*N)*sizeof(float);
    Ah = (float *)malloc(size);//Dynamic Memory Allocation
    Ch = (float *)malloc(size);
    cudaMalloc((void **)&Ad,size);
    cudaMalloc((void **)&Cd,size);
    //Taking Sensor Input
    for (int i= 0;i<N;i++) {
        for (int j = 0;j<N;j++) {
            Ah[i*N + j] = i*N+j;
        }
    }
    printMatrix(Ah,N);
    dim3 blocksize(BLOCK_SIZE,BLOCK_SIZE);
    dim3 gridsize((N + BLOCK_SIZE - 1) / BLOCK_SIZE, (N + BLOCK_SIZE - 1) / BLOCK_SIZE);
    //Copy from RAM to VRAM
    cudaMemcpy(Ad,Ah,size,cudaMemcpyHostToDevice);
    if (command == "START") {//if (strcmp(command,"START")==0) {
        matrixScaling<<<gridsize,blocksize>>>(Ad,Cd,k,N);
        //Synchronism of device and host
        cudaDeviceSynchronize();        //Copy from VRAM to RAM
        cudaMemcpy(Ch,Cd,size,cudaMemcpyDeviceToHost);
        printMatrix(Ch,N);
    }
    else
        cout<<"Command Not Implimented"<<endl;
    //Clearing Heap Mempry of RAM and VRAM
    free(Ah);
    free(Ch);
    cudaFree(Ad);
    cudaFree(Cd);
    return 0;
}
