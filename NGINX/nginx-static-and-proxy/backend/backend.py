from flask import Flask, request
app = Flask(__name__)

@app.route('/api/hello')
def hello():
    
    real_ip = (
        request.headers.get('X-Real-IP') or 
        request.headers.get('X-Forwarded-For', '').split(',')[0].strip() or
        request.remote_addr
    )


    return {
        "message": "Hello from backend!",
        "your_ip": real_ip,
        "host_header": request.headers.get('Host'),
        "all_headers": dict(request.headers)
    }

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
