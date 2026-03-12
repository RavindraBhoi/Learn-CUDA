#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
#define BLOCK_SIZE 32
__global__ void add_and_transpose(int *A, int *B, int *C, int N)
{
   __shared__ int tile[BLOCK_SIZE][BLOCK_SIZE];
   int x = threadIdx.x + blockIdx.x * blockDim.x;
   int y = threadIdx.y + blockIdx.y * blockDim.y;
   int localX = threadIdx.x;
   int localY = threadIdx.y;
   if(x < N && y < N)
   {
       int index = y * N + x;
       // Matrix Addition
       int value = A[index] + B[index];
       // Store result in shared memory
       tile[localX][localY] = value;
   }
   __syncthreads();
   int tx = threadIdx.x + blockIdx.y * blockDim.x;
   int ty = threadIdx.y + blockIdx.x * blockDim.y;
   if(tx < N && ty < N)
   {
       int tindex = ty * N + tx;
       // Write transposed result
       C[tindex] = tile[localY][localX];
   }
}
void fill_matrix(int *data, int N)
{
   for(int i = 0; i < N*N; i++)
       data[i] = i;
}
void print_matrix(int *data, int N)
{
   for(int i=0;i<N;i++)
   {
       for(int j=0;j<N;j++)
       {
           printf("%4d ", data[i*N+j]);
       }
       printf("\n");
   }
}
int main()
{
   int N;
   printf("Enter matrix size N: ");
   scanf("%d",&N);
   int size = N*N*sizeof(int);
   int *A,*B,*C;
   int *d_A,*d_B,*d_C;
   A = (int*)malloc(size);
   B = (int*)malloc(size);
   C = (int*)malloc(size);
   fill_matrix(A,N);
   fill_matrix(B,N);
   cudaMalloc((void**)&d_A,size);
   cudaMalloc((void**)&d_B,size);
   cudaMalloc((void**)&d_C,size);
   cudaMemcpy(d_A,A,size,cudaMemcpyHostToDevice);
   cudaMemcpy(d_B,B,size,cudaMemcpyHostToDevice);
   dim3 block(BLOCK_SIZE,BLOCK_SIZE);
   dim3 grid((N+BLOCK_SIZE-1)/BLOCK_SIZE,(N+BLOCK_SIZE-1)/BLOCK_SIZE);
   add_and_transpose<<<grid,block>>>(d_A,d_B,d_C,N);
   cudaMemcpy(C,d_C,size,cudaMemcpyDeviceToHost);
   printf("\nMatrix A:\n");
   print_matrix(A,N);
   printf("\nMatrix B:\n");
   print_matrix(B,N);
   printf("\nResult (Addition + Transpose):\n");
   print_matrix(C,N);
   cudaFree(d_A);
   cudaFree(d_B);
   cudaFree(d_C);
   free(A);
   free(B);
   free(C);
   return 0;
}