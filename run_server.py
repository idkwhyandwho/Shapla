# run_server.py
import sys
from playwright_mcp import main

# We need to manually craft the sys.argv to include the --port argument
# The first element of sys.argv is the script name.
sys.argv = ['run_server.py', '--port', '65432']

print("Attempting to start Playwright MCP server...")
main()
print("Server script finished.")
