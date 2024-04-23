#!/bin/bash


# Initialize variables to hold the values of --query and --alternative arguments
query_value=""
alternative_value=""

# Loop through all arguments
while [[ $# -gt 0 ]]
do
  case $1 in
    --query=*)
      # Extract and store the value part if argument is --query
      query_value="${1#*=}"
      shift # Remove current argument from processing
      ;;
    --alternative=*)
      # Extract and store the value part if argument is --alternative
      alternative_value="${1#*=}"
      shift # Remove current argument from processing
      ;;
    *)
      # Unknown option, it might be useful to handle unexpected arguments
      echo "Ignoring unknown option: $1"
      shift # Remove current argument from processing
      ;;
  esac
done

# run scale latency test
java \
  -cp ".:${GIE_HOME}/libs/*" \
  -Djna.library.path=${GIE_HOME}/libs \
  -Dgraph.schema=${graph_schema} \
  -Dphysical.opt.config=${physical_opt_config} \
  -Dgraph.planner.opt=${graph_planner_opt} \
  -Dgraph.type.inference.enabled=${type_inference_enabled} \
  -Dconfig=${CONFIG}/compiler/compiler.properties \
  -Dquery=${query_value} \
  -Dalternative=${alternative_value} \
  org.apache.calcite.plan.volcano.ScaleLatencyTest
