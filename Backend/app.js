const express = require('express');
const http = require('http');
const setupWebSocket = require('./api/chat');

const app = express();
const server = http.createServer(app);

setupWebSocket(server);

const PORT = process.env.PORT || 8080;
server.listen(PORT, () => {
    console.log(`Server is listening on port ${PORT}`);
});
