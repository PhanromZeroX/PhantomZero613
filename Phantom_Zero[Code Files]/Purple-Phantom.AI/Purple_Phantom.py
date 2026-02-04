import torch
from transformers import GPT2LMHeadModel, GPT2Tokenizer
import datetime
import os

os.environ['CUDA_VISIBLE_DEVICES'] = ''  # Force CPU

# Function to get Mississippi time
def mississippi_time():
    mississippi_tz = datetime.timezone(datetime.timedelta(hours=-6))
    return datetime.datetime.now(mississippi_tz).strftime("%Y-%m-%d %H:%M:%S")

# Load the trained model and tokenizer
model_path = "./purple_phantom_conversational_model"
if os.path.exists(model_path):
    model = GPT2LMHeadModel.from_pretrained(model_path)
    tokenizer = GPT2Tokenizer.from_pretrained(model_path)
    tokenizer.pad_token = tokenizer.eos_token
else:
    # Fallback to base GPT2 if not trained
    model = GPT2LMHeadModel.from_pretrained("gpt2")
    tokenizer = GPT2Tokenizer.from_pretrained("gpt2")
    tokenizer.pad_token = tokenizer.eos_token

def predict_category(user_input):
    # Use the model to generate a response
    input_text = f"User: {user_input}\nAI:"
    input_ids = tokenizer.encode(input_text, return_tensors='pt')
    output = model.generate(input_ids, max_length=50, num_return_sequences=1, no_repeat_ngram_size=2, top_p=0.95, top_k=50)
    response = tokenizer.decode(output[0], skip_special_tokens=True)
    # Extract the AI response part
    if "AI:" in response:
        response = response.split("AI:")[-1].strip()
    # Replace placeholders if any
    response = response.replace("{time}", mississippi_time())
    response = response.replace("{date}", datetime.datetime.now().strftime("%Y-%m-%d"))
    return response

# For compatibility, perhaps keep some dict for fallbacks, but since model is there, use it.
