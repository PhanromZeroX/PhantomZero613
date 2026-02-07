import torch
from transformers import GPT2LMHeadModel, GPT2Tokenizer, Trainer, TrainingArguments
from torch.utils.data import Dataset
import random
import datetime

# Function to get Mississippi time
def mississippi_time():
    mississippi_tz = datetime.timezone(datetime.timedelta(hours=-6))
    return datetime.datetime.now(mississippi_tz).strftime("%Y-%m-%d %H:%M:%S")

# Generate a big conversational dataset for casual conversation between Purple Phantom AI and Kaream
def generate_dataset(num_samples=5000):
    greetings = ["hello", "hi", "hey", "good morning", "good afternoon", "good evening", "good night"]
    questions = ["how are you", "what's up", "what time is it", "tell me a joke", "who are you", "what can you do", "tell me about yourself"]
    responses = [
        "I'm doing well, Kaream. How about you?",
        "Not much, just here to help you, Kaream.",
        f"The current time in Mississippi is {mississippi_time()}, Kaream.",
        "Why did the scarecrow win an award? Because he was outstanding in his field! Haha, Kaream.",
        "I am Purple Phantom, your personal AI assistant, Kaream.",
        "I can help with time, jokes, information, and more, Kaream.",
        "I'm an AI created to assist you, Kaream, with a sci-fi theme."
    ]
    dataset = []
    for _ in range(num_samples):
        user_input = random.choice(greetings + questions)
        ai_response = random.choice(responses)
        conversation = f"User: {user_input}\nAI: {ai_response}\n"
        dataset.append(conversation)
    return dataset

# Custom Dataset class
class ConversationalDataset(Dataset):
    def __init__(self, texts, tokenizer, max_length=128):
        self.tokenizer = tokenizer
        self.texts = texts
        self.max_length = max_length

    def __len__(self):
        return len(self.texts)

    def __getitem__(self, idx):
        text = self.texts[idx]
        encoding = self.tokenizer(text, truncation=True, padding='max_length', max_length=self.max_length, return_tensors='pt')
        return {
            'input_ids': encoding['input_ids'].flatten(),
            'attention_mask': encoding['attention_mask'].flatten(),
            'labels': encoding['input_ids'].flatten()
        }

# Generate dataset
dataset_texts = generate_dataset()

# Load model and tokenizer
model_name = "gpt2"
model = GPT2LMHeadModel.from_pretrained(model_name)
tokenizer = GPT2Tokenizer.from_pretrained(model_name)
tokenizer.pad_token = tokenizer.eos_token

# Create dataset
train_dataset = ConversationalDataset(dataset_texts, tokenizer)

# Training arguments
training_args = TrainingArguments(
    output_dir="./results",
    num_train_epochs=3,
    per_device_train_batch_size=4,
    save_steps=10_000,
    save_total_limit=2,
)

# Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
)

# Train the model
trainer.train()

# Save the model
model.save_pretrained("./purple_phantom_conversational_model")
tokenizer.save_pretrained("./purple_phantom_conversational_model")

print("Model trained and saved!")