from flask import Flask
from flask import request

app = Flask(__name__)

@app.route('/search/photo')
def anyNameFunction():
    temp = request.args.get('query', "Flask")
    return temp

if __name__ == '__main__':
	app.run(host='0.0.0.0', port=8080, debug=True)
