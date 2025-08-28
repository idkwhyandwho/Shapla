This repository defines **Shapla AI Agents** — lightweight autonomous components that combine compact reasoning models with external tools.

Each agent follows the loop:

**Reason → Act → Observe → Respond**

* **Reason**: Interpret user intent with SmolLM2.
* **Act**: Call external tools via MCP servers.
* **Observe**: Capture tool responses.
* **Respond**: Return results to the user.

---

## Agents

### 🧠 SmolLM2 Reasoning Agent

* **Purpose**: Core reasoning engine for Shapla.
* **Model**: [`Triangle104/SmolLM2-360M-Q4_K_M-GGUF`](https://huggingface.co/Triangle104/SmolLM2-360M-Q4_K_M-GGUF) (\~271 MB, quantized GGUF).
* **Runtime**: Runs with [`ctransformers`](https://github.com/marella/ctransformers) or [`llama.cpp`](https://github.com/ggerganov/llama.cpp).
* **Input**: Natural language user queries.
* **Output**:

  * Direct natural language answers, or
  * Structured action directives, e.g.

    ```
    ACTION: goto("https://example.com")
    ```

---

### 🌐 Playwright MCP Server

* **Purpose**: Provides browser automation and web browsing capabilities.

* **Runtime**: MCP-compatible JSON-RPC server exposing [Playwright](https://playwright.dev/).

* **Installation**:

  ```bash
  pip install playwright-mcp
  playwright install chromium
  python -m playwright_mcp

Exposed Actions (examples):

goto(url: str) → Navigate to a webpage.

click(selector: str) → Click an element.

fill(selector: str, value: str) → Type text into a field.

query_selector(selector: str) → Get element content.

screenshot(path: str) → Save a screenshot.

Input: JSON action request.

Output: JSON response (success/error + result data).

💡 Sequential Thinking MCP Server

Purpose: Enables dynamic and reflective problem-solving through thought sequences.

Runtime: Docker container running the mcp/sequentialthinking image.

Installation: Requires Docker. The server is launched via Docker run commands.

Exposed Actions:

sequentialthinking(thought: str, next_thought_needed: bool, thought_number: int, total_thoughts: int, branch_from_thought: int, branch_id: str, is_revision: bool, revises_thought: int, needs_more_thoughts: bool) → Executes a single thought step in a sequential thinking process.

Input: JSON action request containing the parameters described below.

Output: JSON response containing the result of the thought step.

Parameters: (See detailed explanation at https://github.com/modelcontextprotocol/servers/blob/2025.4.6/src/sequentialthinking/Dockerfile)

🧠 Memory MCP Server

Purpose: Provides a knowledge graph-based persistent memory system.

Runtime: Docker container running the mcp/memory image.

Installation: Requires Docker. The server is launched via Docker run commands.

Exposed Actions:

add_observations(observations: list) → Add new observations to existing entities.

create_entities(entities: list) → Create new entities in the knowledge graph.

create_relations(relations: list) → Create new relations between entities.

delete_entities(entityNames: list) → Delete entities and their relations.

delete_observations(deletions: list) → Delete specific observations.

delete_relations(relations: list) → Delete relations.

open_nodes(names: list) → Open specific nodes in the graph.

read_graph() → Read the entire knowledge graph.

search_nodes(query: str) → Search for nodes based on a query.

Input: JSON action request containing the appropriate parameters for the chosen action.

Output: JSON response containing the result of the action.

⚙️ Task Orchestrator MCP Server

Purpose: Provides comprehensive task and feature management, enabling AI assistants to interact with project data in a structured, context-efficient way.

Runtime: Docker container running the ghcr.io/jpicklyk/task-orchestrator image.

Installation: Requires Docker. The server is launched via Docker run commands.

Exposed Actions: (See detailed documentation below)

Input: JSON action request containing the parameters for the chosen action.

Output: JSON response containing the result of the action.

(Detailed documentation for the Task Orchestrator MCP Server is included below - it's extensive due to the server's rich feature set.)

[The full documentation for the Task Orchestrator MCP Server is included in the previous response. It's too large to include directly in this markdown file, but it covers all available tools, parameters, and usage examples.]

Orchestration (Shapla Loop)
code
Mermaid
download
content_copy
expand_less
IGNORE_WHEN_COPYING_START
IGNORE_WHEN_COPYING_END
flowchart TD
    U[User Input] --> R[SmolLM2 Reasoning]
    R -->|Direct Answer| O[Output to User]
    R -->|ACTION| P[MCP Server (Playwright, Sequential Thinking, Memory, Task Orchestrator)]
    P --> Obs[Observation]
    Obs --> R
Conventions

Reasoning Agent uses the ACTION: prefix to indicate tool usage.

Tool Calls must be JSON objects with name and args.

Responses may be plain text (final answers) or JSON (intermediate observations).

Roadmap

Add memory/long-term context agent.

Integrate additional MCP servers (filesystem, OS commands, APIs).

Optionally upgrade reasoning to SmolLM3 for more complex tasks.

✅ This file helps Jules and teammates understand your agents, how they interact, and how to extend them.

Why is it safer to run MCP Servers?

Running MCP Servers within Docker containers provides several security benefits:

Isolation: Docker containers isolate the MCP server from the host system. This means that if the server is compromised, the attacker's access is limited to the container's environment, preventing them from directly accessing the host system's files or processes.

Resource Limits: Docker allows you to set resource limits (CPU, memory, disk I/O) for each container. This prevents a compromised server from consuming excessive resources and potentially causing a denial-of-service attack.

Reproducibility: Docker images are built from a Dockerfile, which defines the exact environment and dependencies required to run the server. This ensures that the server runs consistently across different environments, reducing the risk of unexpected behavior or vulnerabilities.

Regular Updates: Docker images can be easily updated to incorporate security patches and bug fixes. This allows you to quickly address vulnerabilities and keep your servers secure.

Least Privilege: You can run the Docker container with a non-root user, further limiting the potential impact of a compromise.

Network Control: Docker provides network isolation features, allowing you to control which ports are exposed and which networks the container can access. This reduces the attack surface and prevents unauthorized access.

Image Scanning: Docker Hub and other container registries offer image scanning services that can identify known vulnerabilities in the images you use.
