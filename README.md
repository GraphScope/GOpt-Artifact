# GOpt Artifacts

This repository contains the artifacts related to the paper titled "A Modular Graph-Native Query Optimization Framework".

Firstly, it includes supplementary material which primarily consists of two additional components: (1) Supplementary execution plans for the GOpt paper experiments, including the a case study on LDBC queries and execution plans for QC queries; and (2) Detailed information about the unified intermediate representation (GIR) used in GOpt.
Please refer to the [supplementary_material.pdf](https://github.com/GraphScope/GOpt-Artifact/blob/main/supplementary_material.pdf).

Secondly, we offer a comprehensive set of resources to replicate the experiments detailed in the paper. These resources encompass the necessary environment, datasets, and scripts required for executing the experiments.

As delineated in the paper, the experimental analysis is divided into two segments: small-scale experiments and scalability experiments. The small-scale experiments aim to assess GOpt's performance on a single-machine setup using the G30 dataset and the IMDB dataset. Evaluations cover various aspects such as type inference efficiency, the efficacy of heuristic rules, cost-based optimization strategies, and optimization of LDBC queries on G30, and JOB on IMDB. In contrast, the scalability experiments focus on examining GOpt's performance across large-scale graphs (ranging from G30 to G1000) within a robust 16-machine cluster environment.

## Small-Scale Experiments

### Settings

#### Hardware
The experiments on a smaller scale were carried out on a single machine powered by dual Intel Xeon E5-2620 v4 CPUs (boasting 8 cores and operating at a 2.1GHz clock speed), 512GB of memory, and a 1TB disk. This setup employs 32 threads for execution.

#### Dataset
For these experiments, we utilized the G30 dataset and IMDB dataset. G30 includes 89 million vertices and 541 million edges, and IMDB includes 50 million vertices and 162 million edges.
These two datasets has been preprocessed into a binary format compatible with the GIE system. The entire datasets of G30 and IMDB are approximately 40GB and 6GB in size respectively, a convenient one-click script is included for loading the datasets from remote oss to the docker container:
```bash
cd ${GIE_HOME}/scripts
./load_data.sh
```

#### Environment
To facilitate the experiments, a docker image incorporating all necessary binary dependencies, scripts, and the dataset itself is provided. To initiate an experimental container, execute the following command:
```bash
docker run --name=gopt_bench -it registry.cn-hongkong.aliyuncs.com/graphscope/gopt-bench:v0.0.1 /bin/bash
```

Within the `/home/graphscope/GIE` directory of the container, you will find:
```bash
├── bin # binaries to start the GIE system
├── config # configuration files to start the GIE system
│   ├── compiler
│   └── engine
├── libs # binary dependencies, including some jar files
└── scripts # scripts to run the experiments
    ├── cbo.sh
    ├── job.sh
    ├── kill.sh
    ├── ldbc.sh
    ├── load_data.sh
    ├── rbo.sh
    └── type_inference.sh
```

### Evaluation

#### Type Inference
The performance impact of enabling or disabling type inference optimization within the GIE system is assessed. To replicate these experiment results, use the commands below with the --opt with/without flag determining the state of type inference optimization:
```bash
cd {GIE_HOME}/scripts
./type_inference.sh --opt with
```
```bash
./type_inference.sh --opt without
```
Expected results are organized as follows:
```
query: [Q_T_1], latency: [32232] ms
query: [Q_T_2], latency: [913] ms
query: [Q_T_3], latency: [63800] ms
...
```
#### Heuristic Rules
This part evaluates different RBO rules' impact on query groups as outlined in the paper. Performance comparisons include FieldTrimRule for [Qr1, Qr2], ExpandGetVFusionRule for [Qr3, Qr4], FilterIntoMatchRule for [Qr5, Qr6], and CommonElimRule for [Qr7, Qr8]. To avoid the complexity of the configuration, we have already bound RBO rules to specific query groups in the scripts. You can reproduce the results of the experiments with the following command directly, where `--opt with/without` controls whether to enable the heuristic rules optimization.
```bash
./rbo.sh --opt with
```
```bash
./rbo.sh --opt without
```
The expected output format is as follows:
```
query: [Q_R_1], latency: [117774] ms
query: [Q_R_2], latency: [40629] ms
...
```

#### Cost-based Optimization
In this part of the experiment, we compare the optimal order generated by GOpt and Neo4j on the query set [Qc](https://github.com/alibaba/GraphScope/tree/main/interactive_engine/benchmark/queries/cypher_queries). In addition, we randomly select up to 10 orders for comparison. We have added the `--order GOpt/Neo4j/Random` option in the script to generate the results of different orders:
```bash
./cbo.sh --order GOpt
```
```bash
./cbo.sh --order Random
```
```bash
./cbo.sh --order Neo4j
```
Anticipated outputs should be similar to:
```
*************[Q_C_1_a]*************
plan id [0], latency: [1394331] ms
plan id [1], latency: [23531] ms
plan id [2], latency: [2805822] ms
...
```
When `--order` is specified as GOpt or Neo4j, only one plan id will be output for a query, indicating the optimal execution order generated by GOpt or Neo4j. When `--order` is specified as Random, multiple plan ids will be output for a query, indicating the randomly generated execution order.

#### Optimizing LDBC Queries
To verify the optimization effect of GOpt in a real scenario, we repeated the above experiments on the [LDBC Query Set](https://github.com/ldbc/ldbc_snb_interactive_v1_impls/tree/main/cypher/queries). Similarly, You can get the performance of LDBC queries on different orders by leveraging the `--order` option:
```bash
./ldbc.sh --order GOpt
```
```bash
./ldbc.sh --order Random
```
```bash
./ldbc.sh --order Neo4j
```
The resultant performance metrics are presented as follows:
```
*************[Q_IC_1]*************
plan id [0], latency: [1927] ms
plan id [1], latency: [532] ms
plan id [2], latency: [4786] ms
...
```

#### Optimizing JOB Queries
For further evaluation on real-world queries, we tested the performance with JOB queries on IMDB dataset. Similarly, You can get the performance of JOB queries on different orders by leveraging the `--order` option:
```bash
./job.sh --order GOpt
```
```bash
./job.sh --order Random
```
```bash
./job.sh --order Neo4j
```
The resultant performance metrics are presented as follows:
```
*******************************************[1a.cypher]*******************************************
plan id [0], latency [138] ms
plan id [1], latency [3424] ms
plan id [2], latency [22338] ms
...
```

## Scalability Experiments

In our study, we explored the optimization effects of GOpt on large-scale datasets from two perspectives: 
1. Data Scale: observing how query latency changes with a linear increase in data volume; 
2. Scale up: examining the alterations in query latency as the number of threads on a single machine increases.

### Settings

#### Hardware

Our experiments were conducted on a robust cluster of 16 interconnected machines. Each machine is configured to support 2 threads and is outfitted with dual Intel Xeon E5-2620 v4 CPUs (featuring 8 cores and a clock speed of 2.1GHz), supplemented by 512GB of memory and a 1TB disk for storage.

#### Dataset

We engaged four distinct LDBC datasets for our experiments: G30, G100, G300, G1000. To facilitate the distribution across our hardware setup, these datasets were divided into 16 partitions employing the edge-cut strategy. Consequently, each physical machine handled one data partition, simultaneously accessed by two threads. To streamline the process, we offer a straightforward script enabling the download of data directly from remote oss to each physical machine, transferring it into the docker container via docker volume. Utilize the script below to download the G30 data of 16 partitions to the `/tmp/data` directory on the respective physical machine:

```bash
cd ${GIE_HOME}/scripts/distributed
./deploy.sh hosts ./load_data.sh G30
```

The network addresses of the 16 machines can be configured in the `hosts` file:

```bash
100.12.13.14
100.13.13.15
100.13.13.16
...
```

#### Environment

To conduct our large-scale experiments, we utilized the `gopt_bench` docker container to deploy the GIE system. Furthermore, we've prepared scripts to simulate a 16-node cluster environment on physical machines. To initiate the cluster, follow the steps outlined below:

1. Define the network addresses of the 16 machines in the `hosts` file:

    ```bash
    100.12.13.14
    100.13.13.15
    100.13.13.16
    ...
    ```
2. Activate the GIE system on each machine, specifying the dataset for use (e.g., G30):

    ```bash
    ./deploy_async.sh hosts ./start_executor.sh G30
    ```

    Once these steps are completed, the GIE System is operational, ready for large-scale experimentation as detailed in the Evaluation section.

3. Before switching datasets, ensure to halt the GIE system across all nodes:

    ```bash
    ./deploy.sh hosts ./stop_executor.sh G30
    ```

### Evaluation

#### Data Scale & Scale Up

Our evaluation focused on the variations in query latency as we transitioned among different datasets or thread numbers. For this purpose, we employed the [LDBC Query Set](https://github.com/ldbc/ldbc_snb_interactive_v1_impls/tree/main/cypher/queries). 

While comprehensive scripts for independently reproducing Data Scale and Scale Up performance are not provided, owing to dataset-specific configurations required at system startup, we offer detailed scripts enabling performance assessment for specified queries within a given dataset. By default, the performance metrics reflect the query’s execution under GOpt's optimal plan. However, the `--alternative` option allows for performance comparison under various sub-optimal plans, supporting reproducibility of results discussed in our paper. Here's how to use the scripts:

To assess the performance of query IC3 under GOpt's optimal plan:
```bash
./scale_latency.sh --query=Q_IC_3
```

For evaluating the performance of IC3 under an alternative plan (plan1):
```bash
./scale_latency.sh --query=Q_IC_3 --alternative=plan1
```

Expected output for these commands:
```bash
query: [Q_IC_3][GOpt], latency: [XX] ms
query: [Q_IC_3][plan1], latency: [XX] ms
query: [Q_IC_3][plan2], latency: [XX] ms
```
