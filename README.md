# Curlier 📦

The courier for your `curl` requests.

A minimal, extensible, and flexible CLI tool to execute saved requests using `curl`.

## Features

- Minimal and flexible by design
- Easily extensible via shell scripting
- Supports .env files for secure secret management
- Flag-based interface for easy scripting

## Usage

Once installed you can run:

```shell
./curlier.sh <request_name>
```

**\*💡Pro-tip**: Add an alias like `alias curlier=path/to/curlier.sh` into your shell config file\*

All your requests are just `.sh` files that must be stored under the `requests/` folder.

This makes Curlier really easy to extend and customize to your needs; request files are just shell scripts so you can do whatever you want with them.

You can configure the default requests directory in your shell configuration file:

```bash
# In .zshrc, .bashrc, etc.
export CURLIER_REQUESTS_DIR="/path/to/your/custom/requests/dir"
```

> **Note:** if `CURLIER_REQUESTS_DIR` is not set, Curlier will use the default `./requests/` folder inside the curlier project.

## Flags

There are currently three available flags:

- `--list | -l`: List the available requests inside your `./requests/` folder.
- `--params | -p`: Sends params to the request file as environment variables.
- `--widlcard | -w`: Sets a wildcard as an environment variable which you can use in your request URI.

Both the `--wildcard` and `--params` flags must follow an existing request name and accepts key-value pairs:

```shell
curlier example --params foo=bar
```

## Request Examples

> **Note:** Some examples in the `./requests/` folder

The most basic example of a request file is:

```bash
#!/bin/bash

curl -X GET "https://jsonplaceholder.typicode.com/users"
```

You can combine this with other tools like `jq` to parse the JSON response:

```bash
#!/bin/bash

curl -X GET "https://jsonplaceholder.typicode.com/users" \
  | jq
```

### Using the `--params` flag

Curlier parses the key-value pairs provided to the `--params` flag and stores them into an string called `URL_PARAMS`, available as an environment variable.

```bash
#!/bin/bash

# curlier example -p id=1
curl -X GET "https://jsonplaceholder.typicode.com/users?${URL_PARAMS}" # this will return the user with id=1
```

The `--params` flag can store as many key-value pairs as needed, formatted like `foo=bar&baz=qux` in `URL_PARAMS`.

Each key is also exported as a standalone environment variable. For example, `curlier example -p foo=bar` makes `$foo` available with the value `bar`.

### Using the `--wildcard` flag

Similarly, `--wildcard` parses key-value pairs and exports each as its own environment variable.

```bash
#!/bin/bash

# curlier example -w id=30
curl -X GET "https://jsonplaceholder.typicode.com/todos/$id"
```

### Using env vars

Curlier supports `.env` files to securely manage secrets in your requests. This allows you to commit requests to your repository without exposing sensitive data like access tokens.

You can place them in the `/requests/` folder folder or in subdirectories (e.g., `/requests/project1/.env`, `/requests/.env`, `/requests/project2/.env`, etc.).

```bash
#!/bin/bash

curl -X GET "http://localhost:3000/usrs" \
  -H "Authorization: Bearer $token"
```

## License

MIT © 2025 Facundo Carbonel
