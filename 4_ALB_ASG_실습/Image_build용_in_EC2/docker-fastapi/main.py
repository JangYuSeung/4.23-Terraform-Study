from fastapi import FastAPI

app = FastAPI()

@app.get("/fastapi")
def fastapi_root():
    return {
        "service": "fastapi",
        "message": "Hello from FastAPI!",
        "container": "docker-fastapi-container",
        "port": 8086
    }

@app.get("/fastapi/{path:path}")
def fastapi_path(path: str):
    return {
        "service": "fastapi",
        "path": f"/{path}",
        "message": "Hello from FastAPI!"
    }
