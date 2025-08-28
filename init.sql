-- Database initialization
CREATE EXTENSION IF NOT EXISTS vector;

-- Table for storing documents and embeddings
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    url VARCHAR(500),
    doc_type VARCHAR(50) DEFAULT 'general',
    embedding vector(384), -- Adjust dimension based on your embedding model
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for vector similarity search
CREATE INDEX ON documents USING hnsw (embedding vector_cosine_ops);

-- Table for conversation history
CREATE TABLE conversations (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(100) NOT NULL,
    user_message TEXT NOT NULL,
    assistant_response TEXT NOT NULL,
    tool_calls_made JSONB DEFAULT '[]',
    sources JSONB DEFAULT '[]',
    language VARCHAR(10) DEFAULT 'bn',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for conversation lookup
CREATE INDEX idx_conversations_session ON conversations(session_id);
CREATE INDEX idx_conversations_created_at ON conversations(created_at);

-- Sample documents for testing
INSERT INTO documents (title, content, url, doc_type) VALUES
('ভিপিএন রিসেট গাইড', 'আপনার কোম্পানির ভিপিএন রিসেট করার জন্য এই পদক্ষেপগুলি অনুসরণ করুন: ১) সেটিংস > নেটওয়ার্ক এ যান ২) বিদ্যমান ভিপিএন প্রোফাইল মুছে দিন ৩) নতুন কনফিগারেশন যোগ করুন', '/docs/vpn-reset-bn', 'manual'),
('VPN Reset Guide', 'To reset your company VPN, follow these steps: 1) Go to Settings > Network 2) Remove existing VPN profile 3) Add new configuration with provided credentials', '/docs/vpn-reset-en', 'manual'),
('সাধারণ সমস্যা সমাধান', 'প্রশ্ন: ভিপিএন কানেকশন রিসেট করবো কিভাবে? উত্তর: সম্পূর্ণভাবে রিসেট করার জন্য এই পদক্ষেপগুলি অনুসরণ করুন...', '/docs/faq-bn', 'faq'),
('Docker Model Runner Setup', 'Docker Model Runner allows you to run AI models locally with OpenAI-compatible API endpoints. Use docker model pull ai/smollm3 to get started.', '/docs/docker-setup', 'guide');
