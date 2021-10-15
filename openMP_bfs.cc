#include <stdio.h>
#include <sys/time.h>
#include <omp.h>
#include <stdlib.h>
void serial_bfs(int **nodes,bool visited[], int n){
    int front=0, rear=1;
    int queue[n];
    queue[0] = 0;
    visited[0] = true;
    while(1){
        int u = queue[front++];
        for(int i=0;i<n;i++){
            int edge = nodes[u][i];
            if(edge==1 && !visited[i]){
                queue[rear++] = i;
                visited[i] = true;
            }
        }
        if(front==rear) break;
    }
    return;

}
void parallel_bfs(int **nodes,bool visited[], int n){
    int front=0, rear=1;
    int queue[n];
    visited[0] = true;
    queue[0]=0;
    while(1){
        int f=front,r=rear;
        int u;
        #pragma omp parallel private(u) num_threads(10)
        {
            #pragma omp for
                for(int j=f;j<r;j++){
                    u = queue[j];
                    for(int i=0;i<n;i++){
                        if(nodes[u][i]==1 && !visited[i]){
                            #pragma omp critical
                            {
                                queue[rear] = i;
                                rear++;
                            }
                            visited[i] = true;
                        }
                    }
                }
        }
        front=r;
        if(front==rear) break;
    }
    return;
}

int main(){
    struct timeval TimeValue_Start;
	struct timezone TimeZone_Start;
	struct timeval TimeValue_Final;
	struct timezone TimeZone_Final;
    long time_start, time_end;
	double time_overhead;

    int n,m;
    scanf("%d %d",&n,&m);
    int **nodes = (int **)malloc(n * sizeof(int *));
    for (int i = 0; i < n; i++) {
        nodes[i] = (int *)malloc(n * sizeof(int));
    }
    for(int i=0;i<n;i++){
        for(int j=0;j<n;j++){
            nodes[i][j]=0;
        }
    }
    for(int i=0;i<m;i++){
        int u,v;
        scanf("%d %d",&u,&v);
        nodes[u][v] = 1;
        nodes[v][u] = 1;
    }
    bool visited[n];
    for(int i=0;i<n;i++) visited[i]=0;
    printf("\nParallel");
    gettimeofday(&TimeValue_Start, &TimeZone_Start);
    parallel_bfs(nodes,visited,n);
    gettimeofday(&TimeValue_Final, &TimeZone_Final);

    time_start = TimeValue_Start.tv_sec * 1000000 + TimeValue_Start.tv_usec;
    time_end = TimeValue_Final.tv_sec * 1000000 + TimeValue_Final.tv_usec;
    time_overhead = (time_end - time_start)/1000000.0;
    printf("\nTime in Seconds (T) : %lf\n",time_overhead); 
    
    for(int i=0;i<n;i++) visited[i]=0;
    printf("\nSerial");
    gettimeofday(&TimeValue_Start, &TimeZone_Start);
    serial_bfs(nodes,visited,n); 
    gettimeofday(&TimeValue_Final, &TimeZone_Final);

    time_start = TimeValue_Start.tv_sec * 1000000 + TimeValue_Start.tv_usec;
    time_end = TimeValue_Final.tv_sec * 1000000 + TimeValue_Final.tv_usec;
    time_overhead = (time_end - time_start)/1000000.0;
    printf("\nTime in Seconds (T) : %lf\n\n",time_overhead); 

    return 0;
}
