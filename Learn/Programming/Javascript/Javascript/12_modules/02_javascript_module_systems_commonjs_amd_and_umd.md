## JavaScript Module Systems: CommonJS, AMD, and UMD


### Evolution of JavaScript Modules

JavaScript originally lacked a native module system, leading developers to create various patterns to organize code as applications grew more complex. These module systems emerged to solve scope isolation, dependency management, and code organization problems.

### The Problem Modules Solve

Before modules, JavaScript faced several challenges:

- Global namespace pollution
- Dependency management difficulties
- Code organization issues
- Loading and execution order problems
- Code reuse limitations

### CommonJS Modules

CommonJS emerged as a server-side module specification initially designed for Node.js environments.

#### Core Concepts

- Synchronous module loading
- Server-first design
- File-based modules with local scope
- Simple syntax for imports and exports

#### Basic Syntax

```javascript
// Importing a module
const express = require('express');
const { join } = require('path');

// Exporting from a module
module.exports = function calculator() {
  // Implementation
};

// Alternative export syntax
exports.add = function(a, b) {
  return a + b;
};
```

#### How CommonJS Works

When a module is required in CommonJS:

1. Node.js resolves the module path
2. If the module has been previously loaded, its cached exports are returned
3. Otherwise, the module code is executed in an isolated scope
4. The `module.exports` object is populated
5. The completed `module.exports` object is cached and returned

#### Module Resolution Algorithm

CommonJS modules in Node.js are resolved in this order:

1. Core modules (like `fs`, `path`)
2. File paths (starting with `./` or `../`)
3. Node modules in `node_modules` directories (traversing up the directory tree)

```javascript
// core module
const fs = require('fs');

// relative file path
const utils = require('./utils');

// node_modules package
const lodash = require('lodash');
```

#### Circular Dependencies in CommonJS

CommonJS handles circular dependencies through partial exports:

```javascript
// a.js
console.log('a starting');
exports.done = false;
const b = require('./b');
console.log('in a, b.done =', b.done);
exports.done = true;
console.log('a done');

// b.js
console.log('b starting');
exports.done = false;
const a = require('./a');
console.log('in b, a.done =', a.done);
exports.done = true;
console.log('b done');

/* Output when requiring a.js first:
a starting
b starting
in b, a.done = false
b done
in a, b.done = true
a done
*/
```

### AMD (Asynchronous Module Definition)

AMD was designed for browser environments where asynchronous loading is crucial for performance.

#### Core Concepts

- Asynchronous module loading
- Browser-first design
- Non-blocking script loading
- Callback-based execution

#### Basic Syntax

```javascript
// Defining a module
define('myModule', ['jquery', 'underscore'], function($, _) {
  // Module implementation
  function privateMethod() {
    // Private functionality
  }
  
  return {
    // Public API
    publicMethod: function() {
      privateMethod();
      return 'result';
    }
  };
});

// Using a module
require(['myModule'], function(myModule) {
  myModule.publicMethod();
});
```

#### How AMD Works

1. The AMD loader (like RequireJS) manages module definitions
2. Dependencies are loaded asynchronously in parallel
3. When all dependencies are loaded, the factory function executes
4. The returned value becomes the module's exports
5. Callbacks waiting for the module are executed

#### Simplified Module Definition

AMD also supports a simplified syntax for modules without dependencies:

```javascript
define(function() {
  return {
    hello: function(name) {
      return "Hello, " + name;
    }
  };
});
```

#### AMD with Named Modules

```javascript
// Named module definition
define('utils/math', [], function() {
  return {
    add: function(a, b) { return a + b; },
    subtract: function(a, b) { return a - b; }
  };
});

// Using named modules
require(['utils/math'], function(math) {
  console.log(math.add(5, 3)); // 8
});
```

### UMD (Universal Module Definition)

UMD emerged as a pattern to create modules that work in multiple environments.

#### Core Concepts

- Works in multiple environments (Node.js, AMD, browser globals)
- Detects the available module system
- Falls back to browser globals if no module system is available
- Compatible with both CommonJS and AMD

#### Basic Pattern

```javascript
(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD
    define(['jquery'], factory);
  } else if (typeof module === 'object' && module.exports) {
    // CommonJS
    module.exports = factory(require('jquery'));
  } else {
    // Browser globals
    root.myModule = factory(root.jQuery);
  }
}(typeof self !== 'undefined' ? self : this, function($) {
  // Module implementation
  function myModule() {
    // ...
  }
  
  return myModule;
}));
```

#### How UMD Works

UMD uses feature detection to determine the environment:

1. Checks if AMD's `define` is available
2. Otherwise checks if CommonJS's `module.exports` is available
3. If neither, falls back to creating a global variable

#### UMD for Library Authors

Library authors commonly use UMD to maximize compatibility:

```javascript
// UMD template for library authors
(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as an anonymous module.
    define(['dependency1', 'dependency2'], factory);
  } else if (typeof module === 'object' && module.exports) {
    // Node. Does not work with strict CommonJS, but
    // only CommonJS-like environments that support module.exports,
    // like Node.
    module.exports = factory(require('dependency1'), require('dependency2'));
  } else {
    // Browser globals (root is window)
    root.returnExports = factory(root.dependency1, root.dependency2);
  }
}(typeof self !== 'undefined' ? self : this, function(dependency1, dependency2) {
  // Module implementation
  return {
    // Public API
    method1: function() {},
    method2: function() {}
  };
}));
```

### Comparing Module Systems

#### CommonJS vs AMD

**CommonJS:**

- Synchronous loading (better for server)
- Simpler syntax
- Widely used in Node.js
- Default for many npm packages

**AMD:**

- Asynchronous loading (better for browser)
- More verbose syntax
- Better for client-side applications
- Manages dependencies through callbacks

#### When to Use Each System

**Use CommonJS when:**

- Building Node.js applications
- Using a bundler like Webpack in browser apps
- Simplicity is a priority
- Server-side rendering is involved

**Use AMD when:**

- Legacy browser support is required
- Avoiding a build step for browser apps
- Dynamic loading of modules is needed
- Using RequireJS ecosystem

**Use UMD when:**

- Creating libraries for multiple environments
- Supporting both Node.js and browsers
- Maximum compatibility is needed
- Publishing to npm and CDNs simultaneously

### Implementation Examples

#### CommonJS Example: A Calculator Module

```javascript
// calculator.js
function add(a, b) {
  return a + b;
}

function subtract(a, b) {
  return a - b;
}

function multiply(a, b) {
  return a * b;
}

function divide(a, b) {
  if (b === 0) {
    throw new Error('Division by zero');
  }
  return a / b;
}

module.exports = {
  add,
  subtract,
  multiply,
  divide
};

// usage.js
const calculator = require('./calculator');

console.log(calculator.add(5, 3));       // 8
console.log(calculator.subtract(5, 3));  // 2
console.log(calculator.multiply(5, 3));  // 15
console.log(calculator.divide(6, 3));    // 2
```

#### AMD Example: A Data Service

```javascript
// dataService.js
define(['jquery', 'config'], function($, config) {
  var apiUrl = config.apiBaseUrl + '/data';
  
  return {
    fetchItems: function() {
      return $.ajax({
        url: apiUrl,
        method: 'GET',
        dataType: 'json'
      });
    },
    
    saveItem: function(item) {
      return $.ajax({
        url: apiUrl,
        method: 'POST',
        data: JSON.stringify(item),
        contentType: 'application/json'
      });
    }
  };
});

// app.js
require(['dataService'], function(dataService) {
  dataService.fetchItems()
    .then(function(items) {
      console.log('Items loaded:', items);
    })
    .catch(function(error) {
      console.error('Failed to load items:', error);
    });
});
```

#### UMD Example: A Utility Library

```javascript
// stringUtils.js
(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD
    define([], factory);
  } else if (typeof module === 'object' && module.exports) {
    // CommonJS
    module.exports = factory();
  } else {
    // Browser globals
    root.stringUtils = factory();
  }
}(typeof self !== 'undefined' ? self : this, function() {
  
  return {
    capitalize: function(str) {
      if (typeof str !== 'string' || !str) return '';
      return str.charAt(0).toUpperCase() + str.slice(1);
    },
    
    reverse: function(str) {
      if (typeof str !== 'string') return '';
      return str.split('').reverse().join('');
    },
    
    truncate: function(str, length, suffix) {
      if (typeof str !== 'string') return '';
      suffix = suffix || '...';
      length = length || 30;
      
      if (str.length <= length) return str;
      return str.substr(0, length - suffix.length) + suffix;
    }
  };
}));

// Usage in browser
console.log(stringUtils.capitalize('hello'));  // "Hello"

// Usage in Node.js
const stringUtils = require('./stringUtils');
console.log(stringUtils.reverse('hello'));  // "olleh"

// Usage with AMD
define(['./stringUtils'], function(stringUtils) {
  console.log(stringUtils.truncate('This is a long string', 10));  // "This is..."
});
```

### Dynamic Module Loading

#### CommonJS Dynamic Loading

```javascript
function loadModule(moduleName) {
  try {
    const module = require(moduleName);
    return module;
  } catch (error) {
    console.error(`Failed to load module ${moduleName}:`, error);
    return null;
  }
}

const format = process.env.FORMAT || 'json';
const parser = loadModule(`./parsers/${format}-parser`);

if (parser) {
  parser.parse(data);
}
```

#### AMD Dynamic Loading

```javascript
function loadFeature(featureName) {
  require([`features/${featureName}`], function(feature) {
    feature.initialize();
  }, function(error) {
    console.error(`Failed to load feature ${featureName}:`, error);
  });
}

// Load features based on user permissions
if (user.hasPermission('admin')) {
  loadFeature('admin-panel');
}
```

### Module Bundling with CommonJS and AMD

#### Webpack Configuration for CommonJS

```javascript
// webpack.config.js
module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: __dirname + '/dist'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      }
    ]
  }
};
```

#### RequireJS Configuration for AMD

```javascript
// require.config.js
requirejs.config({
  baseUrl: 'js',
  paths: {
    'jquery': 'lib/jquery.min',
    'underscore': 'lib/underscore.min',
    'backbone': 'lib/backbone.min'
  },
  shim: {
    'backbone': {
      deps: ['underscore', 'jquery'],
      exports: 'Backbone'
    }
  }
});

// Start the main app logic
requirejs(['app/main'], function(main) {
  main.initialize();
});
```

### Modern JavaScript Modules (ES Modules)

ES Modules (ESM) are now the standard but coexist with older systems:

```javascript
// Importing in ES Modules
import express from 'express';
import { join } from 'path';

// Exporting in ES Modules
export function add(a, b) {
  return a + b;
}

export default function calculator() {
  // Implementation
}
```

#### Interoperability with CommonJS and AMD

```javascript
// Importing a CommonJS module in ESM
import pkg from 'lodash';
const { pick, omit } = pkg;

// Using import() for dynamic imports (works with CommonJS/AMD modules)
async function loadModule(moduleName) {
  try {
    const module = await import(moduleName);
    return module.default || module;
  } catch (error) {
    console.error(`Failed to load module ${moduleName}:`, error);
    return null;
  }
}
```

### Real-World Module Patterns

#### CommonJS Plugin System

```javascript
// plugin-manager.js
class PluginManager {
  constructor() {
    this.plugins = {};
  }
  
  register(name, plugin) {
    if (this.plugins[name]) {
      throw new Error(`Plugin "${name}" is already registered`);
    }
    this.plugins[name] = plugin;
    return this;
  }
  
  loadPlugin(name) {
    try {
      const plugin = require(`./plugins/${name}`);
      this.register(name, plugin);
    } catch (error) {
      console.error(`Failed to load plugin ${name}:`, error);
    }
  }
  
  getPlugin(name) {
    return this.plugins[name] || null;
  }
}

module.exports = new PluginManager();

// usage
const pluginManager = require('./plugin-manager');
pluginManager.loadPlugin('logger');
const logger = pluginManager.getPlugin('logger');
logger.log('Hello, world!');
```

#### AMD Module Dependencies

```javascript
// viewModel.js
define([
  'knockout', 
  'services/userService', 
  'services/dataService',
  'utils/formatter'
], function(ko, userService, dataService, formatter) {
  
  function ViewModel() {
    this.user = ko.observable();
    this.items = ko.observableArray([]);
    this.formattedTotal = ko.computed(function() {
      return formatter.currency(this.calculateTotal());
    }, this);
  }
  
  ViewModel.prototype.initialize = function() {
    const self = this;
    
    userService.getCurrentUser()
      .then(function(user) {
        self.user(user);
        return dataService.getItemsForUser(user.id);
      })
      .then(function(items) {
        self.items(items);
      });
  };
  
  ViewModel.prototype.calculateTotal = function() {
    return this.items().reduce(function(total, item) {
      return total + item.price;
    }, 0);
  };
  
  return ViewModel;
});
```

#### UMD Library with Plugin Architecture

```javascript
// myLibrary.js
(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    define([], factory);
  } else if (typeof module === 'object' && module.exports) {
    module.exports = factory();
  } else {
    root.MyLibrary = factory();
  }
}(typeof self !== 'undefined' ? self : this, function() {
  
  var MyLibrary = {
    version: '1.0.0',
    plugins: {},
    
    registerPlugin: function(name, plugin) {
      if (this.plugins[name]) {
        throw new Error(`Plugin "${name}" already registered`);
      }
      this.plugins[name] = plugin;
      return this;
    },
    
    use: function(pluginName, options) {
      const plugin = this.plugins[pluginName];
      
      if (!plugin) {
        throw new Error(`Plugin "${pluginName}" not found`);
      }
      
      if (typeof plugin.init === 'function') {
        plugin.init(this, options);
      }
      
      return this;
    }
  };
  
  return MyLibrary;
}));

// Plugin example
(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    define(['myLibrary'], factory);
  } else if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('./myLibrary'));
  } else {
    factory(root.MyLibrary);
  }
}(typeof self !== 'undefined' ? self : this, function(MyLibrary) {
  
  var LoggerPlugin = {
    init: function(lib, options) {
      options = options || {};
      this.level = options.level || 'info';
      this.prefix = options.prefix || '';
      
      // Extend library with logging methods
      lib.log = this.log.bind(this);
      lib.warn = this.warn.bind(this);
      lib.error = this.error.bind(this);
    },
    
    log: function(message) {
      if (['debug', 'info', 'warn', 'error'].indexOf(this.level) >= 0) {
        console.log(`${this.prefix}${message}`);
      }
    },
    
    warn: function(message) {
      if (['warn', 'error'].indexOf(this.level) >= 0) {
        console.warn(`${this.prefix}${message}`);
      }
    },
    
    error: function(message) {
      if (['error'].indexOf(this.level) >= 0) {
        console.error(`${this.prefix}${message}`);
      }
    }
  };
  
  // Register plugin with library
  MyLibrary.registerPlugin('logger', LoggerPlugin);
  
  return LoggerPlugin;
}));

// Usage
MyLibrary.use('logger', { level: 'info', prefix: '[MyLib] ' });
MyLibrary.log('Application initialized');
```

### Migration Strategies

#### From CommonJS to ES Modules

```javascript
// Original CommonJS
const fs = require('fs');
const path = require('path');

function readConfig(configPath) {
  const fullPath = path.resolve(configPath);
  return JSON.parse(fs.readFileSync(fullPath, 'utf8'));
}

module.exports = {
  readConfig
};

// Migrated to ES Modules
import fs from 'fs';
import path from 'path';

function readConfig(configPath) {
  const fullPath = path.resolve(configPath);
  return JSON.parse(fs.readFileSync(fullPath, 'utf8'));
}

export { readConfig };
```

#### From AMD to CommonJS/ES Modules

```javascript
// Original AMD
define(['jquery', 'utils/formatter'], function($, formatter) {
  function DataTable(element, options) {
    this.element = $(element);
    this.options = options || {};
    this.init();
  }
  
  DataTable.prototype.init = function() {
    // Initialize table
  };
  
  DataTable.prototype.formatCurrency = function(value) {
    return formatter.currency(value);
  };
  
  return DataTable;
});

// Migrated to CommonJS
const $ = require('jquery');
const formatter = require('./utils/formatter');

function DataTable(element, options) {
  this.element = $(element);
  this.options = options || {};
  this.init();
}

DataTable.prototype.init = function() {
  // Initialize table
};

DataTable.prototype.formatCurrency = function(value) {
  return formatter.currency(value);
};

module.exports = DataTable;

// Migrated to ES Modules
import $ from 'jquery';
import * as formatter from './utils/formatter';

class DataTable {
  constructor(element, options) {
    this.element = $(element);
    this.options = options || {};
    this.init();
  }
  
  init() {
    // Initialize table
  }
  
  formatCurrency(value) {
    return formatter.currency(value);
  }
}

export default DataTable;
```

**Conclusion**  

**Key Points:**

- CommonJS provides a simple, synchronous module system ideal for server environments
- AMD offers asynchronous loading optimized for browsers and client-side applications
- UMD creates universal modules compatible with multiple environments
- Modern applications are increasingly adopting ES Modules as the standard
- Understanding these module systems remains important for legacy code maintenance

Related topics to explore include bundlers (Webpack, Rollup, Parcel), ES Module features (dynamic imports, module workers), and module federation for micro-frontends.

---

