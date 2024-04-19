import { type AddressInfo, WebSocketServer } from 'ws';

const wss = new WebSocketServer({ port: 8080 });

wss.once('listening', () => console.log(`Listening on :${(wss.address() as AddressInfo).port}`));

wss.on('connection', (ws) => ws.send('Hello World'));
