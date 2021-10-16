#include <bits/stdc++.h>
#include <cuda.h>
#include <fstream>
#define num_threads 1024
using namespace std;

__global__ void level_bfs(int * que , int que_size , int *next_que , int *next_que_size , int *distance , int * ad_siz , int* edges ,int * startpos )
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    if(tid<que_size)
    {
        int v = que[tid];
        for(int i = startpos[v] ; i <= startpos[v] + ad_siz[v] ; i++ )
        {
            if(atomicCAS(&(distance[i]) , -1 , distance[v] + 1) == -1)
            {
                int pos = atomicAdd(next_que_size , 1);
                next_que[pos] = i;
            }
        }
    }
}

int main(int argc, char *argv[])
{
    
    ifstream input(argv[1]);

    int num_vertices , num_edges;
    
    input>>num_vertices;

    input>>num_edges;

    int *edges = (int*)malloc(num_edges*sizeof(int));
    int *startpos = (int*)malloc(num_vertices*sizeof(int));
    int *ad_siz = (int*)malloc(num_vertices*sizeof(int));
    int *dist = (int*)malloc(num_vertices*sizeof(int));
    int *que = (int*)malloc(num_vertices*sizeof(int));
    int *que_size =(int*)malloc(sizeof(int));
    int *next_que_size =(int*)malloc(sizeof(int));

    for(int i=0;i<num_edges;i++)
    {
        input>>edges[i];
    }


    for(int i =0; i<num_vertices ; i++)
    {
        input>>startpos[i];
    }


    for(int i =0; i<num_vertices ; i++)
    {
        input>>ad_siz[i];
    }

    // memset(dist , -1 , sizeof(dist));

    for(int i = 0 ; i < num_vertices ; i++)
    dist[i] = -1;

    dist[0] = 0;
    que[0] = 0;
    *que_size = 1;
    *next_que_size = 0;


    int *d_dist , *d_edges ,*d_start_pos , *d_ad_siz , *d_que, *d_next_que , *d_que_size , *d_next_que_size;
    
    cudaMalloc((void**)&d_dist , num_vertices*sizeof(int) );
    cudaMalloc((void**)&d_start_pos , num_vertices*sizeof(int) );
    cudaMalloc((void**)&d_ad_siz , num_vertices*sizeof(int) );
    cudaMalloc((void**)&d_que , num_vertices*sizeof(int) );
    cudaMalloc((void**)&d_next_que , num_vertices*sizeof(int) );
    cudaMalloc((void**)&d_edges , num_edges*sizeof(int) ); 
    cudaMalloc((void**)&d_que_size , sizeof(int) );
    cudaMalloc((void**)&d_next_que_size , sizeof(int) );

    cudaMemcpy(d_dist , dist , num_vertices*sizeof(int) , cudaMemcpyHostToDevice );
    cudaMemcpy(d_start_pos , startpos , num_vertices*sizeof(int) , cudaMemcpyHostToDevice );
    cudaMemcpy(d_ad_siz , ad_siz , num_vertices*sizeof(int) , cudaMemcpyHostToDevice );
    cudaMemcpy(d_que , que , num_vertices*sizeof(int) , cudaMemcpyHostToDevice );
    cudaMemcpy(d_edges , edges , num_vertices*sizeof(int) , cudaMemcpyHostToDevice );
    cudaMemcpy(d_que_size , que_size , sizeof(int) , cudaMemcpyHostToDevice );
    cudaMemcpy(d_next_que_size , next_que_size , sizeof(int) , cudaMemcpyHostToDevice );
    
    // cout<<"HI"<<endl;

    while(*que_size>0)
    {
        long num_blocks = (*que_size+num_threads-1)/num_threads;
        // cout<<"HI"<<endl;
        level_bfs<<<num_blocks , num_threads >>>(d_que , *que_size , d_next_que ,  d_next_que_size , d_dist , d_ad_siz , d_edges , d_start_pos);

        // cout<<"HI"<<endl;
        // break;
        cudaMemcpy( que_size , d_next_que_size , sizeof(int) , cudaMemcpyDeviceToHost  );
        cudaMemcpy( d_next_que_size , next_que_size , sizeof(int) , cudaMemcpyHostToDevice );
        // cout<<*que_size<<endl;
        swap(d_next_que , d_que);

    }

    cudaMemcpy( dist , d_dist , num_vertices*sizeof(int) , cudaMemcpyDeviceToHost );

    for(int i = 0 ; i < num_vertices ; i++)
    {
        cout<<i<<": "<<dist[i]<<endl;
    }

}