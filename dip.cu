#include<stdio.h>
#include<stdlib.h>

#define N 100

void host_add(int *a, int *b, int *c) {
    for(int idx=0;idx<N;idx++)
        c[idx] = a[idx] + b[idx];
}
__global__ void scale(int *a, int *b, int sf) {
	int ind = blockIdx.x * blockDim.x + threadIdx.x;
    b[ind] = a[ind] * sf;
}
__global__ void scale_shared(int *a, int *b, int sf) {
	
        __shared__ int sharedMem [ N*N ];
	int ind = blockIdx.x * blockDim.x + threadIdx.x;
        sharedMem[ind] = a[ind] * sf;
        __syncthreads();
        b[ind] = sharedMem[ind];
}

//basically just fills the array with index.
void fill_array(int *data, int n) {
    for(int idx=0;idx<n*n;idx++)
        data[idx] = idx;
}

void print_output(int *a, int n) {
	printf("\n");
    for(int idx=0;idx<n;idx++){
    	for(int idy=0;idy<n;idy++)
        	printf("%d\t",  a[idx*n+idy]);
		printf("\n");
	}
}

// TIP To <b>Run</b> code, press <shortcut actionId="Run"/> or click the <icon src="AllIcons.Actions.Execute"/> icon in the gutter.
int main(void) {
    int *a, *b;
    int *d_a, *d_b; // device copies of a, b, c
	char line[100],ch;
	int n,sf=5;
	while(1) {
	printf("\nEnter dimension :");
	fgets(line,100,stdin);
	sscanf(line,"%d",&n);
	printf("\nEnter scaling Factor :");
	fgets(line,100,stdin);
	sscanf(line,"%d",&sf);

    int size = n*n * sizeof(int);

    // Allocate space for host copies of a, b, c and setup input values
    a = (int *)malloc(size);
    fill_array(a,n);
	b = (int *)malloc(size);
	print_output(a,n);

	printf("Enter Command : ");
	fgets(line,100,stdin);
	sscanf(line,"%c",&ch);

	printf("Detected command : %c\n",ch);
	if (ch=='y'){
	cudaMalloc((void**)&d_a, size);
    cudaMalloc((void**)&d_b, size);

    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);

    scale_shared<<<n,n>>>(d_a,d_b,sf);


    cudaMemcpy(b, d_b, size, cudaMemcpyDeviceToHost);

	print_output(b,n);
	cudaFree(d_a); cudaFree(d_b);
	} else if (ch=='x') break;
 else
printf("Incorrect character command enter y");
free(a); free(b);

}


    return 0;
}