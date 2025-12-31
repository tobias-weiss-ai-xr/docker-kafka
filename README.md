# Docker Kafka

Docker Compose setup for Apache Kafka with Zookeeper, including automatic topic creation and Kafka UI.

## Features

- **Kafka 7.4.0** - Latest Confluent Platform distribution
- **Zookeeper** - Required for Kafka coordination
- **Auto-created Topics** - PAL MCP API topics created on startup
- **Kafka UI** - Web interface at http://localhost:8080
- **Data Persistence** - Docker volumes for data retention
- **Health Checks** - Ensures services are ready before use

## Quick Start

```bash
# Start all services
make up

# Or with docker-compose directly
docker-compose up -d

# Check status
make ps

# View logs
make logs

# Stop services
make down
```

## Services

### Kafka Broker
- **Port**: 9092
- **Connection**: `localhost:9092`
- **Auto-created Topics**:
  - `api-usage-events` (3 partitions)
  - `tool-execution-events` (3 partitions)
  - `session-events` (3 partitions)
  - `error-events` (3 partitions)

### Kafka UI
- **URL**: http://localhost:8080
- **Features**: Browse topics, view messages, consumer lag monitoring

### Zookeeper
- **Port**: 2181
- **Admin Server**: Disabled (port conflict avoidance)

## Environment Variables

### Dashboard Server
```bash
export KAFKA_ENABLED=true
export KAFKA_BROKERS=localhost:9092
```

### PAL MCP Server
```bash
export KAFKA_ENABLED=true
export KAFKA_BROKERS=localhost:9092
export KAFKA_API_TOPIC=api-usage-events
export KAFKA_TOOL_TOPIC=tool-execution-events
export KAFKA_SESSION_TOPIC=session-events
export KAFKA_ERROR_TOPIC=error-events
```

## Commands

### Start Kafka
```bash
docker-compose up -d
```

### Stop Kafka
```bash
docker-compose down
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f kafka
```

### List Topics
```bash
docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9092
```

### Create Topic
```bash
docker exec -it kafka kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1 \
  --topic my-topic
```

### Delete Topic
```bash
docker exec -it kafka kafka-topics --delete \
  --bootstrap-server localhost:9092 \
  --topic my-topic
```

### Consume Messages
```bash
docker exec -it kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic api-usage-events \
  --from-beginning
```

### Produce Test Message
```bash
docker exec -it kafka kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic api-usage-events
# Then type messages and press Ctrl+C to exit
```

## Data Persistence

Data is stored in Docker volumes:
- `zookeeper-data` - Zookeeper data
- `zookeeper-logs` - Zookeeper logs
- `kafka-data` - Kafka log segments

To completely reset:
```bash
docker-compose down -v
docker-compose up -d
```

## Troubleshooting

### Kafka not starting
```bash
# Check logs
docker-compose logs kafka

# Restart
docker-compose restart kafka
```

### Port conflicts
If port 9092 is in use, edit `docker-compose.yml` and change the port mapping.

### Connection issues
- Ensure `localhost:9092` is accessible from your application
- For Docker networking, use service name `kafka:9092`
- Check firewall settings

### Topics not auto-creating
```bash
# Check init logs
docker-compose logs kafka-init

# Manually create topics
make topics
```

## Integration with PAL MCP API

The topics are automatically configured for the PAL MCP API:

1. **api-usage-events** - API call tracking
2. **tool-execution-events** - Tool usage metrics
3. **session-events** - Session lifecycle
4. **error-events** - Error tracking

The dashboard at http://localhost:8081 will automatically display events when:
1. Kafka is running
2. Dashboard server started with `KAFKA_ENABLED=true`
3. PAL server is processing requests

## Monitoring

### Kafka UI
Visit http://localhost:8080 for:
- Topic browser
- Message viewer
- Consumer group monitoring
- Broker metrics

### CLI Monitoring
```bash
# Consumer groups
docker exec -it kafka kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --list

# Topic details
docker exec -it kafka kafka-topics \
  --describe \
  --bootstrap-server localhost:9092 \
  --topic api-usage-events
```

## License

MIT

## Author

Created for PAL MCP API Dashboard integration
