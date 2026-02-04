#!/bin/bash

# source .venv/bin/activate

python api_server.py &

streamlit run app.py