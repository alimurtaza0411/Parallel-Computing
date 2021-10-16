import concurrent.futures
import multiprocessing
import random
import time

start = time.perf_counter()

n_tree = 7

# adj = [[]] * (int(n_tree)+1)
# adj.append([0])

# for i in range(2, int(n_tree) + 1):
#     p = random.randint(0, i - 1)
#     adj[p].append(i)
#     adj[i].append(p)

adj = []
adj.append([0])  # 0
adj.append([2, 3])  # 1
adj.append([1, 4, 5])  # 2
adj.append([1, 6, 7])  # 3
adj.append([2])  # 4
adj.append([2])  # 5
adj.append([3])  # 6
adj.append([3])  # 7

visited = [False for _ in range(len(adj))]


def dfs(n, k, d=0):
    visited[n] = True
    if n == k:
        print(f'Finished in {round(time.perf_counter() - start, 2)} second(s), depth is {d}')
        exit(0)
    for v in adj[n]:
        if not visited[v]:
            dfs(v, k, d+1)


def p_dfs(n, k, d=0):
    visited[n] = True
    if n == k:
        print(f'Finished in {round(time.perf_counter() - start, 2)} second(s), depth is {d}')
        exit(0)
    for v in adj[n]:
        if not visited[v]:
            t = multiprocessing.Process(target=p_dfs, args=(v, k, d+1))
            t.start()


p_dfs(1, 7)
