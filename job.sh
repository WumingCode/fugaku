#!/bin/sh
#PJM --name "test"
#PJM -L  "node=900"              # 割当ノード数900
#PJM -L  "rscgrp=large"          # リソースグループの指定
#PJM -L  "elapse=12:00:00"       # 経過時間制限 12時間
#PJM --mpi "max-proc-per-node=4" # 1ノードあたりに生成するMPIプロセス数の上限値
#PJM -o sys_out
#PJM -e sys_err

export OMP_NUM_THREADS=12         # スレッド数の指定
export PLE_MPI_STD_EMPTYFILE=OFF  # 空の標準出力ファイルの生成の抑制
export OMPI_MCA_plm_ple_memory_allocation_policy=bind_local  # CMGのメモリとプロセスをバインド

mpiexec -n 3600 -stdout sys_out -stderr sys_err ./em2d_test.out　# 900 node x 4 MPI procs
