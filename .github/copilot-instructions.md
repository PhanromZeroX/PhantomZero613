# AI Copilot Instructions for Purple Phantom AI

## Project Overview
Purple Phantom AI is a **conversational AI chatbot** with multiple interface implementations:
- **Streamlit web UI** (`app.py`) - Primary web interface with sci-fi VR HUD styling
- **Kivy mobile app** (`mobile_app.py`) - Mobile/desktop client
- **Core model** (`Purple-Phantom.AI/Purple_Phantom.py`) - GPT-2 based response generation

## Architecture & Data Flow

### Model Architecture
1. **Training** (`train_conversational_model.py`):
   - Generates 5,000 conversational samples (user → AI pairs)
   - Trains GPT-2 via HuggingFace Transformers using TensorFlow backend
   - Outputs saved to `./purple_phantom_conversational_model/`

2. **Inference** (`Purple_Phantom.py`):
   - Loads pretrained model from `./purple_phantom_conversational_model/` 
   - Falls back to base GPT-2 if custom model unavailable
   - Forces CPU execution: `CUDA_VISIBLE_DEVICES=''`
   - Enforces max 50 tokens, removes n-grams, uses top-p/top-k sampling

3. **Context Injection**:
   - Wraps user input: `"User: {input}\nAI:"`
   - Injects timestamp via `mississippi_time()` (CST, hardcoded for Kaream)
   - Replaces `{time}` and `{date}` placeholders in responses

### UI Implementations
- **Streamlit** (`app.py`): Imports `conversational_response` from `Purple-Phantom.AI/Purple_Phantom.py`
- **Kivy** (`mobile_app.py`): Imports `predict_category` from same module
- **Styling**: Sci-fi neon purple (#8a2be2) glassmorphism, VR HUD scanlines, pulsing animations

## Critical Developer Workflows

### Model Training
```bash
python train_conversational_model.py
```
Outputs: `./purple_phantom_conversational_model/` (model + tokenizer)

### Running Streamlit Web Interface
```bash
streamlit run app.py  # Uses Purple_Phantom.py core
```

### Building Mobile APK
```bash
buildozer android debug
```
Configuration: `buildozer.spec` - requires python3, kivy, torch, transformers

## Project-Specific Patterns

1. **Timezone Hardcoding**: All temporal logic uses Mississippi (CST) via `mississippi_time()`
   - Used in greetings, response placeholders, training data
   - Function: `datetime.timezone(datetime.timedelta(hours=-6))`

2. **Personalization**: Hardcoded user name "Kaream" in greetings, responses, UI text

3. **Fallback Design**: Model loading falls back to base GPT-2 if custom model missing

4. **Cross-Component Imports**: 
   - Core `Purple_Phantom.py` imported by both app variants
   - No shared config file - hardcoded values replicated across files

## Import Dependencies
- **Core ML**: `torch`, `transformers` (GPT-2 fine-tuning/inference)
- **Web**: `streamlit` (UI)
- **Mobile**: `kivy` (UI for `mobile_app.py`)
- **Framework**: `tensorflow` imported in `app.py` but unused

## Key Files Reference
- Core logic: [`Purple-Phantom.AI/Purple_Phantom.py`](Purple-Phantom.AI/Purple_Phantom.py)
- Web entry: [`app.py`](app.py)
- Mobile entry: [`mobile_app.py`](mobile_app.py)
- Training: [`train_conversational_model.py`](train_conversational_model.py)
- Build config: [`buildozer.spec`](buildozer.spec)
