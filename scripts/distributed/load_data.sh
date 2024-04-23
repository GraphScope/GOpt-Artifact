#!/bin/bash
dir=/tmp/data
data=$1
id=$2

mkdir -p $dir/$data
curl -o $dir/$data/${data}_p16_partition${id}.tar -L "https://graphscope.oss-cn-beijing.aliyuncs.com/atc23/glogs/Graphs/${data}_p16_partition${id}.tar"
cd $dir/$data && tar xvf ${data}_p16_partition${id}.tar
