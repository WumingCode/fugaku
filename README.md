# Fugaku tips
## Getting started
### 必要なもの
* 電子証明書が添付されたメール
* 証明書のパスフレーズが記載されたはがき

### 富岳にログイン
* ブラウザに電子証明書を登録
* ポータルサイト https://www.fugaku.r-ccs.riken.jp/ にアクセス
* https://www.fugaku.r-ccs.riken.jp/user_portal/ からssh公開鍵を登録
* `ssh login.fugaku.r-ccs.riken.jp`

## コンパイラ/オプション
### コンパイラ
```bash
FC = mpifrtpx
```
### コンパイラオプション 
```bash
FCFLAGS = -Kfast,openmp
```
## ジョブ投入
```bash
$ pjsub job.sh
```
### ジョブスクリプトサンプル
```shell
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
```
### ジョブ経過チェック
```bash
$ pjstat
```
### リソース空きチェック
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
## データ管理
計算結果はホーム領域ではなくワーク領域に置くように。ワーク領域はまず、
```bash
$ mkdir /data/`id -gn`/`id -un`
```
として、各自ディレクトリを作成する。
