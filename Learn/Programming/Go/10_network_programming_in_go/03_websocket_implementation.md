## WebSocket Implementation


WebSockets enable full-duplex communication between client and server, ideal for real-time applications.

**WebSocket Server:**

```go
type Hub struct {
    clients    map[*Client]bool
    broadcast  chan []byte
    register   chan *Client
    unregister chan *Client
    mu         sync.RWMutex
}

type Client struct {
    hub  *Hub
    conn *websocket.Conn
    send chan []byte
    id   string
}

func NewHub() *Hub {
    return &Hub{
        clients:    make(map[*Client]bool),
        broadcast:  make(chan []byte),
        register:   make(chan *Client),
        unregister: make(chan *Client),
    }
}

func (h *Hub) Run() {
    for {
        select {
        case client := <-h.register:
            h.mu.Lock()
            h.clients[client] = true
            h.mu.Unlock()
            
            log.Printf("Client %s connected. Total clients: %d", client.id, len(h.clients))
            
        case client := <-h.unregister:
            h.mu.Lock()
            if _, ok := h.clients[client]; ok {
                delete(h.clients, client)
                close(client.send)
                log.Printf("Client %s disconnected. Total clients: %d", client.id, len(h.clients))
            }
            h.mu.Unlock()
            
        case message := <-h.broadcast:
            h.mu.RLock()
            for client := range h.clients {
                select {
                case client.send <- message:
                default:
                    delete(h.clients, client)
                    close(client.send)
                }
            }
            h.mu.RUnlock()
        }
    }
}

var upgrader = websocket.Upgrader{
    CheckOrigin: func(r *http.Request) bool {
        return true // Allow all origins in development
    },
}

func (h *Hub) HandleWebSocket(w http.ResponseWriter, r *http.Request) {
    conn, err := upgrader.Upgrade(w, r, nil)
    if err != nil {
        log.Printf("WebSocket upgrade failed: %v", err)
        return
    }
    
    clientID := r.Header.Get("X-Client-Id")
    if clientID == "" {
        clientID = generateClientID()
    }
    
    client := &Client{
        hub:  h,
        conn: conn,
        send: make(chan []byte, 256),
        id:   clientID,
    }
    
    h.register <- client
    
    go client.writePump()
    go client.readPump()
}

func (c *Client) readPump() {
    defer func() {
        c.hub.unregister <- c
        c.conn.Close()
    }()
    
    c.conn.SetReadLimit(512)
    c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
    c.conn.SetPongHandler(func(string) error {
        c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
        return nil
    })
    
    for {
        _, message, err := c.conn.ReadMessage()
        if err != nil {
            if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
                log.Printf("WebSocket error: %v", err)
            }
            break
        }
        
        // Broadcast message to all clients
        c.hub.broadcast <- message
    }
}

func (c *Client) writePump() {
    ticker := time.NewTicker(54 * time.Second)
    defer func() {
        ticker.Stop()
        c.conn.Close()
    }()
    
    for {
        select {
        case message, ok := <-c.send:
            c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
            if !ok {
                c.conn.WriteMessage(websocket.CloseMessage, []byte{})
                return
            }
            
            if err := c.conn.WriteMessage(websocket.TextMessage, message); err != nil {
                log.Printf("Write error: %v", err)
                return
            }
            
        case <-ticker.C:
            c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
            if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
                return
            }
        }
    }
}
```

**WebSocket Client:**

```go
type WSClient struct {
    conn   *websocket.Conn
    url    string
    header http.Header
    done   chan struct{}
    send   chan []byte
}

func NewWSClient(url string, header http.Header) *WSClient {
    return &WSClient{
        url:    url,
        header: header,
        done:   make(chan struct{}),
        send:   make(chan []byte, 256),
    }
}

func (c *WSClient) Connect(ctx context.Context) error {
    dialer := websocket.DefaultDialer
    dialer.HandshakeTimeout = 10 * time.Second
    
    conn, _, err := dialer.DialContext(ctx, c.url, c.header)
    if err != nil {
        return fmt.Errorf("failed to connect: %w", err)
    }
    
    c.conn = conn
    
    go c.readMessages()
    go c.writeMessages()
    
    return nil
}

func (c *WSClient) SendMessage(message []byte) error {
    select {
    case c.send <- message:
        return nil
    case <-c.done:
        return fmt.Errorf("client is closed")
    }
}

func (c *WSClient) readMessages() {
    defer close(c.done)
    
    for {
        _, message, err := c.conn.ReadMessage()
        if err != nil {
            if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
                log.Printf("WebSocket read error: %v", err)
            }
            break
        }
        
        log.Printf("Received: %s", message)
    }
}

func (c *WSClient) writeMessages() {
    ticker := time.NewTicker(54 * time.Second)
    defer ticker.Stop()
    
    for {
        select {
        case message := <-c.send:
            c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
            if err := c.conn.WriteMessage(websocket.TextMessage, message); err != nil {
                log.Printf("Write error: %v", err)
                return
            }
            
        case <-ticker.C:
            c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
            if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
                return
            }
            
        case <-c.done:
            return
        }
    }
}
```

