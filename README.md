# nature-env

A dotenv (`.env`) file parser and loader for [nature-lang](https://nature-lang.org), inspired by [godotenv](https://github.com/joho/godotenv).

## Installation

Add to your `package.toml`:

```toml
[dependencies]
nature_env = { type = "git", version = "v1.0.0", url = "https://github.com/arjendevos/nature-env" }
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
RATE=0.75
ALLOWED_ORIGINS=http://localhost,https://example.com
DB_OPTS=host=localhost,port=5432
```

Load and access your variables:

```nature
import nature_env
import nature_env.env as env

fn main():void! {
    // Load .env file into process environment (panics on failure)
    nature_env.load()

    // Type-safe getters via env module
    var db = env.text('DATABASE_URL')             // string, throws if missing
    var port = env.number('PORT', 8080)           // int with default
    var rate = env.decimal('RATE', 0.5)           // float with default
    var debug = env.boolean('DEBUG')              // bool (true/false/1/0/yes/no)
    var origins = env.array('ALLOWED_ORIGINS')    // ["http://localhost", "https://example.com"]
    var opts = env.dict('DB_OPTS')                // {"host": "localhost", "port": "5432"}

    println(db)
}
```

Or use autoload to skip the explicit `load()` call:

```nature
import nature_env.autoload                        // .env is loaded automatically
import nature_env.env as env

fn main():void {
    var port = env.number('PORT', 8080)
}
```

## API

### Loading & Reading (`import nature_env`)

#### `load(...[string] filenames):void`

Reads env file(s) and sets them in the process environment. **Will not** override variables that already exist. Defaults to `.env` when called with no arguments. **Panics** on failure.

```nature
nature_env.load()                              // loads .env
nature_env.load('.env', '.env.local')          // loads multiple files
```

#### `try_load(...[string] filenames):void!`

Same as `load`, but returns an error instead of panicking.

```nature
nature_env.try_load('.env') catch err {
    println(err.msg())
}
```

#### `overload(...[string] filenames):void`

Same as `load`, but **will** override existing environment variables. **Panics** on failure.

```nature
nature_env.overload('.env.test')
```

#### `try_overload(...[string] filenames):void!`

Same as `overload`, but returns an error instead of panicking.

```nature
nature_env.try_overload('.env.test') catch err {
    println(err.msg())
}
```

#### `read(...[string] filenames):{string:string}!`

Reads env file(s) and returns the key-value pairs as a map **without** setting them in the environment.

```nature
var env_map = nature_env.read('.env')
println(env_map['DATABASE_URL'])
```

#### `unmarshal(string src):{string:string}!`

Parses a dotenv-formatted string and returns the key-value pairs as a map.

```nature
var env_map = nature_env.unmarshal('KEY=value\nOTHER=123')
```

### Type-Safe Getters (`import nature_env.env as env`)

All getters read directly from the process environment (works after `load()` or with any env var).

#### `env.text(string key, ...[string] fallback):string!`

Returns the value as a string. Pass an optional default for when the key is not set.

```nature
var host = env.text('HOST')                    // throws if missing
var host = env.text('HOST', 'localhost')       // returns 'localhost' if missing
```

#### `env.str(string key, ...[string] fallback):string!`

Alias for `env.text`. Returns the value as a string.

```nature
var host = env.str('HOST')                     // throws if missing
var host = env.str('HOST', 'localhost')        // returns 'localhost' if missing
```

#### `env.number(string key, ...[int] fallback):int!`

Returns the value parsed as an integer.

```nature
var port = env.number('PORT')              // throws if missing or not a number
var port = env.number('PORT', 3000)        // returns 3000 if missing
```

#### `env.decimal(string key, ...[float] fallback):float!`

Returns the value parsed as a float.

```nature
var rate = env.decimal('RATE')             // throws if missing
var rate = env.decimal('RATE', 0.5)        // returns 0.5 if missing
```

#### `env.boolean(string key, ...[bool] fallback):bool!`

Returns the value parsed as a boolean. Accepts `true`/`false`, `1`/`0`, `yes`/`no` (case-insensitive).

```nature
var debug = env.boolean('DEBUG')           // throws if missing
var debug = env.boolean('DEBUG', false)    // returns false if missing
```

#### `env.array(string key, ...[string] fallback):[string]!`

Returns the value split by commas with whitespace trimmed. The variadic args serve as the default array.

```nature
// TAGS=api, web, worker  →  ["api", "web", "worker"]
var tags = env.array('TAGS')                      // throws if missing
var tags = env.array('TAGS', 'a', 'b', 'c')      // returns ['a','b','c'] if missing
```

#### `env.dict(string key):{string:string}!`

Parses comma-separated `key=value` pairs into a map.

```nature
// DB_OPTS=host=localhost,port=5432  →  {"host": "localhost", "port": "5432"}
var opts = env.dict('DB_OPTS')
```

### Writing (`import nature_env`)

#### `marshal({string:string} env_map):string`

Converts a map into a dotenv-formatted string. Keys are sorted alphabetically. Integer values are unquoted, all others are double-quoted with escaping.

```nature
{string:string} m = {}
m['PORT'] = '3000'
m['HOST'] = 'localhost'
var output = nature_env.marshal(m)
// HOST="localhost"\nPORT=3000
```

#### `write({string:string} env_map, string filename):void!`

Marshals the map and writes it to a file.

```nature
nature_env.write(m, '.env.output')
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
