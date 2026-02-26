# nature-env

A dotenv (`.env`) file parser and loader for [nature-lang](https://nature-lang.org), inspired by [godotenv](https://github.com/joho/godotenv).

## Installation

Add to your `package.toml`:

```toml
[dependencies]
nature_env = { type = "git", version = "v0.1.0", url = "https://github.com/arjendevos/nature-env" }
```

Then run:

```bash
npkg sync
```

## Usage

Create a `.env` file in your project root:

```
DATABASE_URL=postgres://localhost/mydb
SECRET_KEY=mysecret
DEBUG=true
PORT=3000
```

Load it in your code:

```nature
import nature_env
import libc

fn main():void! {
    // Load .env file into process environment
    nature_env.load([])

    // Access variables via libc.getenv()
    var db = libc.getenv('DATABASE_URL'.to_cstr())
    println(db.to_string())
}
```

## API

### `load([string] filenames):void!`

Reads env file(s) and sets them in the process environment. **Will not** override variables that already exist. Defaults to `[".env"]` when given an empty array.

```nature
nature_env.load([])                          // loads .env
nature_env.load(['.env', '.env.local'])      // loads multiple files
```

### `overload([string] filenames):void!`

Same as `load`, but **will** override existing environment variables.

```nature
nature_env.overload(['.env.test'])
```

### `read([string] filenames):{string:string}!`

Reads env file(s) and returns the key-value pairs as a map **without** setting them in the environment.

```nature
var env_map = nature_env.read(['.env'])
println(env_map['DATABASE_URL'])
```

### `unmarshal(string src):{string:string}!`

Parses a dotenv-formatted string and returns the key-value pairs as a map.

```nature
var env_map = nature_env.unmarshal('KEY=value\nOTHER=123')
```

### `marshal({string:string} env_map):string`

Converts a map of key-value pairs into a dotenv-formatted string. Keys are sorted alphabetically. Integer values are unquoted, all others are double-quoted with escaping.

```nature
{string:string} env = {}
env['PORT'] = '3000'
env['HOST'] = 'localhost'
var output = nature_env.marshal(env)
// HOST="localhost"\nPORT=3000
```

### `write({string:string} env_map, string filename):void!`

Marshals the map and writes it to a file.

```nature
nature_env.write(env, '.env.output')
```

## Supported .env Syntax

```bash
# Comments (full line or inline with space before #)
KEY=value
KEY=value # inline comment

# Quoted values
SINGLE='preserves $literal \n content'
DOUBLE="expands\nnewlines and $VARIABLES"

# Variable expansion (double-quoted or unquoted)
BASE=/usr/local
PATH=${BASE}/bin
ALT=$BASE/bin
PAREN=$(BASE)/lib

# Export prefix (stripped)
export SECRET=abc123

# Empty values
EMPTY=
ALSO_EMPTY=""

# Integer values
PORT=3000

# Colon separator
KEY:value
```

## Running Tests

```bash
cd tests
./run_tests.sh
```

## License

MIT
