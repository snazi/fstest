---
name: slack
description: "Slack MCP integration for searching conversations, posting messages, reading channel history, joining channels, and retrieving user profiles. Use when the user asks to send a Slack message, search Slack, read channel messages, check Slack threads, find Slack users, or interact with Slack in any way. Requires the slack MCP server to be active. Covers slack_list_channels, slack_join_channel, slack_post_message, slack_get_channel_history, slack_get_thread_replies, slack_search_messages, slack_list_users, and slack_get_user_profile. This skill does NOT cover email, calendar, or non-Slack messaging platforms."
---

# Slack MCP

> **PREREQUISITE:** The `slack` MCP server must be active (configured in `.mcp.json`).
> On first use, the agent will open a browser OAuth flow — sign in with your Slack account.

## Available Operations

| Tool | Description |
|------|-------------|
| `slack_list_channels` | List public channels in the workspace (supports pagination and filtering) |
| `slack_join_channel` | Join a public channel by name or ID |
| `slack_post_message` | Post a message to a channel |
| `slack_get_channel_history` | Retrieve recent messages from a channel |
| `slack_get_thread_replies` | Retrieve replies in a thread |
| `slack_search_messages` | Search messages across the workspace |
| `slack_list_users` | List workspace members with profile info |
| `slack_get_user_profile` | Get detailed profile for a specific user |

## Usage Notes

- Channel names may be passed with or without the `#` prefix.
- Call `slack_list_channels` first to resolve a channel name to its ID before calling `slack_join_channel`.
- Prefer `slack_search_messages` for context gathering before posting to a channel.
