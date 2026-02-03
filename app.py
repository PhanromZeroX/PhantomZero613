import streamlit as st
import datetime
import pandas as pd
import random
from Purple_Phantom import conversational_response

# TensorFlow is optional for deployment environments that don't support it
try:
    import tensorflow as tf
    TENSORFLOW_AVAILABLE = True
except Exception:
    TENSORFLOW_AVAILABLE = False

# Copy functions from Purple-Phantom.py
def mississippi_time():
    mississippi_tz = datetime.timezone(datetime.timedelta(hours=-6))  # Central Standard Time (CST)
    mississippi_time = datetime.datetime.now(mississippi_tz)
    return mississippi_time.strftime("%Y-%m-%d %H:%M:%S")

greeting_dataset = {
    "morning": [
        "Good morning, Kaream! The current time in Mississippi is " + mississippi_time() + ". How can I assist you today?",
        "Morning, Kaream! It's " + mississippi_time() + " in Mississippi. What would you like to do today?",
        "Hello Kaream, it's a beautiful morning in Mississippi at " + mississippi_time() + ". How can I help you?"
    ],
    "afternoon": [
        "Good afternoon, Kaream! The current time in Mississippi is " + mississippi_time() + ". What can I do for you?",
        "Afternoon, Kaream! It's " + mississippi_time() + " in Mississippi. How can I assist you this afternoon?",
        "Hello Kaream, it's a lovely afternoon in Mississippi at " + mississippi_time() + ". What would you like to do?"
    ],
    "evening": [
        "Good evening, Kaream! The current time in Mississippi is " + mississippi_time() + ". How can I assist you tonight?",
        "Evening, Kaream! It's " + mississippi_time() + " in Mississippi. What would you like to do this evening?",
        "Hello Kaream, it's a peaceful evening in Mississippi at " + mississippi_time() + ". How can I help you?"
    ],
    "night": [
        "Good night, Kaream! The current time in Mississippi is " + mississippi_time() + ". Is there anything you need before bed?",
        "Night, Kaream! It's " + mississippi_time() + " in Mississippi. How can I assist you before you sleep?",
        "Hello Kaream, it's a quiet night in Mississippi at " + mississippi_time() + ". What would you like to do?"
    ]
}

def generate_greeting(time_of_day):
    if time_of_day in greeting_dataset:
        return random.choice(greeting_dataset[time_of_day])
    else:
        return "Hello! How can I assist you?"

# Sci-Fi themed CSS with Glassmorphism and Neon Purple Glow for VR HUD
st.markdown("""
<style>
    @keyframes glow {
        0% { box-shadow: 0 0 10px #8a2be2; }
        50% { box-shadow: 0 0 20px #8a2be2, 0 0 30px #8a2be2; }
        100% { box-shadow: 0 0 10px #8a2be2; }
    }
    @keyframes pulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.05); }
        100% { transform: scale(1); }
    }
    @keyframes scanline {
        0% { transform: translateY(-100%); }
        100% { transform: translateY(100vh); }
    }
    .stApp {
        background: linear-gradient(135deg, #0a0a0a 0%, #1a1a2e 50%, #16213e 100%);
        color: #e0e0e0;
        font-family: 'Courier New', monospace;
        position: relative;
        overflow: hidden;
    }
    .stApp::before {
        content: '';
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(138, 43, 226, 0.1);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        border: 1px solid rgba(138, 43, 226, 0.2);
        z-index: -1;
        animation: glow 3s infinite;
    }
    .hud-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
        z-index: 10;
    }
    .hud-border {
        position: absolute;
        border: 2px solid #8a2be2;
        box-shadow: 0 0 20px #8a2be2;
    }
    .hud-top { top: 10px; left: 10px; right: 10px; height: 2px; }
    .hud-bottom { bottom: 10px; left: 10px; right: 10px; height: 2px; }
    .hud-left { top: 10px; bottom: 10px; left: 10px; width: 2px; }
    .hud-right { top: 10px; bottom: 10px; right: 10px; width: 2px; }
    .scanline {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 2px;
        background: linear-gradient(90deg, transparent, #8a2be2, transparent);
        animation: scanline 5s linear infinite;
    }
    .stTextInput > div > div > input {
        background: rgba(138, 43, 226, 0.1);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        color: #8a2be2;
        border: 2px solid #8a2be2;
        border-radius: 10px;
        box-shadow: 0 0 10px #8a2be2;
        animation: glow 2s infinite;
    }
    .stTextInput > div > div > input:focus {
        box-shadow: 0 0 20px #8a2be2;
        animation: glow 1s infinite;
    }
    .stButton > button {
        background: rgba(138, 43, 226, 0.2);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        color: #ffffff;
        border: 2px solid #8a2be2;
        border-radius: 10px;
        padding: 10px 20px;
        box-shadow: 0 0 10px #8a2be2;
        transition: all 0.3s ease;
        animation: pulse 2s infinite;
    }
    .stButton > button:hover {
        background: rgba(138, 43, 226, 0.4);
        box-shadow: 0 0 20px #8a2be2;
        transform: scale(1.05);
        animation: glow 1s infinite;
    }
    .stChatMessage {
        background: rgba(138, 43, 226, 0.1);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        border: 1px solid #8a2be2;
        border-radius: 15px;
        padding: 15px;
        margin: 10px 0;
        color: #e0e0e0;
        box-shadow: 0 0 10px rgba(138, 43, 226, 0.3);
        animation: glow 4s infinite;
    }
    .stChatMessage.user {
        background: rgba(138, 43, 226, 0.2);
        border-color: #8a2be2;
        box-shadow: 0 0 10px rgba(138, 43, 226, 0.3);
        animation: glow 4s infinite;
    }
    h1, h2, h3 {
        color: #8a2be2;
        text-shadow: 0 0 10px #8a2be2;
        animation: glow 3s infinite;
    }
    .stMarkdown {
        color: #e0e0e0;
    }
    .stSidebar {
        background: rgba(15, 15, 35, 0.8);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        border-right: 2px solid #8a2be2;
    }
    .social-button {
        animation: pulse 3s infinite;
        background: rgba(138, 43, 226, 0.2) !important;
        backdrop-filter: blur(10px) !important;
        -webkit-backdrop-filter: blur(10px) !important;
        border: 1px solid #8a2be2 !important;
        box-shadow: 0 0 10px #8a2be2 !important;
    }
    .social-button:hover {
        animation: glow 1s infinite;
        background: rgba(138, 43, 226, 0.4) !important;
        box-shadow: 0 0 20px #8a2be2 !important;
    }
</style>
""", unsafe_allow_html=True)

# VR HUD Overlay
st.markdown("""
<div class="hud-overlay">
    <div class="hud-border hud-top"></div>
    <div class="hud-border hud-bottom"></div>
    <div class="hud-border hud-left"></div>
    <div class="hud-border hud-right"></div>
    <div class="scanline"></div>
</div>
""", unsafe_allow_html=True)

st.title("Purple Phantom AI Assistant")

st.write("Welcome to your personal AI assistant, themed like a FNF YouTuber!")

# Social Media Buttons
st.markdown("""
<div style="display: flex; justify-content: center; gap: 10px; margin: 20px 0;">
    <a href="https://www.instagram.com" target="_blank" class="social-button" style="background: linear-gradient(45deg, #ff006e, #8338ec); color: white; padding: 10px 15px; border-radius: 10px; text-decoration: none; box-shadow: 0 0 10px #ff006e; transition: all 0.3s ease;">📷 Instagram</a>
    <a href="https://discord.com" target="_blank" class="social-button" style="background: linear-gradient(45deg, #ff006e, #8338ec); color: white; padding: 10px 15px; border-radius: 10px; text-decoration: none; box-shadow: 0 0 10px #ff006e; transition: all 0.3s ease;">💬 Discord</a>
    <a href="https://www.twitch.tv" target="_blank" class="social-button" style="background: linear-gradient(45deg, #ff006e, #8338ec); color: white; padding: 10px 15px; border-radius: 10px; text-decoration: none; box-shadow: 0 0 10px #ff006e; transition: all 0.3s ease;">📺 Twitch</a>
    <a href="https://www.youtube.com" target="_blank" class="social-button" style="background: linear-gradient(45deg, #ff006e, #8338ec); color: white; padding: 10px 15px; border-radius: 10px; text-decoration: none; box-shadow: 0 0 10px #ff006e; transition: all 0.3s ease;">🔴 YouTube</a>
</div>
""", unsafe_allow_html=True)

# Simple greeting based on time
current_time = datetime.datetime.now()
if 5 <= current_time.hour < 12:
    time_of_day = "morning"
elif 12 <= current_time.hour < 17:
    time_of_day = "afternoon"
elif 17 <= current_time.hour < 21:
    time_of_day = "evening"
else:
    time_of_day = "night"

st.write(generate_greeting(time_of_day))

# Chat interface
if "messages" not in st.session_state:
    st.session_state.messages = []

for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

if prompt := st.chat_input("What can I help you with?"):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # AI response
    response = conversational_response(prompt)
    st.session_state.messages.append({"role": "assistant", "content": response})
    with st.chat_message("assistant"):
        st.markdown(response)