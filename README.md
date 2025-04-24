# Curlier 📦

The courier for your curl requests.

A minimal, extendable and flexible CLI tool to execute saved requests using curl.

## Usage

Once installed you can run:

```shell
./curlier.sh <request_name>
```

**\*Pro-tip**: Add an alias like `alias curlier=path/to/curlier.sh` into your shell config file\*

All your requests are just `.sh` files that you must store under the `requests/` folder.

This makes curlier really eassy to extend and customize to your needs; request files are just shell scripts so you can make with them whatever you want.

You can configure the default requests directory inside your shell configuration file (ie: .bashrc, .zshrc, etc).

```bash
# In .zshrc, .bashrc, etc.
export CURLIER_REQUESTS_DIR="/path/to/your/custom/requests/dir"
```

> **Note:** if `CURLIER_REQUESTS_DIR` is not set curlier will use the default `./requests/` folder inside the curlier project.

## Flags

There are only three flags available for the moment:

- `--list | -l`: list the available requests inside your `./requests/` folder.
- `--params | -p`: Sends params to the request file as env vars.
- `--widlcard | -w`: Sets a wildcard as an env var which you can use in your request URI.

The `--params` flag can only be used if an available request name is put before the flag and it accepts key/value pairs:

```shell
curlier example --params foo=bar
```

## Request Examples

> **Note:** There are some examples in the `./requests/` folder

The most basic example of a request file is as follows:

```bash
#!/bin/bash

curl -X GET "https://jsonplaceholder.typicode.com/users"
```

You can combine this with whatever you want; for example, you can use `jq` to parse the json response from `jsonplaceholder`.

```bash
#!/bin/bash

curl -X GET "https://jsonplaceholder.typicode.com/users" \
  | jq
```

### Using the `--params` flag

Curlier parses the key/value pairs that follows the params flag and saves them into an string called `URL_PARAMS` which is available as an env bar.

```bash
#!/bin/bash

# curlier example -p id=1
curl -X GET "https://jsonplaceholder.typicode.com/users?${URL_PARAMS}" # this will return the user with id=1 from jsonplaceholder
```

The `--params` flag can store as many key/value pairs as you want and they will be stored in the `URL_PARAMS` string as `foo=bar&baz=qux`.

They also are exported as the name of the key containing the value of it so you can check in your script that every needed param is present (ie: `curlier example -p foo=bar` will return `$foo` which will have a value equal to `bar`).

### Using the `--wildcard` flag

Similarly to the `--params` flag, `--wildcard` parses the key/value pairs that follows the flag and saves them into separate strings called like the key with the value of it.

```bash
#!/bin/bash

# curlier example -w id=30
curl -X GET "https://jsonplaceholder.typicode.com/todos/$id"
```

### Using env vars

Curlier also support the usage of .env files to add secrets to your requests, so you can save your requests in your repository without sharing sensitive information like access tokens.

They can be stored in your `/requests/` folder or in it's child folders if you have specific folders for each of your apis (ie: /requests/project1/.env, /requests/.env, /requests/proyect2/.env, etc).

```bash
#!/bin/bash

curl -X GET "http://localhost:3000/usrs" \
  -H "Authorization: Bearer $token"
```
