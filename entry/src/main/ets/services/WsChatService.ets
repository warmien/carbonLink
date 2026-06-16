import { webSocket } from '@kit.NetworkKit';
import { AppConstants } from '../constants/AppConstants';
import { WsMessageType, WsConnectionState, WsMessage } from '../models/Message';
import { BusinessError } from '@kit.BasicServicesKit';

class WsChatServiceInner {
  private ws: webSocket.WebSocket | null = null;
  private state: WsConnectionState = WsConnectionState.DISCONNECTED;
  private pingTimer: number = -1;
  private reconnectTimer: number = -1;
  private reconnectIndex: number = 0;
  private missedPongs: number = 0;
  private token: string = '';
  private msgSeq: number = 0;
  private convSeq: number = 0;

  getState(): WsConnectionState {
    return this.state;
  }

  connect(token: string): void {
    if (this.state === WsConnectionState.CONNECTED || this.state === WsConnectionState.CONNECTING) {
      console.log('[WsChat] 已连接或正在连接，跳过');
      return;
    }

    this.token = token;
    this.setState(WsConnectionState.CONNECTING);

    try {
      this.ws = webSocket.createWebSocket();
      const url: string = `${AppConstants.WS_URL}?token=${token}`;

      this.ws.on('open', () => {
        console.log('[WsChat] WebSocket已连接');
        this.setState(WsConnectionState.CONNECTED);
        this.reconnectIndex = 0;
        this.missedPongs = 0;
        this.startPing();
      });

      this.ws.on('message', (err: BusinessError, data: string | ArrayBuffer) => {
        if (err) {
          console.error('[WsChat] 收到消息错误:', err.message);
          return;
        }
        if (typeof data === 'string') {
          this.handleMessage(data);
        }
      });

      this.ws.on('close', () => {
        console.log('[WsChat] WebSocket已关闭');
        this.stopPing();
        if (this.state !== WsConnectionState.DISCONNECTED) {
          this.scheduleReconnect();
        }
      });

      this.ws.on('error', (err: BusinessError) => {
        console.error('[WsChat] WebSocket错误:', err.message);
        this.stopPing();
        this.scheduleReconnect();
      });

      this.ws.connect(url);
    } catch (err) {
      console.error('[WsChat] 连接异常:', (err as Error).message);
      this.scheduleReconnect();
    }
  }

  disconnect(): void {
    this.setState(WsConnectionState.DISCONNECTED);
    this.stopPing();
    this.clearReconnect();

    if (this.ws) {
      try {
        this.ws.close();
      } catch (_e) {
        // ignore
      }
      this.ws = null;
    }
  }

  sendMarkRead(conversationId: string): void {
    if (this.state !== WsConnectionState.CONNECTED || !this.ws) {
      return;
    }
    try {
      const msg: Record<string, string> = {};
      msg['type'] = WsMessageType.MARK_READ;
      msg['conversationId'] = conversationId;
      this.ws.send(JSON.stringify(msg));
    } catch (err) {
      console.error('[WsChat] 发送mark_read失败:', (err as Error).message);
    }
  }

  private setState(newState: WsConnectionState): void {
    this.state = newState;
    AppStorage.setOrCreate('wsConnectionState', newState);
  }

  private startPing(): void {
    this.stopPing();
    this.pingTimer = setInterval(() => {
      if (this.state !== WsConnectionState.CONNECTED || !this.ws) {
        return;
      }
      try {
        const pingMsg: Record<string, string> = {};
        pingMsg['type'] = WsMessageType.PING;
        this.ws.send(JSON.stringify(pingMsg));
        this.missedPongs++;
        if (this.missedPongs >= 3) {
          console.log('[WsChat] 连续3次无pong响应，判定断连');
          this.stopPing();
          this.scheduleReconnect();
        }
      } catch (err) {
        console.error('[WsChat] ping发送失败:', (err as Error).message);
      }
    }, AppConstants.WS_PING_INTERVAL) as number;
  }

  private stopPing(): void {
    if (this.pingTimer !== -1) {
      clearInterval(this.pingTimer);
      this.pingTimer = -1;
    }
  }

  private handleMessage(raw: string): void {
    try {
      const msg: WsMessage = JSON.parse(raw) as WsMessage;

      if (msg.type === WsMessageType.PONG) {
        this.missedPongs = 0;
        return;
      }

      if (msg.type === WsMessageType.NEW_MESSAGE) {
        this.msgSeq++;
        const payload: Record<string, string | number | object> = {};
        payload['seq'] = this.msgSeq;
        if (msg.data !== null) {
          payload['data'] = msg.data;
        }
        AppStorage.setOrCreate('wsNewMessagePayload', JSON.stringify(payload));
        return;
      }

      if (msg.type === WsMessageType.CONVERSATION_UPDATE) {
        this.convSeq++;
        const payload: Record<string, string | number | object> = {};
        payload['seq'] = this.convSeq;
        if (msg.data !== null) {
          payload['data'] = msg.data;
        }
        AppStorage.setOrCreate('wsConvUpdatePayload', JSON.stringify(payload));
        return;
      }

      if (msg.type === WsMessageType.ERROR) {
        console.error(`[WsChat] 服务端错误: code=${msg.code}, message=${msg.message}`);
        return;
      }
    } catch (err) {
      console.error('[WsChat] 消息解析失败:', (err as Error).message);
    }
  }

  private scheduleReconnect(): void {
    if (this.state === WsConnectionState.DISCONNECTED) {
      return;
    }

    this.setState(WsConnectionState.RECONNECTING);
    this.clearReconnect();

    const delays: number[] = AppConstants.WS_RECONNECT_DELAYS;
    const delay: number = this.reconnectIndex < delays.length
      ? delays[this.reconnectIndex]
      : AppConstants.WS_MAX_RECONNECT_DELAY;

    console.log(`[WsChat] ${delay}ms后重连 (第${this.reconnectIndex + 1}次)`);
    this.reconnectIndex++;

    this.reconnectTimer = setTimeout(() => {
      if (this.ws) {
        try {
          this.ws.close();
        } catch (_e) {
          // ignore
        }
        this.ws = null;
      }
      this.connect(this.token);
    }, delay) as number;
  }

  private clearReconnect(): void {
    if (this.reconnectTimer !== -1) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = -1;
    }
  }
}

export const WsChatService = new WsChatServiceInner();
