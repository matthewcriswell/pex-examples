from docker import from_env
from docker.errors import DockerException
import sys

def can_run_docker():
    try:
        # Create a client from the environment (DOCKER_HOST, /var/run/docker.sock, etc.)
        client = from_env()
        # 'ping' will raise if the socket is unreachable or permission is denied.
        client.ping()
        return True, None
    except DockerException as e:
        # Could be: no socket, daemon not running, or permission denied
        return False, str(e)

def main():
    ok, err = can_run_docker()
    if not ok:
        print(f"ERROR: cannot access Docker daemon: {err}", file=sys.stderr)
        sys.exit(1)
    print("✔ Docker SDK can reach the daemon; proceeding…")
    # …rest of your logic…

if __name__ == "__main__":
    main()

