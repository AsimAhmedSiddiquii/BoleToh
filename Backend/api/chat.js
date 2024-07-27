const WebSocket = require('ws');
const { app } = require('../firebase');
const { getFirestore, collection, doc, getDocs, query, orderBy } = require('firebase-admin/firestore');

const db = getFirestore(app);
const userConnections = {}; // userId: WebSocket

const setupWebSocket = (server) => {
    const wss = new WebSocket.Server({ server, path: '/ws' });

    wss.on('connection', async (ws, req) => {
        console.log('New client connected');

        const userId = new URL(req.url, `http://${req.headers.host}`).searchParams.get('user');
        const recipientId = new URL(req.url, `http://${req.headers.host}`).searchParams.get('recipient');

        console.log(`User ID: ${userId}, Recipient ID: ${recipientId}`);

        // Fetch and send previous messages
        if (userId && recipientId) {
            try {
                const chatRef = db.collection('chats').doc(`${userId}_${recipientId}`).collection('messages');
                const querySnapshot = await chatRef.orderBy('timestamp', 'asc').get();
                if (querySnapshot.empty) {
                    console.log('No previous messages found.');
                } else {
                    querySnapshot.forEach((doc) => {
                        const message = doc.data();
                        console.log(`Sending previous message: ${JSON.stringify(message)}`);
                        ws.send(JSON.stringify({ senderId: message.senderId, content: message.content }));
                    });
                }
            } catch (error) {
                console.error('Error fetching previous messages:', error);
            }
        }

        ws.on('message', async (message) => {
            try {
                const { senderId, receiverId, content } = JSON.parse(message);
                const recipientSocket = userConnections[receiverId];

                await db.collection('chats').doc(`${senderId}_${receiverId}`).collection('messages').add({
                    senderId: senderId,
                    receiverId: receiverId,
                    content: content,
                    timestamp: new Date()
                });

                if (recipientSocket && recipientSocket.readyState === WebSocket.OPEN) {
                    recipientSocket.send(JSON.stringify({ senderId, content }));
                }
            } catch (error) {
                console.error('Message handling failed:', error);
            }
        });

        ws.on('close', () => {
            console.log('Client disconnected');
            for (const userId in userConnections) {
                if (userConnections[userId] === ws) {
                    delete userConnections[userId];
                    break;
                }
            }
        });
    });
};

module.exports = setupWebSocket;
