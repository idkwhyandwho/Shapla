.PHONY: help setup run dev test clean docker-build docker-up docker-down

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Setup development environment
	@echo "Setting up Shapla development environment..."
	docker model pull ai/smollm3
	python -m venv venv
	source venv/bin/activate && pip install -r requirements.txt
	cp .env.example .env
	@echo "Setup complete! Edit .env with your configuration."

run: ## Run SmolLM3 model via Docker Model Runner
	@echo "Starting SmolLM3 via Docker Model Runner..."
	docker model run ai/smollm3

dev: ## Run development server
	@echo "Starting Shapla in development mode..."
	source venv/bin/activate && python shapla_agent.py

docker-build: ## Build Docker image
	docker build -t shapla-agent .

docker-up: ## Start all services with docker-compose
	docker-compose up -d

docker-down: ## Stop all services
	docker-compose down

docker-logs: ## View logs from all services
	docker-compose logs -f

test: ## Run tests
	@echo "Running tests..."
	python -m pytest tests/ -v

clean: ## Clean up temporary files
