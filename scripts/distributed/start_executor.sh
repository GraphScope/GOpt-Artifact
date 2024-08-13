#!/bin/bash
dir=/tmp/data
data=$1
id=$2
sudo docker run --net=host --memory=400g --name=${data}_test -v $dir:/data/test -v /home/admin/${data}_test:/home/GraphScope/op_test registry.cn-hongkong.aliyuncs.com/graphscope/gopt-bench:v0.0.1 sh -c "cd /home/GraphScope && DATA_PATH=/data/test/${data}/bin_p16 RUST_LOG=info PARTITION_ID=${id} ./start_rpc_server --config ./op_test/config > /home/GraphScope/op_test/executor_$id.log 2>&1"
