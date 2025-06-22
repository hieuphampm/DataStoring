import React, { useState, useEffect, useRef } from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';
import { BsSend, BsChat, BsPersonCircle } from 'react-icons/bs';

function App() {
  const [messages, setMessages] = useState([]);
  const [user, setUser] = useState('User_' + Math.random().toString(36).substr(2, 5));
  const [message, setMessage] = useState('');
  const [room, setRoom] = useState('');
  const [joined, setJoined] = useState(false);
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    if (!joined || !room) return;

    const fetchMessages = async () => {
      try {
        const response = await fetch(`http://34.2.19.12:8000/messages?room=${room}`);
        const data = await response.json();
        setMessages(data.messages || []);
        scrollToBottom();
      } catch (error) {
        console.error('Fetch error:', error);
      }
    };

    fetchMessages();
    const interval = setInterval(fetchMessages, 2000);
    return () => clearInterval(interval);
  }, [joined, room]);

  const sendMessage = async (e) => {
    e.preventDefault();
    if (!message.trim() || !room) return;

    try {
      await fetch(`http://34.2.19.12:8000/messages?room=${room}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user, message }),
      });
      setMessage('');
      scrollToBottom();
    } catch (error) {
      console.error('Send error:', error);
    }
  };

  const formatTimestamp = (timestamp) => {
    try {
      return new Date(timestamp).toLocaleTimeString('en-US', {
        hour: '2-digit', minute: '2-digit', hour12: true,
      });
    } catch {
      return 'Invalid';
    }
  };

  const avatarColors = ['#f44336', '#3f51b5', '#4caf50', '#ff9800', '#9c27b0'];
  const getAvatarColor = (name) => avatarColors[name.charCodeAt(0) % avatarColors.length];

  if (!joined) {
    return (
      <div className="container vh-100 d-flex flex-column justify-content-center align-items-center">
        <h2 className="mb-3">Join Private Chat Room</h2>
        <input type="text" className="form-control mb-2" placeholder="Enter nickname" value={user} onChange={(e) => setUser(e.target.value)} />
        <input type="text" className="form-control mb-2" placeholder="Enter or share room code" value={room} onChange={(e) => setRoom(e.target.value)} />
        <button className="btn btn-primary" onClick={() => setJoined(true)} disabled={!user || !room}>Join</button>
      </div>
    );
  }

  return (
    <div className="d-flex flex-column vh-100">
      <div className="bg-primary text-white p-3">
        <div className="d-flex align-items-center">
          <BsChat className="me-2" size={24} />
          <h1 className="h5 mb-0 fw-bold">Room: {room}</h1>
        </div>
      </div>

      <div className="flex-grow-1 p-3 overflow-auto" style={{ backgroundColor: '#f8f9fa' }}>
        {messages.map((msg, index) => (
          <div key={index} className={`d-flex mb-3 ${msg.user === user ? 'justify-content-end' : 'justify-content-start'}`}>
            {msg.user !== user && (
              <div className="me-2 align-self-end" style={{ color: getAvatarColor(msg.user) }}>
                <BsPersonCircle size={24} />
              </div>
            )}
            <div className={`p-3 rounded-3 shadow-sm ${msg.user === user ? 'bg-primary text-white' : 'bg-white'}`} style={{ maxWidth: '75%' }}>
              <div className="fw-bold mb-1">{msg.user}</div>
              <div>{msg.message}</div>
              <div className="text-end mt-1" style={{ fontSize: '0.7rem', opacity: 0.8 }}>{formatTimestamp(msg.timestamp)}</div>
            </div>
            {msg.user === user && (
              <div className="ms-2 align-self-end" style={{ color: getAvatarColor(msg.user) }}>
                <BsPersonCircle size={24} />
              </div>
            )}
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      <div className="p-3 border-top bg-white">
        <form onSubmit={sendMessage} className="d-flex">
          <input
            type="text"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="Type a message..."
            className="form-control rounded-pill me-2"
          />
          <button type="submit" className="btn btn-primary rounded-circle d-flex align-items-center justify-content-center" style={{ width: '42px', height: '42px' }}>
            <BsSend />
          </button>
        </form>
      </div>
    </div>
  );
}

export default App;
