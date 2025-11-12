from flask import Flask, request
app = Flask(__name__)

@app.route('/')
def hello():
    headers = dict(request.headers)
    headers_html = "<br>".join([f"{k}: {v}" for k, v in headers.items()])
    return f"<h1>Hello, I'm backend1</h1><h2>Request headers:</h2>{headers_html}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
