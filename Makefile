.PHONY: help up down restart ps logs topics clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

up: ## Start Kafka and all services
	docker compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 10
	@echo "Kafka is ready at localhost:9092"
	@echo "Kafka UI available at http://localhost:8080"

down: ## Stop all services
	docker compose down

restart: down up ## Restart all services

ps: ## Show running containers
	docker compose ps

logs: ## Show logs from all services
	docker compose logs -f

logs-kafka: ## Show Kafka logs
	docker compose logs -f kafka

logs-zookeeper: ## Show Zookeeper logs
	docker compose logs -f zookeeper

topics: ## List all topics
	docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9092

create-topic: ## Create a new topic (usage: make create-topic TOPIC=name)
	docker exec -it kafka kafka-topics --create --if-not-exists \
		--bootstrap-server localhost:9092 \
		--partitions 3 \
		--replication-factor 1 \
		--topic $(TOPIC)

delete-topic: ## Delete a topic (usage: make delete-topic TOPIC=name)
	docker exec -it kafka kafka-topics --delete \
		--bootstrap-server localhost:9092 \
		--topic $(TOPIC)

describe-topic: ## Describe a topic (usage: make describe-topic TOPIC=name)
	docker exec -it kafka kafka-topics --describe \
		--bootstrap-server localhost:9092 \
		--topic $(TOPIC)

consume: ## Consume messages from a topic (usage: make consume TOPIC=api-usage-events)
	docker exec -it kafka kafka-console-consumer \
		--bootstrap-server localhost:9092 \
		--topic $(TOPIC) \
		--from-beginning

produce: ## Produce messages to a topic (usage: make produce TOPIC=api-usage-events)
	docker exec -it kafka kafka-console-producer \
		--bootstrap-server localhost:9092 \
		--topic $(TOPIC)

clean: down ## Remove all containers, volumes, and images
	docker compose down -v
	@echo "All Kafka data has been removed"

reset: clean up ## Reset Kafka (delete all data and restart)
