from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/health')
def health_check():
    return jsonify({'status': 'alive', 'layer': 'body'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
