# Fugaku tips
富岳を利用するにあたって、最低限必要な情報（tips）をまとめた。詳細は[富岳利用者用ページ](https://www.fugaku.r-ccs.riken.jp/)を参照のこと。
The following is a summary of the minimum necessary information (tips) for using Fugaku. For details, please refer to the [Fugaku User's Page](https://www.fugaku.r-ccs.riken.jp/).

## Getting started
### What you need
* 電子証明書が添付されたメール
* 証明書のパスフレーズが記載されたはがき

* An e-mail with a digital certificate attached
* A postcard containing the passphrase for the certificate

### logining in Fugaku
* ブラウザに電子証明書を登録
* https://www.fugaku.r-ccs.riken.jp/user_portal/ からssh公開鍵を登録
* `ssh userid@login.fugaku.r-ccs.riken.jp`

* Register digital certificate in browser
* Register ssh public key from https://www.fugaku.r-ccs.riken.jp/user_portal/
* `ssh userid@login.fugaku.r-ccs.riken.jp`

## Specification
* CPU
  * A64FX 2.0GHz, 4xCMG (Core Memory Group) 
  * 12 cores/CMG NUMA architecture
* memory
  * 32GB/CPU (8GB/CMG)
  
## Compiler / Options
### Compiler
```bash
FC = mpifrtpx
```
### options 
```bash
FCFLAGS = -Kfast,openmp
```
## How to submit a job
```bash
$ pjsub job.sh
```
### jobscript sample（[job.sh](job.sh)）
```shell
#!/bin/sh
#PJM --name "test"
#PJM -L  "node=900"              # 900 nodes
#PJM -L  "rscgrp=large"          # specifying resource group
#PJM -L  "elapse=12:00:00"       # elapse time 12hrs max for large que
#PJM --mpi "max-proc-per-node=4" # maximum number of MPI procs/node
#PJM -g hp120286                 # specify account's group ID
#PJM -o sys_out
#PJM -e sys_err

export OMP_NUM_THREADS=12         # # of threads
export PLE_MPI_STD_EMPTYFILE=OFF  # suppressing generation of empty file (optional)
export OMPI_MCA_plm_ple_memory_allocation_policy=bind_local  # memory bind to local CMG (optional)

mpiexec -n 3600 -stdout sys_out -stderr sys_err ./em2d_test.out　# 900 node x 4 MPI procs
```
### job execution check
```bash
$ pjstat
```
### available resource check
```bash
$ pjshowrsc small
[ CLST: fugaku-comp ]
RSCUNIT          NODE
                 TOTAL   FREE  ALLOC
rscunit_ft01    158590  39898 118692
$ pjshowrsc large
[ CLST: fugaku-comp ]
RSCUNIT          NODE
                 TOTAL   FREE  ALLOC
rscunit_ft01    158590  39898 118692
```
## data storage
The source code is placed in the home area, and the large data required for computation is placed in the work area.
```bash
$ mkdir /data/hp120286/`id -un`
```
and each user creates a directory with the name of the user ID and places the data under it.
How much disk space they consume is obtained by 
```bash
$ accountd
COLLECTDATE : 2021/08/07 08:50:22    unit[GiB] 
USER : ??????
*--------------------------------------------------[GROUP]-----------------------------------------------------*
GROUP           FILESYSTEM                   LIMIT             USAGE         AVAILABLE           FILES  USE_RATE
*hp??????       /vol0003                 1,843,200           188,030         1,655,170         311,934     10.2%
*hp??????       /vol0004                       ---            31,473               ---       9,319,908       ---
*hp??????       /vol0006                 3,276,800         2,947,883           328,917     165,597,045     90.0%
*--------------------------------------------------[USER]------------------------------------------------------*
USER            FILESYSTEM                   LIMIT             USAGE         AVAILABLE           FILES  USE_RATE
??????          /vol0003                 unlimited                 0         unlimited               0       ---
??????          /vol0004                 unlimited                 1         unlimited           3,317       ---
??????          /vol0006                 unlimited             3,640         unlimited         721,687       ---
```
