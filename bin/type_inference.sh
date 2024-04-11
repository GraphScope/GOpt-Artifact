#!/bin/bash

# Initialize optValue variable
optValue=""

# Loop through arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --opt) # Look for --opt parameter
            optValue="$2" # Assign the next argument as the value of --opt
            shift # Move past the value
            ;;
    esac
    shift # Move to the next key-value pair or standalone flag
done

# Start GIE System
cd ${GIE_HOME}
RUST_LOG=info DATA_PATH=${DATA}/bi30_bin_p1 ./start_rpc_server --config=${CONFIG}/engine.config &
if [[ "$optValue" == "with" ]]; then
    make run config.path=${CONFIG}/compiler.config graph.type.inference.enabled=true &
else
    make run config.path=${CONFIG}/compiler.config graph.type.inference.enabled=false &
fi

# run type_inference test
java -cp ".:${GIE_HOME}/lib/*" org.apache.calcite.plan.volcano.TypeInferenceTest