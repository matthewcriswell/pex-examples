# check_runtime_pyw.py

import sys
from python_on_whales import DockerClient, DockerException, ClientNotFoundError

def find_working_runtime():
    """
    Try Docker first, then fallback to nerdctl. Returns (engine_name, client)
    if successful, or raises a RuntimeError if both fail.
    """
    # Each entry is a list representing how to invoke the binary.
    # (python-on-whales will prepend these to every 'docker' command under the hood.)
    candidates = [
        (["docker"], "docker"),
        (["nerdctl"], "nerdctl"),
    ]

    last_error = None
    for client_call, name in candidates:
        try:
            # Create a DockerClient that uses `client_call[0]` (docker or nerdctl)
            client = DockerClient(client_call=client_call)
            # `info()` does exactly: run "{client_call} info" under the hood.
            client.info()
            return name, client
        except DockerException as e:
            # Keep the last exception around for reporting if both fail.
            last_error = e
        except ClientNotFoundError as e:
            last_error = e

    # If we reach here, neither docker nor nerdctl worked:
    raise RuntimeError(f"Could not reach any container runtime: {last_error!r}")

def main():
    try:
        engine_name, client = find_working_runtime()
    except RuntimeError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)

    print(f"✔ {engine_name} is available; proceeding…")
    # At this point, `client` is a DockerClient pointed at either docker or nerdctl.
    # You can continue using `client`, e.g.:
    #
    #   containers = client.container.list()
    #   print("Running containers:", containers)
    #
    # Or for nerdctl specifically:
    #   client.image.pull("alpine")
    #
    # (Behind the scenes, it will run "docker …" or "nerdctl …" accordingly.)

if __name__ == "__main__":
    main()

