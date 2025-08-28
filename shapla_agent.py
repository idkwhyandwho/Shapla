import json
import requests
from ctransformers import AutoModelForCausalLM

# Configuration
MODEL_PATH = "Triangle104/SmolLM2-360M-Q4_K_M-GGUF"  # Replace with local path if downloaded
MCP_SERVERS = {
    "playwright": "http://localhost:8931",  # Default Playwright MCP port
    "sequential_thinking": "http://localhost:8081",
    "memory": "http://localhost:8082",
    "task_orchestrator": "http://localhost:8083",
}

# Load the SmolLM2 model
model = AutoModelForCausalLM.from_pretrained(MODEL_PATH, model_type="gguf")

# System prompt for reasoning
SYSTEM_PROMPT = """
You are a helpful AI agent. Respond directly to simple queries. For complex tasks requiring tools, output in the format:
ACTION: tool_name({"arg1": "value1", "arg2": "value2"})
Available tools: goto, click, fill, query_selector, screenshot (Playwright); sequentialthinking (Sequential Thinking); add_observations, create_entities, etc. (Memory); create_task, etc. (Task Orchestrator).
"""

def reason(user_input, context=""):
    """Use SmolLM2 to reason and decide on action or response."""
    prompt = f"{SYSTEM_PROMPT}\nContext: {context}\nUser: {user_input}\nAgent:"
    response = model(prompt, max_new_tokens=512, temperature=0.7)
    return response

def parse_action(response):
    """Parse if response is an ACTION, return tool, args else None."""
    if response.startswith("ACTION:"):
        action_str = response[len("ACTION:"):].strip()
        try:
            tool_name, args_str = action_str.split("(", 1)
            args_str = args_str.rstrip(")")
            args = json.loads(args_str)
            return tool_name.strip(), args
        except:
            return None, None
    return None, None

def call_mcp_tool(server_key, action, params):
    """Call MCP server via JSON-RPC."""
    server_url = MCP_SERVERS.get(server_key)
    if not server_url:
        raise ValueError(f"Unknown server: {server_key}")

    payload = {
        "jsonrpc": "2.0",
        "method": action,
        "params": params,
        "id": 1
    }
    response = requests.post(server_url, json=payload)
    if response.status_code == 200:
        result = response.json().get("result")
        return result
    else:
        raise Exception(f"Error calling {action}: {response.text}")

def determine_server(tool_name):
    """Map tool to MCP server."""
    if tool_name in ["goto", "click", "fill", "query_selector", "screenshot"]:
        return "playwright"
    elif tool_name == "sequentialthinking":
        return "sequential_thinking"
    elif tool_name in ["add_observations", "create_entities", "create_relations", "delete_entities", "delete_observations", "delete_relations", "open_nodes", "read_graph", "search_nodes"]:
        return "memory"
    else:
        return "task_orchestrator"  # Assume others are task orchestrator

def agent_loop(user_input):
    """Main Shapla agent loop: Reason -> Act -> Observe -> Respond."""
    context = ""
    while True:
        response = reason(user_input, context)
        tool, args = parse_action(response)

        if tool:
            # Act: Call tool
            server = determine_server(tool)
            try:
                observation = call_mcp_tool(server, tool, args)
                # Observe: Add to context
                context += f"\nObservation: {json.dumps(observation)}"
            except Exception as e:
                context += f"\nError: {str(e)}"
        else:
            # Respond: Direct answer
            return response

# Example usage
if __name__ == "__main__":
    user_query = input("Enter your query: ")
    result = agent_loop(user_query)
    print("Response:", result)
