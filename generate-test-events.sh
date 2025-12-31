#!/bin/bash

echo "🎬 Generating test Kafka events..."
echo ""

KAFKA_CONTAINER="kafka"

while true; do
    # Random delay 1-3 seconds
    sleep $((1 + RANDOM % 3))

    # Generate random event type
    EVENT_TYPE=$((RANDOM % 4))
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    EVENT_ID="event-$(date +%s%N)"

    case $EVENT_TYPE in
        0)
            # API Usage Event
            echo "{\"event_id\":\"$EVENT_ID\",\"event_type\":\"api_call\",\"timestamp\":\"$TIMESTAMP\",\"provider\":\"saia\",\"model\":\"qwq-32b\",\"tokens\":$((100 + RANDOM % 5000)),\"success\":$((RANDOM % 10 > 1)),\"duration_ms\":$((100 + RANDOM % 5000)),\"session_id\":\"session-$((RANDOM % 100))\"}" | \
            docker exec -i $KAFKA_CONTAINER kafka-console-producer --bootstrap-server localhost:9092 --topic api-usage-events > /dev/null
            echo "✅ API Usage Event"
            ;;
        1)
            # Tool Execution Event
            TOOL_NUM=$((RANDOM % 6))
            case $TOOL_NUM in
                0) TOOL="chat" ;;
                1) TOOL="planner" ;;
                2) TOOL="codereview" ;;
                3) TOOL="debug" ;;
                4) TOOL="thinkdeep" ;;
                5) TOOL="refactor" ;;
            esac
            SUCCESS=$((RANDOM % 10 > 1))
            echo "{\"event_id\":\"$EVENT_ID\",\"event_type\":\"tool_execution\",\"timestamp\":\"$TIMESTAMP\",\"tool_name\":\"$TOOL\",\"provider\":\"saia\",\"model\":\"qwq-32b\",\"duration_ms\":$((500 + RANDOM % 10000)),\"success\":$SUCCESS,\"input_tokens\":$((100 + RANDOM % 2000)),\"output_tokens\":$((100 + RANDOM % 3000)),\"session_id\":\"session-$((RANDOM % 100))\"}" | \
            docker exec -i $KAFKA_CONTAINER kafka-console-producer --bootstrap-server localhost:9092 --topic tool-execution-events > /dev/null
            echo "✅ Tool Execution Event ($TOOL)"
            ;;
        2)
            # Session Event
            START_TIME=$(date -d '10 minutes ago' -u +"%Y-%m-%dT%H:%M:%SZ")
            END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
            echo "{\"event_id\":\"$EVENT_ID\",\"event_type\":\"session_lifecycle\",\"timestamp\":\"$TIMESTAMP\",\"session_id\":\"session-$((RANDOM % 50))\",\"session_start\":\"$START_TIME\",\"session_end\":\"$END_TIME\",\"total_tokens\":$((1000 + RANDOM % 50000)),\"api_calls\":$((1 + RANDOM % 50)),\"tool_calls\":$((1 + RANDOM % 20)),\"success\":true,\"termination_reason\":\"user_completed\"}" | \
            docker exec -i $KAFKA_CONTAINER kafka-console-producer --bootstrap-server localhost:9092 --topic session-events > /dev/null
            echo "✅ Session Event"
            ;;
        3)
            # Error Event
            ERROR_NUM=$((RANDOM % 5))
            case $ERROR_NUM in
                0) ERROR_CODE="TIMEOUT" ;;
                1) ERROR_CODE="RATE_LIMIT" ;;
                2) ERROR_CODE="AUTH_FAILED" ;;
                3) ERROR_CODE="MODEL_UNAVAILABLE" ;;
                4) ERROR_CODE="INVALID_REQUEST" ;;
            esac
            echo "{\"event_id\":\"$EVENT_ID\",\"event_type\":\"error\",\"timestamp\":\"$TIMESTAMP\",\"provider\":\"saia\",\"model\":\"qwq-32b\",\"tool_name\":\"chat\",\"session_id\":\"session-$((RANDOM % 100))\",\"error_code\":\"$ERROR_CODE\",\"error_message\":\"Error occurred: $ERROR_CODE\",\"retryable\":$((RANDOM % 2))}" | \
            docker exec -i $KAFKA_CONTAINER kafka-console-producer --bootstrap-server localhost:9092 --topic error-events > /dev/null
            echo "❌ Error Event ($ERROR_CODE)"
            ;;
    esac
done
