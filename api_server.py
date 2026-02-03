from flask import Flask, request, jsonify
from Purple_Phantom import conversational_response, MODEL_AVAILABLE

app = Flask(__name__)

@app.route('/api/respond', methods=['POST'])
def respond():
    data = request.get_json(force=True)
    prompt = data.get('prompt', '')
    if not prompt:
        return jsonify({'error': 'no prompt provided'}), 400
    resp = conversational_response(prompt)
    return jsonify({'response': resp, 'model_available': bool(MODEL_AVAILABLE)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
