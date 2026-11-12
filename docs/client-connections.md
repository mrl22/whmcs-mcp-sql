# Connect Codex, Claude and ChatGPT

Connection requirements checked against official documentation on 12 November 2026. The examples target the implemented `whmcs-mcp-sql:local` image. No client settings have been changed automatically. The HTTP endpoint is `/mcp`, using Streamable HTTP; no MCP login or OAuth is enabled in this development release.

Start the service first:

```sh
docker compose up -d --build --wait
curl http://127.0.0.1:3100/ready
```

`/ready` should return `{"status":"ready"}`. Keep Docker running for local connections. Cloud connections require a reachable endpoint or supported outbound tunnel; a cloud service cannot access your computer's `127.0.0.1`.

## Codex

For a local HTTP connection, add this to `~/.codex/config.toml`:

```toml
[mcp_servers.whmcs]
url = "http://127.0.0.1:3100/mcp"
```

Reload Codex so it discovers the server. Ask it to call `get_capabilities`, then `describe_schema`. A useful first request is: “Show the number of active clients and services. Keep currencies separate for any financial figures.”

Alternatively, let Codex launch its own stdio container. Use this **instead of** the URL entry, substituting the absolute path to your environment file:

```toml
[mcp_servers.whmcs]
command = "docker"
args = ["run", "--rm", "-i", "--no-healthcheck", "--read-only", "--cap-drop=ALL", "--security-opt=no-new-privileges", "--add-host=host.docker.internal:host-gateway", "--env-file", "/absolute/path/to/whmcs-mcp-sql/.env", "-e", "MCP_TRANSPORT=stdio", "whmcs-mcp-sql:local"]
```

Build the image with `docker compose build` first. Use `-i` and omit a TTY (`-t`). The environment file contains database settings; the explicit `MCP_TRANSPORT=stdio` overrides its HTTP setting. HTTP does not need to be running for this stdio option. For remote HTTP, replace the local URL with its reachable HTTPS `/mcp` URL and add that hostname to `MCP_ALLOWED_HOSTS`.

Source: [Official Codex MCP documentation](https://learn.chatgpt.com/docs/extend/mcp?surface=cli).

## Claude Desktop: local stdio

Open Claude Desktop's developer MCP configuration. On macOS the usual file is `~/Library/Application Support/Claude/claude_desktop_config.json`; on Windows it is `%APPDATA%\Claude\claude_desktop_config.json`. Merge this entry with any existing `mcpServers` object:

```json
{
  "mcpServers": {
    "whmcs": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "--no-healthcheck",
        "--read-only",
        "--cap-drop=ALL",
        "--security-opt=no-new-privileges",
        "--add-host=host.docker.internal:host-gateway",
        "--env-file",
        "/absolute/path/to/whmcs-mcp-sql/.env",
        "-e",
        "MCP_TRANSPORT=stdio",
        "whmcs-mcp-sql:local"
      ]
    }
  }
}
```

Build the image and replace the environment-file path. Restart Claude Desktop, enable WHMCS tools in the conversation if required, then ask for `get_capabilities`. If Claude cannot locate `docker`, use its absolute executable path (`command -v docker` on macOS/Linux). This local option needs no public endpoint.

## Claude Code

With HTTP running:

```sh
claude mcp add --transport http whmcs http://127.0.0.1:3100/mcp
```

Use `/mcp` in Claude Code to inspect status. Use the deployed HTTPS URL for a remote service. Claude Code can also launch Docker via `claude mcp add --transport stdio whmcs -- docker run ...`, using the Desktop Docker arguments.

Source: [Official Claude Code MCP guide](https://code.claude.com/docs/en/mcp).

## Claude web / Desktop remote connectors

1. Deploy HTTP at a URL reachable from Anthropic's cloud.
2. Add its hostname to `MCP_ALLOWED_HOSTS` and restart the server.
3. In Claude, open **Customize → Connectors → Add a custom web connector**.
4. Enter a name and the HTTPS `/mcp` URL.
5. Review authentication and choose **No sign in** for this development service.
6. Finish setup, enable the connector, and ask for `get_capabilities`.

Remote requests originate from Anthropic's cloud, including in Claude Desktop. A LAN/VPN-only URL on the staff member's computer is insufficient for this connection type; local Desktop stdio is separate. Account/workspace permissions can control connector availability.

Source: [Official Claude remote connector guide](https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp).

## ChatGPT

### Direct server URL

1. Make the HTTP `/mcp` endpoint reachable from OpenAI through HTTPS.
2. Add the external hostname to `MCP_ALLOWED_HOSTS` and restart the service.
3. In ChatGPT, open **Plugins → Add custom MCP server**.
4. Choose a server URL and enter the complete HTTPS `/mcp` endpoint.
5. Select **No authentication**.
6. Finish adding and install the resulting personal/workspace plugin.
7. Invoke it using `@` and ask for `get_capabilities`.

Use the current custom-MCP setup in your account; workspace policy may restrict adding/installing servers. This uses MCP, **not GPT Actions**.

### Private-network connection with Secure MCP Tunnel

ChatGPT also supports an outbound Secure MCP Tunnel, forwarding to a local HTTP or stdio service without opening an inbound public endpoint. It requires appropriate tunnel access and association with the intended ChatGPT workspace.

Follow the official tunnel setup to install/authenticate the current `tunnel-client`, register the tunnel, and forward to `http://127.0.0.1:3100/mcp`. In custom MCP setup choose **Tunnel**, select the registered tunnel, and install the resulting plugin. Keep Docker and the tunnel client running. This deployment-side component installs nothing in WHMCS. Use official commands for your workspace rather than an unverified tunnel ID or authentication command.

Sources: [Official custom MCP setup](https://developers.openai.com/api/docs/guides/custom-mcp-server), [Official MCP quickstart](https://developers.openai.com/plugins/build/app-quickstart), [Official Secure MCP Tunnel guide](https://developers.openai.com/api/docs/guides/secure-mcp-tunnels).

## HTTPS reverse proxy

For a proxy on the same host, forward to `http://127.0.0.1:3100`. For a Docker proxy, join the same network and forward to `http://whmcs-mcp-sql:3100`. Preserve the original Host header and add the external hostname to `MCP_ALLOWED_HOSTS`. If a browser client sends an Origin header, list its exact origin in `MCP_ALLOWED_ORIGINS`. Neither setting enables authentication.

Compose binds to localhost by default. Provide the required proxy/network/tunnel route for remote clients. Everyone who can reach this unauthenticated development endpoint receives the same permitted business-data access.

## Troubleshooting

| Symptom                      | Check                                                                                                                                             |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Database unreachable         | Use `host.docker.internal` for host MySQL, a Docker service name on a shared network, or the remote hostname. Container loopback is not the host. |
| Host rejected (403)          | Add the endpoint hostname, without scheme/port, to `MCP_ALLOWED_HOSTS`.                                                                           |
| Origin rejected (403)        | Add the exact trusted browser origin to `MCP_ALLOWED_ORIGINS`.                                                                                    |
| Cloud cannot reach localhost | Use reachable HTTPS or ChatGPT's supported tunnel.                                                                                                |
| Stdio disconnects            | Build the image, use an absolute `.env` path, enable stdin with `-i`, omit `-t`, and keep Docker running.                                         |
| `FEATURE_UNAVAILABLE`        | Inspect `get_capabilities`; missing schema and SQL-only limitations are explicit. Restart after an import/schema change.                          |
| `COLUMN_UNAVAILABLE`         | Check `describe_schema`; hidden columns cannot be queried in any expression.                                                                      |
| Truncated results            | Reduce selected fields or paginate. Long text is deliberately bounded at source.                                                                  |

Run `npm run smoke` for HTTP or `SMOKE_STDIO=docker npm run smoke` for actual Docker stdio. Checks print summary counts, not customer records. They verify the server protocol; signing into each cloud client remains account-dependent.
