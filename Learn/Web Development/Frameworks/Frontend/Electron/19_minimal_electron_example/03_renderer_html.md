## Renderer HTML


```javascript
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self'">
  <title>Electron IPC Example</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      max-width: 600px;
      margin: 50px auto;
      padding: 20px;
    }
    button {
      background: #4CAF50;
      color: white;
      padding: 10px 20px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      margin: 5px;
    }
    button:hover {
      background: #45a049;
    }
    .output {
      margin-top: 20px;
      padding: 15px;
      background: #f5f5f5;
      border-radius: 4px;
      min-height: 100px;
    }
    .message {
      margin: 5px 0;
      padding: 8px;
      background: white;
      border-left: 3px solid #4CAF50;
    }
  </style>
</head>
<body>
  <h1>Electron Process Communication</h1>
  
  <div>
    <h2>Invoke (with response):</h2>
    <button id="pingBtn">Send Ping to Main</button>
  </div>
  
  <div>
    <h2>Send (async, with callback):</h2>
    <button id="asyncBtn">Send Async Message</button>
  </div>
  
  <div class="output" id="output">
    <strong>Output:</strong>
    <div id="messages"></div>
  </div>

  <script src="renderer.js"></script>
</body>
</html>
```

