# Fugaku tips
富岳を利用するにあたって、最低限必要な情報（tips）をまとめた。詳細はポータルサイトを参照のこと。

## Getting started
### 必要なもの
* 電子証明書が添付されたメール
* 証明書のパスフレーズが記載されたはがき

### 富岳にログイン
* ブラウザに電子証明書を登録
* ポータルサイト https://www.fugaku.r-ccs.riken.jp/ にアクセス
* https://www.fugaku.r-ccs.riken.jp/user_portal/ からssh公開鍵を登録
* `ssh userid@login.fugaku.r-ccs.riken.jp`

## アーキテクチャ
* CPU
  * A64FX 2.0GHz, 4xCMG (Core Memory Group) 
  * CMGあたり12コアで構成されるNUMA構造
* メモリ
  * 32GB/CPU (8GB/CMG)
  
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
### ジョブスクリプトサンプル（[job.sh](job.sh)）
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
## データの置き場
ソースコードはhome領域、計算に必要な大きなデータはwork領域に置く。work領域は、
```bash
$ mkdir /data/`id -gn`/`id -un`
```
のようにして、各自ユーザーIDの名前のディレクトリを作成し、その下にデータを置く。
どのくらいディスクを消費しているかは、
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
で確認できる（`/vol0006`がhome領域及びwork領域があるvolumeである）。
