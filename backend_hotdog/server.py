from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from PIL import Image
import numpy as np

import tensorflow as tf

app = Flask(__name__)

app.config["DEBUG"] = True

model = tf.keras.models.load_model('./assets/hotdog_not_hotdog.h5')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

@app.route('/')
def home():
   return 'Hello, world'

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/predict', methods=['POST'])
def predict():
    # Check if the request contains a file
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']
    
    # If no file is selected
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        img = Image.open(file.stream)  # Open image
        img = img.resize((224, 224))  # Resize image to match the input size of your model (e.g., 224x224)
        img_array = np.array(img) / 255.0  # Normalize image

        # Add batch dimension
        img_array = np.expand_dims(img_array, axis=0)

        # Predict with your model
        prediction = model.predict(img_array)

        # Assuming model returns probabilities, you might want to convert to binary (0 or 1)
        outcome = int(prediction[0] > 0.5)  # If greater than 0.5, predict 1 else 0

        return jsonify({'prediction': outcome})

    return jsonify({'error': 'Invalid file format'}), 400




if __name__ == '__main__':
   app.run(host='0.0.0.0', port=5000)