import { WebSocketServer, WebSocket } from 'ws';
import { IncomingMessage } from 'http';
import { URL } from 'url';
import { UserAuthService } from '../services/UserAuthService';
import { setWsPushCallback } from '../services/ChatService';

const HEARTBEAT_INTERVAL_MS = 60000;

interface ClientInfo {
  ws: WebSocket;
  userId: string;
  isAlive: boolean;
  lastPing: number;
}

const connectionManager = new Map<string, Set<WebSocket>>();
const clientInfoMap = new WeakMap<WebSocket, ClientInfo>();

let wss: WebSocketServer;
let heartbeatTimer: NodeJS.Timeout | null = null;

function addConnection(userId: string, ws: WebSocket): void {
  if (!connectionManager.has(userId)) {
    connectionManager.set(userId, new Set());
  }
  connectionManager.get(userId)!.add(ws);
}

function removeConnection(userId: string, ws: WebSocket): void {
  const conns = connectionManager.get(userId);
  if (conns) {
    conns.delete(ws);
    if (conns.size === 0) {
      connectionManager.delete(userId);
    }
  }
}

function pushToUser(userId: string, type: string, data: Record<string, string | number | object>): void {
  const conns = connectionManager.get(userId);
  if (!conns || conns.size === 0) return;

  const message = JSON.stringify({ type, data });
  conns.forEach((ws) => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(message);
    }
  });
}

function heartbeatCheck(): void {
  connectionManager.forEach((conns: Set<WebSocket>, userId: string) => {
    conns.forEach((ws: WebSocket) => {
      const info = clientInfoMap.get(ws);
      if (!info) return;
      if (!info.isAlive) {
        console.log(`[Chat:WS] 心跳超时，断开连接: 用户 ${userId}`);
        ws.terminate();
        return;
      }
      info.isAlive = false;
    });
  });
}

export function initWsChatServer(server: import('http').Server): void {
  wss = new WebSocketServer({ server, path: '/ws/chat' });

  wss.on('connection', (ws: WebSocket, req: IncomingMessage) => {
    let token = '';
    try {
      const url = new URL(req.url || '', `http://${req.headers.host}`);
      token = url.searchParams.get('token') || '';
    } catch {
      ws.close(4001, 'Invalid connection URL');
      return;
    }

    if (!token) {
      ws.close(4001, 'Token required');
      return;
    }

    const decoded = UserAuthService.verifyAccessToken(token);
    if (!decoded) {
      ws.close(4001, 'Token invalid or expired');
      return;
    }

    const userId = decoded.userId;
    addConnection(userId, ws);

    clientInfoMap.set(ws, {
      ws,
      userId,
      isAlive: true,
      lastPing: Date.now(),
    });

    console.log(`[Chat:WS] 用户 ${userId} 已连接，当前在线: ${connectionManager.size}`);

    ws.on('pong', () => {
      const info = clientInfoMap.get(ws);
      if (info) {
        info.isAlive = true;
        info.lastPing = Date.now();
      }
    });

    ws.on('message', (raw: import('ws').RawData) => {
      try {
        const msg = JSON.parse(raw.toString());
        if (msg.type === 'ping') {
          ws.send(JSON.stringify({ type: 'pong' }));
          const info = clientInfoMap.get(ws);
          if (info) {
            info.isAlive = true;
            info.lastPing = Date.now();
          }
        } else if (msg.type === 'mark_read') {
          console.log(`[Chat:WS] 用户 ${userId} 标记已读: ${msg.conversationId}`);
        }
      } catch {
        // ignore malformed messages
      }
    });

    ws.on('close', () => {
      removeConnection(userId, ws);
      clientInfoMap.delete(ws);
      console.log(`[Chat:WS] 用户 ${userId} 已断开，当前在线: ${connectionManager.size}`);
    });

    ws.on('error', (err) => {
      console.error(`[Chat:WS] 连接错误: 用户 ${userId}`, err.message);
      removeConnection(userId, ws);
      clientInfoMap.delete(ws);
    });
  });

  heartbeatTimer = setInterval(heartbeatCheck, HEARTBEAT_INTERVAL_MS);

  wss.on('close', () => {
    if (heartbeatTimer) {
      clearInterval(heartbeatTimer);
      heartbeatTimer = null;
    }
  });

  setWsPushCallback(pushToUser);

  console.log('[Chat:WS] WebSocket服务已启动，路径: /ws/chat');
}

export function getOnlineUserCount(): number {
  return connectionManager.size;
}

export function isUserOnline(userId: string): boolean {
  const conns = connectionManager.get(userId);
  return !!conns && conns.size > 0;
}