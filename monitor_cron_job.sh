#!/bin/bash 

# Set environment variables
PYTHON_SCRIPT=$1
JOB_NAME=$2
LOG_FILE=$3
NEW_RELIC_API_KEY=NEW_RELIC_API_KEY
NEW_RELIC_ACCOUNT_ID=123456789

# Start time
START_TIME=$(date +%s%N)
START_TIMESTAMP=$(date +%Y-%m-%d\ %H:%M:%S)

# Activate virtual environment and run Python script
python $PYTHON_SCRIPT > /dev/null 2>&1
SCRIPT_EXIT_CODE=$?

# End time
END_TIME=$(date +%s%N)
END_TIMESTAMP=$(date +%Y-%m-%d\ %H:%M:%S)

# Execution time in millisecomds
EXECUTION_TIME=$(( (END_TIME - START_TIME) / 1000000 ))


# Determine if script was successful or not
if [ $SCRIPT_EXIT_CODE -eq 0 ]; then
  JOB_STATUS="SUCCESS"
else
  JOB_STATUS="FAILED"
fi

# Send data to New Relic
curl -X POST "https://insights-collector.eu01.nr-data.net/v1/accounts/$NEW_RELIC_ACCOUNT_ID/events" \
  -H "Content-Type: application/json" \
  -H "X-Insert-Key: $NEW_RELIC_API_KEY" \
  -d '[{"eventType":"CronJob","jobName":"'"$JOB_NAME"'","startTimestamp":"'"$START_TIMESTAMP"'","endTimestamp":"'"$END_TIMESTAMP"'","executionTimeMs":'"$EXECUTION_TIME"',"jobStatus":"'"$JOB_STATUS"'"}]'
