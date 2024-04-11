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

# Determine the value of the system property based on optValue
if [[ "$optValue" == "with" ]]; then
    graphPlannerIsOn="true"
else [[ "$optValue" == "without" ]]
    graphPlannerIsOn="false"
fi

# run rbo test
java -cp ".:${GIE_HOME}/lib/*" -Dgraph.planner.is.on=${graphPlannerIsOn} org.apache.calcite.plan.volcano.RBOTest