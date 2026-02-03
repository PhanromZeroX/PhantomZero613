#!/bin/bash
# Purple Phantom AI - Quick Start Script
# Run this to start both API and Streamlit UI

echo "🚀 Starting Purple Phantom AI..."
echo ""

cd /workspaces/PhantomZero613

# Start Flask API in background
echo "📍 Starting Flask API Server on http://localhost:8080..."
python3 api_server.py > /tmp/api.log 2>&1 &
API_PID=$!
sleep 2

# Check if API started
if ps -p $API_PID > /dev/null; then
    echo "✅ API Server started (PID: $API_PID)"
else
    echo "❌ API Server failed to start"
    cat /tmp/api.log
    exit 1
fi

echo ""
echo "🌐 Starting Streamlit Web UI on http://localhost:8501..."
echo "Setting REMOTE_API_URL..."
export REMOTE_API_URL="http://127.0.0.1:8080/api/respond"

echo ""
echo "================================"
echo "✅ Both systems starting!"
echo "================================"
echo ""
echo "📍 API Server:      http://localhost:8080/api/respond"
echo "🌐 Web UI (Streamlit): http://localhost:8501"
echo ""
echo "Open these URLs in your browser to test!"
echo ""

# Start Streamlit (this runs in foreground)
streamlit run app.py --server.port=8501

