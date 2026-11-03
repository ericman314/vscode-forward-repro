# VS Code port forwarding truncates responses under parallel load

Responses through a VS Code forwarded port from a dev container are cut
short when many requests run at once. Browsers report
`net::ERR_CONTENT_LENGTH_MISMATCH`. The same requests made without the
forwarder complete.

## Steps

1. Open this folder in VS Code and run **Dev Containers: Reopen in
   Container**.
2. In a VS Code terminal (inside the container), run `./serve.sh`.
3. In a terminal on the host, run `./test.sh`.

## Expected

Every download is 1,000,000 bytes.

## Actual

Some downloads through the forwarded port are truncated. All downloads
made inside the container complete. Observed with VS Code 1.144.1,
Dev Containers 0.469.0, Docker 29.8.1, Ubuntu 26.04 host:

```
Through VS Code forwarded port: 113 complete, 7 truncated
Inside the container (no forwarder): 120 complete, 0 truncated
```

`PARALLEL` (default 40) and `RUNS` (default 3) adjust the load:
`PARALLEL=80 ./test.sh`.
