from flask import Flask, Response
import cv2

app = Flask(__name__)

camera = cv2.VideoCapture(-1)

def generate_frames():
    while True:
        success, frame = camera.read()
        if not success:
            break
        else:
            # Convert frame to raw bytes
            frame_bytes = frame.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: video/mp4\r\n\r\n' + frame_bytes + b'\r\n')

@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(), mimetype='video/mp4')

if __name__ == '__main__':
    app.run(debug=True)
