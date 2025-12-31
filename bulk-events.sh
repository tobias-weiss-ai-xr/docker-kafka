#!/bin/bash

echo "Generating 30 events across 4 topics..."

for i in {1..30}; do
    sleep 0.5
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    EVENT_TYPE=$((i % 4))

    case $EVENT_TYPE in
        0)
            # API Usage
            echo "{\"event_id\":\"auto-$i\",\"event_type\":\"api_call\",\"timestamp\":\"$TIMESTAMP\",\"provider\":\"saia\",\"model\":\"qwq-32b\",\"tokens\":$((100 + RANDOM % 1000)),\"success\":true,\"duration_ms\":$((100 + RANDOM % 1000))}" | \
                docker exec -i kafka kafka-console-producer --bootstrap-server localhost:9092 --topic api-usage-events > /dev/null 2>&1
            echo "✅ API Event $i"
            ;;
        1)
            # Tool Execution
            echo "{\"event_id\":\"auto-$i\",\"event_type\":\"tool_execution\",\"timestamp\":\"$TIMESTAMP\",\"tool_name\":\"chat\",\"provider\":\"saia\",\"model\":\"qwq-32b\",\"duration_ms\":$((500 + RANDOM % 2000)),\"success\":true,\"input_tokens\":100,\"output_tokens\":200}" | \
                docker exec -i kafka kafka-console-producer --bootstrap-server localhost:9092 --topic tool-execution-events > /dev/null 2>&1
            echo "🔧 Tool Event $i"
            ;;
        2)
            # Session
            START=$(date -d '5 min ago' -u +%Y-%m-%dT%H:%M:%SZ)
            echo "{\"event_id\":\"auto-$i\",\"event_type\":\"session_lifecycle\",\"timestamp\":\"$TIMESTAMP\",\"session_id\":\"session-$((i % 5))\",\"session_start\":\"$START\",\"session_end\":\"$TIMESTAMP\",\"total_tokens\":1000,\"api_calls\":5,\"tool_calls\":3,\"success\":true}" | \
                docker exec -i kafka kafka-console-producer --bootstrap-server localhost:9092 --topic session-events > /dev/null 2>&1
            echo "📊 Session Event $i"
            ;;
        3)
            # Error
            echo "{\"event_id\":\"auto-$i\",\"event_type\":\"error\",\"timestamp\":\"$TIMESTAMP\",\"provider\":\"saia\",\"model\":\"qwq-32b\",\"tool_name\":\"chat\",\"error_code\":\"TIMEOUT\",\"error_message\":\"Request timeout\"}" | \
                docker exec -i kafka kafka-console-producer --bootstrap-server localhost:9092 --topic error-events > /dev/null 2>&1
            echo "❌ Error Event $i"
            ;;
    esac
done

echo "Done! Check dashboard at http://localhost:8081"
