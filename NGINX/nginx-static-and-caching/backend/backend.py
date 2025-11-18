from flask import Flask, request
app = Flask(__name__)

@app.route('/api')
def hello():
    
    nginx_cache_status = request.headers.get('X-Cache-Status-Internal')

    real_ip = (
        request.headers.get('X-Real-IP') or 
        request.headers.get('X-Forwarded-For', '').split(',')[0].strip() or
        request.remote_addr
    )


    return {
        "message": "Hello from backend!",
        "your_ip": real_ip,
        "host_header": request.headers.get('Host'),
        "nginx_internal_cache_status": nginx_cache_status,
        "all_headers": dict(request.headers)
    }

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
