import sys
sys.path.append('Purple-Phantom.AI')

from Purple_Phantom import predict_category, mississippi_time

from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/api/respond', methods=['POST'])
def respond():
    data = request.json
    input_text = data.get('input', '')
    response = predict_category(input_text)
    timestamp = mississippi_time()
    return jsonify({'response': response, 'timestamp': timestamp})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)