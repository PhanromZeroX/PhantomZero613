# Okay so to begin with, this is Purple-Phantom.AI
# this is a Python script for an Personal AI Assistant named Purple Phantom
# it is designed to help with various tasks and provide information as well as entertainment
# and personal social interaction and can insteract with me throught text commands
# it will be also have integrated social media app features to help me stay connected with friends and family
# it will also have integrated memory database used for all if conversational context and personal data storage
# it will know my preferences and habits to provide a more personalized experience
# Purple phantom  will have an algorithm that uses it memory bank to be turned into a data set so its learning from its past interactions
# just to cut this short he will have various nerual network models, algorithms and data processing techniques to help him learn and adapt over time
# this will help him improve his responses and interactions with me



# --- Libraries ---
import datetime
import pandas as pd
import tensorflow as tf
from tensorflow.keras import Input







#--- Hello Master aglorithm---
# details about how purple phantom will greet me and start a conversation based on the time of day and my mood
# this will be based on my previous interactions and preferences stored in his memory bank or csv files ready made for his learning dataset

# --- tools to help with tasks ---
# a function for moss point mississippi time zone conversion
# a function for setting reminders and alarms
# a function for managing to do lists and tasks using learning algorithms to prioritize tasks based on my habits and preferences
# a function for managing calendar events and appointments
# a function just to let me know various of new information and news updates based on my interests using web scraping and natural language processing techniques
# i will be also providing a nerual network model for simple and fast lear

#--- time for mississippi ---
def mississippi_time():
    # --- add instructions for mississippi time conversion for neuaral network model ---
    # lets add time zone and all info related to mississippi time and prepare it dataset wise purple phantoms greeting network model
    mississippi_tz = datetime.timezone(datetime.timedelta(hours=-6))  # Central Standard Time (CST)
    mississippi_time = datetime.datetime.now(mississippi_tz)
    #okay now lets set up a key value pair data set for purple phantom to learn from
    return mississippi_time.strftime("%Y-%m-%d %H:%M:%S")

# --- key value pair data set for purple phantom to learn from, by add in a medium amount of responses based on time of day ---
# lets know we will include the mississippi time function into this dataset
# we also include masters name in string format who is Kaream
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

# --- lets turn this into something that can prepare it for a nerual network model using the first data set ---
# note this will be the first function used when purple phantom is activated
#this will also be the first input for the network model to learn from

# -- lets make a algorithm to prepare the greeting dataset for the nerual network model and we will use it to make understandable tabulare data---
def prepare_greeting_data(dataset):
    prepared_data = []
    for time_of_day, responses in dataset.items():
        for response in responses:
            prepared_data.append((time_of_day, response))
    return prepared_data

# --- prepare the greeting data for the nerual network model and make tabulare viual data ---
greeting_data_for_model = prepare_greeting_data(greeting_dataset)
# viaual representation of the prepared data and making it visualy complex yet unserstandable for the nerual network model using pandas
#greeting_df = pd.DataFrame(greeting_data_for_model, columns=["Time of Day", "Response"])
#print(greeting_df)

# okay so the prepare dataset is now prepared lets move on to make the inputs for the nueral model training both key value pairs using pandas
# an test and train if it can correctly greet me based on the time of day by coming up with random new responses of its own based on the learned dataset
def train_greeting_model(prepared_data):
    # neural network
    input_size = 11
    hidden_size = 8
    output_size = 4  # number of time_of_day classes
    learning_rate = 0.01
    num_epochs = 100
    # neural model itsef will be using tensorflow library
    model = tf.keras.Sequential([
        Input(shape=(input_size,)),
        tf.keras.layers.Dense(hidden_size, activation='relu'),
        tf.keras.layers.Dense(output_size, activation='softmax')
    ])
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate),
                  loss='sparse_categorical_crossentropy',
                  metrics=['accuracy'])
    # prepare data for training
    X_train = []
    y_train = []
    time_of_day_mapping = {"morning": 0, "afternoon": 1, "evening": 2, "night": 3}
    for time_of_day, response in prepared_data:
        input_vector = [0] * input_size
        input_vector[time_of_day_mapping[time_of_day]] = 1
        X_train.append(input_vector)
        y_train.append(time_of_day_mapping[time_of_day])
    X_train = tf.convert_to_tensor(X_train, dtype=tf.float32)
    y_train = tf.convert_to_tensor(y_train, dtype=tf.int32)
    # train the model
    model.fit(X_train, y_train, epochs=num_epochs, verbose=1)
    return model

# train the greeting model
print("Starting training of the greeting model...")
greeting_model = train_greeting_model(greeting_data_for_model)
print("Training completed. Saving model...")
greeting_model.save('Purple-Phantom.AI/greeting_model.keras')
print("Model saved.")

# function to generate a greeting based on time of day
import random
def generate_greeting(time_of_day):
    if time_of_day in greeting_dataset:
        return random.choice(greeting_dataset[time_of_day])
    else:
        return "Hello! How can I assist you?"

# example usage
current_time = datetime.datetime.now()
if 5 <= current_time.hour < 12:
    tod = "morning"
elif 12 <= current_time.hour < 17:
    tod = "afternoon"
elif 17 <= current_time.hour < 21:
    tod = "evening"
else:
    tod = "night"
print(f"Generated greeting: {generate_greeting(tod)}")

