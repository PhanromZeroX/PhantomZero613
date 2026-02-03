import datetime
import os
import json
import logging

# Optional requests import for remote API fallback
try:
    import requests
    REQUESTS_AVAILABLE = True
except Exception:
    REQUESTS_AVAILABLE = False

# Try to load a local model if available; otherwise code supports remote API fallback.
MODEL_AVAILABLE = False
model = None
tokenizer = None

# Function to get Mississippi time
def mississippi_time():
    mississippi_tz = datetime.timezone(datetime.timedelta(hours=-6))
    return datetime.datetime.now(mississippi_tz).strftime("%Y-%m-%d %H:%M:%S")

model_path = "./purple_phantom_conversational_model"
try:
    # lazy import of heavy libs so environments that can't install them won't fail on import
    from transformers import GPT2LMHeadModel, GPT2Tokenizer
    if os.path.exists(model_path):
        model = GPT2LMHeadModel.from_pretrained(model_path)
        tokenizer = GPT2Tokenizer.from_pretrained(model_path)
        tokenizer.pad_token = tokenizer.eos_token
        MODEL_AVAILABLE = True
    else:
        # try fallback to base GPT-2 if the environment allows
        try:
            model = GPT2LMHeadModel.from_pretrained("gpt2")
            tokenizer = GPT2Tokenizer.from_pretrained("gpt2")
            tokenizer.pad_token = tokenizer.eos_token
            MODEL_AVAILABLE = True
        except Exception:
            MODEL_AVAILABLE = False
except Exception:
    MODEL_AVAILABLE = False


def predict_category(user_input):
    """Generate a reply using the local model. Caller should check MODEL_AVAILABLE first."""
    if not MODEL_AVAILABLE:
        return "(model unavailable) I can't reply locally right now."
    input_text = f"User: {user_input}\nAI:"
    input_ids = tokenizer.encode(input_text, return_tensors='pt')
    output = model.generate(input_ids, max_length=50, num_return_sequences=1, no_repeat_ngram_size=2, top_p=0.95, top_k=50)
    response = tokenizer.decode(output[0], skip_special_tokens=True)
    if "AI:" in response:
        response = response.split("AI:")[-1].strip()
    response = response.replace("{time}", mississippi_time())
    response = response.replace("{date}", datetime.datetime.now().strftime("%Y-%m-%d"))
    return response


def conversational_response(prompt: str) -> str:
    """
    Preferred method to get a conversational response. Order:
    1) Remote API if environment variable REMOTE_API_URL is set.
    2) Local model via predict_category if MODEL_AVAILABLE.
    3) Fallback simple echo.
    """
    remote = os.environ.get('REMOTE_API_URL')
    if remote and REQUESTS_AVAILABLE:
        try:
            resp = requests.post(remote, json={"prompt": prompt}, timeout=10)
            if resp.status_code == 200:
                data = resp.json()
                return data.get('response', data.get('text', resp.text))
            else:
                logging.warning('Remote API returned status %s', resp.status_code)
        except Exception as e:
            logging.warning('Remote API request failed: %s', e)

    # Local model fallback
    if MODEL_AVAILABLE:
        return predict_category(prompt)

    # Last-resort fallback
    return f"Sorry — model not available. Echo: {prompt}"
