# nature-env

A `.env` file parser and loader for the [Nature programming language](https://nature-lang.org).

> **nature-env** brings dotenv support to Nature lang — load, parse, and manage environment variables with type-safe getters.

## Features

- Load `.env` files into the process environment
- Type-safe getters: `string`, `int`, `float`, `bool`, `array`, `dict`
- Variable expansion (`$VAR`, `${VAR}`)
- Single & double quoted values
- Comments, export prefix, and more
- Read, write, marshal, and unmarshal `.env` content

## Installation

Add to your `package.toml`:

```toml
[dependencies]
dotenv = { type = "git", version = "v1.0.6", url = "https://github.com/arjendevos/nature-env" }
```

Then run:

```bash
npkg sync
```

## Quick Start

Create a `.env` file in your project root:

```bash
DATABASE_URL=postgres://localhost/mydb
SECRET_KEY=mysecret
DEBUG=true
PORT=3000
RATE=0.75
ALLOWED_ORIGINS=http://localhost,https://example.com
DB_OPTS=host=localhost,port=5432
```

Load and access your variables:

```n
import dotenv

fn main():void! {
    // Load .env into the process environment (panics on failure)
    dotenv.load()

    // Type-safe getters
    var db      = dotenv.text('DATABASE_URL')          // string — throws if missing
    var port    = dotenv.number('PORT', 8080)           // int with default
    var rate    = dotenv.decimal('RATE', 0.5)           // float with default
    var debug   = dotenv.boolean('DEBUG')               // bool (true/false/1/0/yes/no)
    var origins = dotenv.array('ALLOWED_ORIGINS')       // ["http://localhost", "https://example.com"]
    var opts    = dotenv.dict('DB_OPTS')                // {"host": "localhost", "port": "5432"}

    println(db)
}
```

---

## API Reference

### Loading & Reading

#### `load(...[string] filenames):void`

Loads env file(s) into the process environment. **Does not** override variables that already exist. Defaults to `.env` when called with no arguments. Panics on failure.

```n
dotenv.load()                          // loads .env
dotenv.load('.env', '.env.local')      // loads multiple files
```

#### `overload(...[string] filenames):void`

Same as `load`, but **does** override existing environment variables. Panics on failure.

```n
dotenv.overload('.env.test')
```

#### `read(...[string] filenames):{string:string}!`

Reads env file(s) and returns key-value pairs as a map **without** modifying the environment.

```n
var m = dotenv.read('.env')
println(m['DATABASE_URL'])
```

#### `unmarshal(string src):{string:string}!`

Parses a dotenv-formatted string into a map.

```n
var m = dotenv.unmarshal('KEY=value\nOTHER=123')
```

---

### Type-Safe Getters

All getters read from the process environment. They work after calling `load()` or with any pre-existing env var.

Each getter throws if the key is missing and no default is provided.

#### `text(string key, ...[string] fallback):string!`

Returns the value as a string.

```n
var host = dotenv.text('HOST')                 // throws if missing
var host = dotenv.text('HOST', 'localhost')     // returns 'localhost' if missing
```

#### `str(string key, ...[string] fallback):string!`

Alias for `text`.

```n
var host = dotenv.str('HOST', 'localhost')
```

#### `number(string key, ...[int] fallback):int!`

Returns the value parsed as an integer.

```n
var port = dotenv.number('PORT')           // throws if missing or not a number
var port = dotenv.number('PORT', 3000)     // returns 3000 if missing
```

#### `decimal(string key, ...[float] fallback):float!`

Returns the value parsed as a float.

```n
var rate = dotenv.decimal('RATE')          // throws if missing
var rate = dotenv.decimal('RATE', 0.5)     // returns 0.5 if missing
```

#### `boolean(string key, ...[bool] fallback):bool!`

Returns the value parsed as a boolean. Accepts `true`/`false`, `1`/`0`, `yes`/`no` (case-insensitive).

```n
var debug = dotenv.boolean('DEBUG')        // throws if missing
var debug = dotenv.boolean('DEBUG', false) // returns false if missing
```

#### `array(string key, ...[string] fallback):[string]!`

Splits the value by commas (whitespace trimmed). The variadic args serve as the default array.

```n
// TAGS=api, web, worker  →  ["api", "web", "worker"]
var tags = dotenv.array('TAGS')
var tags = dotenv.array('TAGS', 'a', 'b', 'c')  // default if missing
```

#### `dict(string key, ...[string] fallback):{string:string}!`

Parses comma-separated `key=value` pairs into a map. The optional fallback is a comma-separated string parsed the same way.

```n
// DB_OPTS=host=localhost,port=5432  →  {"host": "localhost", "port": "5432"}
var opts = dotenv.dict('DB_OPTS')
var opts = dotenv.dict('DB_OPTS', 'host=localhost,port=5432')  // default if missing
```

---

### Writing & Serialization

#### `marshal({string:string} env_map):string`

Converts a map into a dotenv-formatted string. Keys are sorted alphabetically. Integer values are unquoted; all others are double-quoted with escaping.

```n
{string:string} m = {}
m['PORT'] = '3000'
m['HOST'] = 'localhost'
var output = dotenv.marshal(m)
// HOST="localhost"\nPORT=3000
```

#### `write({string:string} env_map, string filename):void!`

Marshals the map and writes it to a file.

```n
dotenv.write(m, '.env.output')
```

---

## Supported `.env` Syntax

```bash
# Comments (full-line or inline with a space before #)
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

# Export prefix (stripped automatically)
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
