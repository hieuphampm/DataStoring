import React, { useState, useEffect, useRef } from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';
import { BsSend, BsChat, BsPersonCircle } from 'react-icons/bs';

function App() {
  const [messages, setMessages] = useState([]);
  const [user, setUser] = useState('User_' + Math.random().toString(36).substr(2, 5));
  const [message, setMessage] = useState('');
  const messagesEndRef = useRef(null);
  const messageContainerRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    const fetchMessages = async (retries = 3, delay = 2000) => {
      for (let i = 0; i < retries; i++) {
        try {
          const response = await fetch('http://34.2.19.12:8000/messages');
          if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
          const data = await response.json();
          setMessages(data.messages || []);
          scrollToBottom();
          return; // Success, exit retry loop
        } catch (error) {
          console.error('Fetch error:', error.message);
          if (i < retries - 1) {
            await new Promise(resolve => setTimeout(resolve, delay));
            console.log(`Retrying fetch... (${i + 1}/${retries})`);
          }
        }
      }
    };

    fetchMessages();
    const interval = setInterval(fetchMessages, 2000);
    return () => clearInterval(interval);
  }, []);

  const sendMessage = async (e) => {
    e.preventDefault();
    if (!message.trim()) return;

    try {
      const response = await fetch('http://34.2.19.12:8000/messages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user, message }),
      });
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
      const data = await response.json();
      console.log('Send response:', data);
      setMessage('');
      scrollToBottom();
    } catch (error) {
      console.error('Send error:', error.message);
    }
  };

  const formatTimestamp = (timestamp) => {
    try {
      return new Date(timestamp).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: true,
      });
    } catch (e) {
      return 'Invalid Date';
    }
  };

  return (
    <div className="d-flex flex-column vh-100">
      {/* Header */}
      <div className="bg-primary text-white p-3">
        <div className="d-flex align-items-center">
          <BsChat className="me-2" size={24} />
          <h1 className="h5 mb-0 fw-bold">Anonymous Chat</h1>
        </div>
      </div>

      {/* Message Container */}
      <div 
        ref={messageContainerRef}
        className="flex-grow-1 p-3 overflow-auto" 
        style={{ backgroundColor: '#f8f9fa' }}
      >
        {messages.map((msg, index) => (
          <div
            key={index}
            className={`d-flex mb-3 ${msg.user === user ? 'justify-content-end' : 'justify-content-start'}`}
          >
            {msg.user !== user && (
              <div className="me-2 align-self-end">
                <BsPersonCircle size={24} className="text-secondary" />
              </div>
            )}
            <div
              className={`p-3 rounded-3 shadow-sm ${
                msg.user === user ? 'bg-primary text-white' : 'bg-white'
              }`}
              style={{ maxWidth: '75%', wordBreak: 'break-word' }}
            >
              <div>{msg.message}</div>
              <div className="text-end mt-1" style={{ fontSize: '0.7rem', opacity: 0.8 }}>
                {formatTimestamp(msg.timestamp)}
              </div>
            </div>
            {msg.user === user && (
              <div className="ms-2 align-self-end">
                <BsPersonCircle size={24} className="text-primary" />
              </div>
            )}
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      {/* Input Container */}
      <div className="p-3 border-top bg-white">
        <form onSubmit={sendMessage} className="d-flex">
          <input
            type="text"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="Type a message..."
            className="form-control rounded-pill me-2"
          />
          <button 
            type="submit" 
            className="btn btn-primary rounded-circle d-flex align-items-center justify-content-center" 
            style={{ width: '42px', height: '42px', flexShrink: 0 }}
          >
            <BsSend />
          </button>
        </form>
      </div>
    </div>
  );
}

export default App;