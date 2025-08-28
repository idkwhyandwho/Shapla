# AGENTS.md - Shapla AI Agent System

## Project Overview

Shapla defines **lightweight autonomous AI agents** that combine compact reasoning models with external tools via MCP (Model Context Protocol) servers. Each agent follows the core loop: **Reason → Act → Observe → Respond**.

The system uses SmolLM2 for reasoning and integrates various MCP servers for capabilities like browser automation, memory management, sequential thinking, and task orchestration.

### Core Components
- **🧠 SmolLM2 Reasoning Agent**: [`Triangle104/SmolLM2-360M-Q4_K_M-GGUF`](https://huggingface.co/Triangle104/SmolLM2-360M-Q4_K_M-GGUF) (~271 MB quantized model)
- **🌐 Playwright MCP Server**: Browser automation and web browsing via JSON-RPC
- **💡 Sequential Thinking MCP Server**: Dynamic problem-solving through thought sequences
- **🧠 Memory MCP Server**: Knowledge graph-based persistent memory system
- **⚙️ Task Orchestrator MCP Server**: Comprehensive task and feature management
- **Web Frontend**: Vue 3 + TypeScript chat interface (optional)
- **Backend Server**: FastAPI orchestration layer (optional)
- **Sandbox Environment**: Docker-based isolated execution (optional)

### Agent Loop Architecture
```
User Input → SmolLM2 Reasoning → ACTION: tool() → MCP Server → Observation → Response
```

### Runtime Options
- **Standalone**: Direct Python execution with `shapla_agent.py`
- **Web Application**: Full FastAPI + Vue.js deployment
- **Container**: Docker-based deployment with all services

## Quick Start

### Standalone Agent (Minimal)
```bash
# Setup SmolLM2 environment
python -m venv shapla_env
source shapla_env/bin/activate  # or shapla_env\Scripts\activate on Windows
pip install ctransformers requests

# Download SmolLM2 model (if not auto-downloaded)
# Model: Triangle104/SmolLM2-360M-Q4_K_M-GGUF (~271 MB)

# Start MCP servers (Docker)
docker run -d -p 8080:80 --name playwright-mcp playwright-mcp
docker run -d -p 8081:80 --name memory-mcp mcp/memory
docker run -d -p 8082:80 --name sequential-thinking-mcp mcp/sequentialthinking

# Run standalone agent
python shapla_agent.py
```

### Full Web Application
```bash
# Clone and setup
git clone <repository>
cd shapla

# Start all services in development mode
docker-compose up --build

# Access points:
# - Frontend: http://localhost:5173
# - Backend API: http://localhost:8000
# - Sandbox API: http://localhost:8080
# - VNC: http://localhost:5900
```

### Production Deployment
```bash
# Minimal deployment (SmolLM2 + MCP servers)
docker-compose -f docker-compose.prod.yml up

# Or standalone agent only
python shapla_agent.py
```

## Build and Test Commands

### Frontend (web/)
```bash
cd web/
npm install
npm run dev          # Development server
npm run build        # Production build
npm run preview      # Preview build
npm run type-check   # TypeScript checking
```

### Backend (backend/)
```bash
cd backend/
pip install -r requirements.txt
python -m pytest                    # Run tests
python -m pytest --cov=app         # With coverage
uvicorn app.main:app --reload       # Development server
./run.sh                            # Production server
```

### Sandbox (sandbox/)
```bash
cd sandbox/
pip install -r requirements.txt
python -m pytest                    # Run tests
uvicorn app.main:app --host 0.0.0.0 --port 8080  # Development
```

### SmolLM2 Agent Testing
```bash
# Test standalone agent with SmolLM2
cd shapla/
python shapla_agent.py

# Example interactions:
# User: "What is the content of https://example.com?"
# Agent: ACTION: goto("https://example.com")
# MCP: [webpage content response]
# Agent: [natural language summary]

# Test with memory
# User: "Remember that I like Python programming"
# Agent: ACTION: create_entities([{"name": "User", "observations": ["likes Python programming"]}])

# Test sequential thinking
# User: "Help me plan a complex project step by step"
# Agent: ACTION: sequentialthinking("First, let me break down the project requirements...", True, 1, 5, 0, "", False, 0, True)
```

## Code Style Guidelines

### Python (Backend & Sandbox)
- **Formatter**: Black (line length: 88)
- **Linter**: Ruff with FastAPI-specific rules
- **Type Hints**: Required for all public functions
- **Docstrings**: Google style for classes and public methods
- **Import Order**: isort with black profile

```python
# Example function signature
async def create_session(
    session_data: SessionCreate,
    db: Database = Depends(get_database)
) -> SessionResponse:
    """Create a new conversation session.
    
    Args:
        session_data: Session creation parameters
        db: Database dependency injection
        
    Returns:
        Created session with ID and metadata
        
    Raises:
        ValidationError: If session_data is invalid
    """
```

### SmolLM2 Integration
- **Model Loading**: Use `ctransformers` or `llama.cpp` for GGUF model loading
- **Inference**: CPU-optimized quantized model (Q4_K_M format)
- **Context Window**: Efficient context management for multi-turn conversations
- **Action Parsing**: SmolLM2 generates `ACTION: tool_name(args)` format for tool calls
- **Response Format**: Plain text for final answers, structured for intermediate steps

```python
# Example SmolLM2 integration
from ctransformers import AutoModelForCausalLM

model = AutoModelForCausalLM.from_pretrained(
    "Triangle104/SmolLM2-360M-Q4_K_M-GGUF",
    model_file="smollm2-360m-q4_k_m.gguf",
    model_type="llama"
)

# System prompt structure
SYSTEM_PROMPT = """You are a helpful AI agent. When you need to use tools, format actions as:
ACTION: tool_name(arguments)

Available tools:
- goto(url): Navigate to webpage  
- click(selector): Click element
- fill(selector, text): Fill form field
- create_entities(entities): Store in memory
- sequentialthinking(thought, ...): Multi-step reasoning
"""
```

## MCP Server Integration

### Available MCP Servers
1. **🌐 Playwright MCP Server** - Browser automation
2. **💡 Sequential Thinking MCP Server** - Multi-step reasoning
3. **🧠 Memory MCP Server** - Knowledge graph memory
4. **⚙️ Task Orchestrator MCP Server** - Project management
5. **📁 Filesystem MCP Server** - File operations (optional)
6. **🌐 Fetch MCP Server** - Web content fetching (optional)

### MCP Server Configuration
```python
# shapla_agent.py MCP server registry
MCP_SERVERS = {
    "playwright": {
        "port": 8080,
        "actions": ["goto", "click", "fill", "screenshot", "query_selector"]
    },
    "memory": {
        "port": 8081, 
        "actions": ["create_entities", "read_graph", "search_nodes", "add_observations"]
    },
    "sequential_thinking": {
        "port": 8082,
        "actions": ["sequentialthinking"]
    }
}
```

### Action Format Conventions
- **Tool Invocation**: `ACTION: tool_name(arg1, arg2, ...)`
- **JSON-RPC**: All MCP communication uses JSON-RPC 2.0 protocol
- **Response Handling**: Tool responses become observations for next reasoning step
- **Error Handling**: Failed tool calls generate error observations for SmolLM2

## Testing Instructions

### Unit Tests
```bash
# Backend unit tests
cd backend && python -m pytest tests/unit/

# Frontend unit tests  
cd web && npm run test:unit

# Sandbox unit tests
cd sandbox && python -m pytest tests/
```

### Integration Tests
```bash
# Full system integration
docker-compose -f docker-compose.test.yml up --abort-on-container-exit

# API integration tests
python -m pytest tests/integration/api/

# MCP server integration
python -m pytest tests/integration/mcp/
```

### E2E Tests
```bash
# Playwright E2E tests
cd web && npm run test:e2e

# Manual testing checklist:
# 1. Create new session via PUT /api/v1/sessions
# 2. Send chat message and verify SSE stream
# 3. Test tool invocation (browser, shell, file)
# 4. Verify VNC connection works
# 5. Test session persistence after restart
```

## Security Considerations

### Sandbox Security
- **Isolation**: Each session runs in separate Docker container
- **Resource Limits**: CPU/memory limits enforced via Docker
- **Network**: Restricted outbound access, no inbound except API
- **File System**: Read-only base image, writable temp directories only
- **Process Management**: Supervisor manages all sandbox processes

### API Security
- **Input Validation**: Pydantic schemas for all endpoints
- **Path Traversal**: Absolute path validation for file operations
- **Command Injection**: Shell command sanitization required
- **Rate Limiting**: TODO - implement per-session rate limits
- **CORS**: Configurable origins via ORIGINS environment variable

### MCP Server Security
- **Sandboxing**: MCP servers run in isolated containers
- **Permissions**: Minimal required permissions only
- **Validation**: All MCP responses validated before processing
- **Timeouts**: Service timeout configuration prevents resource exhaustion

## Development Guidelines

### Commit Messages
```
type(scope): brief description

feat(api): add session timeout management
fix(sandbox): resolve VNC connection drops
docs(agents): update MCP server integration guide
test(backend): add unit tests for session service
```

### Pull Request Guidelines
1. **Branch Naming**: `feature/description`, `fix/description`, `docs/description`
2. **PR Description**: Include testing steps and breaking changes
3. **Code Review**: Require approval for backend/security changes
4. **CI/CD**: All tests must pass before merge

### Adding New Tools
1. **Define Interface**: Add tool interface in `domain/external/`
2. **Implement Logic**: Create implementation in `infrastructure/`
3. **Register Tool**: Add to tool registry in `application/services/`
4. **Add Tests**: Unit tests for logic, integration tests for end-to-end
5. **Update Docs**: Add tool documentation and examples

### MCP Server Development
```python
# Example MCP server registration
MCP_SERVERS = {
    "browser": {
        "command": "python",
        "args": ["-m", "playwright_mcp"],
        "env": {"PLAYWRIGHT_BROWSERS_PATH": "/browsers"}
    },
    "custom_tool": {
        "command": "python", 
        "args": ["-m", "custom_mcp_server"],
        "env": {"CUSTOM_CONFIG": "/config"}
    }
}
```

## Environment Configuration

### Required Environment Variables
```bash
# SmolLM2 Configuration
MODEL_PATH=Triangle104/SmolLM2-360M-Q4_K_M-GGUF
MODEL_FILE=smollm2-360m-q4_k_m.gguf
MAX_TOKENS=512
TEMPERATURE=0.7

# MCP Server Configuration
MCP_PLAYWRIGHT_PORT=8080
MCP_MEMORY_PORT=8081  
MCP_SEQUENTIAL_THINKING_PORT=8082
MCP_TASK_ORCHESTRATOR_PORT=8083

# Optional Web Application
DATABASE_URL=mongodb://localhost:27017/shapla  # If using web interface
REDIS_URL=redis://localhost:6379              # If using web interface
LOG_LEVEL=INFO

# Docker Configuration (if using containers)
COMPOSE_PROJECT_NAME=shapla
DOCKER_BUILDKIT=1
```

### Development vs Production
- **Development**: SmolLM2 with debug logging, local MCP servers
- **Production**: Optimized model loading, containerized MCP servers, monitoring

## Deployment Steps

### Standalone Agent Deployment
1. **Environment Setup**: Python 3.9+ with `ctransformers`
2. **Model Download**: SmolLM2-360M-Q4_K_M-GGUF (~271 MB)
3. **MCP Servers**: Start required MCP servers via Docker
4. **Agent Launch**: `python shapla_agent.py`
5. **Testing**: Verify tool integration and reasoning loop

### Full Web Application Deployment
1. **Server Setup**: Ubuntu 20.04+ with Docker 20.10+
2. **Environment**: Copy `.env.production` and update values
3. **Build**: `docker-compose -f docker-compose.prod.yml build`
4. **Deploy**: `docker-compose -f docker-compose.prod.yml up -d`
5. **Health Check**: Verify SmolLM2 model loading and MCP server connectivity

### Scaling Considerations
- **Load Balancing**: Multiple backend instances behind nginx
- **Session Affinity**: Sticky sessions for WebSocket connections
- **Database**: MongoDB replica set for high availability
- **Caching**: Redis cluster for session data
- **Storage**: Persistent volumes for file operations

## Troubleshooting Common Issues

### SmolLM2 Model Issues
```bash
# Model download/loading issues
# Verify model file exists and is valid GGUF format
ls -la ~/.cache/huggingface/hub/

# Test model loading directly
python -c "from ctransformers import AutoModelForCausalLM; model = AutoModelForCausalLM.from_pretrained('Triangle104/SmolLM2-360M-Q4_K_M-GGUF')"

# Alternative: Use llama.cpp backend
pip install llama-cpp-python
```

### MCP Server Issues
```bash
# Check MCP server status
curl http://localhost:8080/health  # Playwright MCP
curl http://localhost:8081/health  # Memory MCP
curl http://localhost:8082/health  # Sequential Thinking MCP

# Test MCP server directly (JSON-RPC)
curl -X POST http://localhost:8080/jsonrpc \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"goto","params":{"url":"https://example.com"},"id":1}'

# Docker MCP server logs
docker logs playwright-mcp
docker logs memory-mcp
```

### Agent Loop Issues
```bash
# Debug action parsing
# Check if SmolLM2 generates proper ACTION: format
# Verify MCP server response parsing
# Test with simpler queries first

# Enable debug logging in shapla_agent.py
export LOG_LEVEL=DEBUG
python shapla_agent.py
```

## Performance Considerations

### SmolLM2 Optimization
- **Model Size**: 360M parameters, ~271 MB quantized (Q4_K_M)
- **CPU Inference**: Optimized for consumer hardware, no GPU required
- **Context Management**: Efficient token usage for multi-turn conversations
- **Batch Processing**: Process multiple actions in sequence efficiently
- **Memory Usage**: ~1-2GB RAM for model + conversation context

### MCP Server Optimization
- **Container Limits**: Set appropriate CPU/memory limits per MCP server
- **Connection Pooling**: Reuse JSON-RPC connections where possible
- **Response Caching**: Cache frequent tool responses (e.g., web content)
- **Concurrent Requests**: Handle multiple tool calls efficiently
- **Health Monitoring**: Regular health checks for MCP server availability

## Large Dataset Handling

### Chat History
- **Pagination**: Load messages in chunks
- **Compression**: Gzip large message payloads
- **Archival**: Move old sessions to cold storage
- **Search**: Full-text search via MongoDB indexes

### File Operations
- **Streaming**: Stream large file uploads/downloads
- **Chunking**: Process large files in chunks
- **Validation**: File size limits and type checking
- **Cleanup**: Automatic temp file removal

## Contributing

### Getting Started
1. Read this AGENTS.md file thoroughly
2. Set up development environment
3. Run existing tests to verify setup
4. Pick an issue labeled "good first issue"
5. Follow the PR guidelines above

### Code Review Process
- **Automated**: CI/CD runs linting, tests, security scans
- **Manual**: At least one reviewer for all changes
- **Documentation**: Update relevant docs with code changes
- **Testing**: Add tests for new features, maintain coverage

For questions or clarification on any of these guidelines, please open an issue or reach out to the maintainers.



### Approval of Simplified Approach for Running Shapla Agent

Yes, your proposed simplified approach to run shapla_agent.py as a standalone command-line script sounds correct and practical for achieving a minimal working demo. This aligns well with the goal of quickly validating the agent's core loop (Reason → Act → Observe → Respond) without the overhead of a full web application setup. By focusing on a local Python environment, you'll avoid the mismatches you've identified, such as the FastAPI dependencies and Docker port configurations, allowing faster iteration.

Key considerations for proceeding:
- **Virtual Environment Setup**: Use `venv` or `conda` to isolate dependencies, ensuring no conflicts with system Python packages.
- **Dependency Installation**: Run `pip install -r requirements.txt`, but note that extras like FastAPI can be ignored or removed if unused—focus on essentials like `ctransformers` and `requests`.
- **MCP Server Handling**: Start the Playwright MCP server manually (e.g., `python -m playwright_mcp`) and update the script's port if needed. For other MCP servers (e.g., Memory, Sequential Thinking), launch them via Docker individually if required, but start with just Playwright for the demo.
- **Script Corrections**: Adjust hardcoded ports in shapla_agent.py to match your local setup, and test with simple queries to verify tool calls.
- **Next Steps**: Once running, you can expand to integrate more MCP servers from the list (e.g., Memory for persistence). If scalability becomes a priority later, we can revisit FastAPI integration.

This method prioritizes simplicity while maintaining the agent's lightweight nature, as emphasized in the Shapla repository design.

---

The Shapla AI Agents framework, as outlined in the repository, emphasizes lightweight, autonomous components that leverage compact models like SmolLM2 with external tools via MCP servers. Your analysis correctly identifies key inconsistencies in the provided files: the Docker setup (docker-compose.yml and Dockerfile) is oriented toward a FastAPI-based web service, which includes API endpoints and Uvicorn for serving, but shapla_agent.py functions purely as a CLI script with no web server logic. This mismatch likely stems from an evolving project structure—perhaps an initial plan for a web-deployed agent that shifted to a simpler prototype. Unused dependencies in requirements.txt, such as FastAPI and Uvicorn, further support this, as they aren't imported or utilized in the script, potentially inflating the environment without benefit for a demo.

Approving the standalone approach is grounded in best practices for minimal viable products (MVPs) in AI agent development. For instance, many open-source AI frameworks, like LangChain or LlamaIndex, start with CLI prototypes for rapid testing before scaling to web apps. This allows isolated debugging of the agent's loop: reasoning with SmolLM2, parsing actions, calling MCP tools via JSON-RPC, and handling observations. By bypassing Docker initially, you eliminate complexities like network configurations (e.g., the script's hardcoded port 8080 not matching docker-compose services) and focus on core functionality.

To implement effectively:
- **Environment Setup**: Create a virtual environment with `python -m venv shapla_env` and activate it. Install dependencies via `pip install -r requirements.txt`, but consider a trimmed list (e.g., `ctransformers`, `requests`) to avoid bloat. If GPU support is needed for faster inference, ensure ctransformers is configured accordingly, though SmolLM2's small size (~271 MB) runs well on CPU.
- **MCP Server Launch**: For Playwright, install via `pip install playwright-mcp; playwright install chromium`, then run `python -m playwright_mcp --port=8080` (or adjust to match the script). For Docker-based servers like Memory or Sequential Thinking, pull images (e.g., `docker pull mcp/memory`) and run individually with `docker run -p 8082:80 mcp/memory`, mounting volumes for persistence if needed. The provided MCP server list (Everything, Fetch, Filesystem, Git, Memory, Sequential Thinking, Time) demonstrates protocol features, but for the demo, prioritize those used in the script (e.g., Playwright, Memory).
- **Script Execution and Testing**: Update MCP_SERVERS dict in shapla_agent.py if ports differ. Run with `python shapla_agent.py` and test queries like "What is the content of https://example.com?" to trigger a `goto` action. Monitor for errors in tool mapping or JSON parsing, and add logging if needed.
- **Potential Enhancements**: Incorporate XML-structured system prompts for better LLM guidance, as XML tags (e.g., <instructions>, <tools>) can improve parseability in models like SmolLM2. For example, refactor SYSTEM_PROMPT to use delimiters: `<system>You are a helpful agent.</system><tools>Available: goto, etc.</tools>`. This draws from practices in prompt engineering libraries like mdx-prompt, which enable composable JSX-based prompts, potentially useful if expanding to MDX queries for data analysis tasks.

If issues arise (e.g., model loading fails), fallback to llama.cpp for inference: compile it and run the script with bindings. Once the demo works, integration into FastAPI could involve wrapping the agent_loop in an API endpoint (e.g., `/agent/query`), exposing it via Uvicorn, and updating Docker to compose services properly—aligning ports and volumes.

#### MCP Servers Overview Table
| Server Name | Purpose | Runtime | Key Features | Installation Notes |
|-------------|---------|---------|--------------|--------------------|
| Everything | Reference/test server | Docker (mcp/everything) | Prompts, resources, tools demo | `docker run -p 8080:80 mcp/everything` |
| Fetch | Web content fetching | Docker (mcp/fetch) | Conversion for LLM efficiency | Supports URL-based fetches; integrate for web actions |
| Filesystem | Secure file operations | Docker (mcp/filesystem) | Access controls | Configurable paths; useful for local file tools |
| Git | Git repo manipulation | Docker (mcp/git) | Read, search, commit | Clone repos via params; enhances dev workflows |
| Memory | Knowledge graph memory | Docker (mcp/memory) | Persistent entities/relations | Actions like create_entities; core for long-term context |
| Sequential Thinking | Reflective problem-solving | Docker (mcp/sequentialthinking) | Thought sequences | Parameters for branching; aids complex reasoning |
| Time | Time/timezone conversions | Docker (mcp/time) | Date handling | Simple utils; low overhead for temporal tasks |

This table summarizes the servers you mentioned, based on official MCP documentation, ensuring a complete reference for extension.

Regarding system prompts with MDX and XML: While MDX (Multidimensional Expressions) is primarily an OLAP query language for data cubes (often serialized in XML via XMLA), its integration into LLM prompts is niche but feasible for analytical tasks. XML tagging in prompts enhances structure, as seen in advanced setups where tags delineate sections (e.g., <query>MDX SELECT...</query>). Tools like mdx-prompt allow JSX-composed prompts, blending React-like reusability with MDX data if querying cubes. In Shapla, this could refine the agent's prompt for better tool calls, especially if adding MDX-related servers for data viz.

Overall, this path minimizes blockers, enabling quick progress toward a functional demo while keeping options open for web integration later.
