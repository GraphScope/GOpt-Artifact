#!/bin/bash

# Initialize orderValue variable
orderValue=""

# Loop through arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --order) # Look for --order parameter
            orderValue="$2" # Assign the next argument as the value of --order
            shift # Move past the value
            ;;
    esac
    shift # Move to the next key-value pair or standalone flag
done

# Start GIE System
cd ${GIE_HOME}
RUST_LOG=info DATA_PATH=${DATA}/bi30_bin_p1 ./start_rpc_server --config=${CONFIG}/engine.config &

# Determine the CBO test to run based on orderValue
if [[ "$orderValue" == "GOpt" ]]; then
    java -cp ".:${GIE_HOME}/lib/*" org.apache.calcite.plan.volcano.CBOGOptTest &
elif [[ "$orderValue" == "Random" ]]; then
    java -cp ".:${GIE_HOME}/lib/*" org.apache.calcite.plan.volcano.CBORandomTest &
else 
    java -cp ".:${GIE_HOME}/lib/*" org.apache.calcite.plan.volcano.CBONeo4jTest &
fi