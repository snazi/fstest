---
name: websockets-best-practices
description: "Realtime WebSocket and socket.io service implementation patterns including authentication, session lifecycle, bidirectional messaging, error handling, and reliability. Use when building or reviewing WebSocket connections, real-time communication services, or session management. Do not use for REST API or HTTP polling patterns."
---

## Authentication and Security

- Validate route authentication up front and fail closed.
- Use JWT for user-facing routes.
- Use digital signatures for internal routes.
- Keep Twilio signature validation for call modules.

## Session Lifecycle and Ownership

- Keep lifecycle ownership in session managers.
- Create or reuse a session before registering `message`, `error`, and `close` handlers.
- Always clean up frontend/model/Twilio sockets.

## Error Handling
- Use early returns for invalid payloads or invalid state transitions.
- Log persistence failures with metadata, but do not block WebSocket loops or crash sessions.

## Example

```typescript
// BAD
const msg = JSON.parse(data.toString());
ws.send(JSON.stringify(event));
await fetch(`${plannerBaseUrl}/api/v1/call/transcripts`, { method: "POST" });

// GOOD
const msg = parseMessage(data);
if (!msg || !isOpen(session.frontendConn)) return;
jsonSend(session.frontendConn, event);
await fetchWithHooks(`${plannerBaseUrl}/api/v1/call/transcripts`, { method: "POST" });
```
