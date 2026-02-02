import streamlit as st
import datetime
import pandas as pd
import tensorflow as tf
import random

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

st.title("Purple Phantom AI Assistant")

st.write("Welcome to your personal AI assistant!")

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

    # Simple response - use greeting or echo
    if "hello" in prompt.lower() or "hi" in prompt.lower():
        response = generate_greeting(time_of_day)
    else:
        response = f"You said: {prompt}. (AI response coming soon!)"
    st.session_state.messages.append({"role": "assistant", "content": response})
    with st.chat_message("assistant"):
        st.markdown(response)