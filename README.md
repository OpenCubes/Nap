Nap
===
[![Built with Grunt](https://cdn.gruntjs.com/builtwith.png)](http://gruntjs.com/)

The highly-configurable RESTful HTTP service provider made for Express framework and Mongoose

### Using it

```js

var nap = require('nap');

api = nap(globalOptions);
api.add(modelObject);
api.inject(app);
```

### `globalOptions`

  - [ ] `authGroups`: an array containing all the different groups, ordered for a
    waterfall (last groups inherits the first group autorizations) (ex: `['guest'])

  - [ ] `getRole`: a function called wth two arguments, `userId` the id string,
    number or object corresponding to the current logged user and `callback`
    a function to be called with a string corresponding to the user role

  - [ ] `canThis`: overrides the canThis middleware. Injected a `this` object:
    - `config` the passed config
    - `getRole()` a **Promise** that wraps the `getRole`specified option
    - `deny()` call it to deny access
    - `allow()` the access
    - `url` current url
    - `params` the request params
    - `method` the HTTP method

### `modelObject`

  - [ ] `model` the model name or object
  - [ ] `authorizations` an object where the value is the method (GET, PUT...)
    and the value an array of user roles (cascading). Example:
    - `get: ["guest"]` everybody, from guests to admins will be able to GET
    - `post: ["user"]` only logged users or admins will be able to POST
    - `put: ["admin"]` only admin will be able to do this
  - [ ] `authorship` used when a user PUT his own mod he might be able to edit
    it even though he doesn't have the PUT authorization (see above).
    This is the name of the field that contains the author id.
  - [ ] `indexFields` the fields selected on `GET /{model}`
  - [ ] `dontBreak` don't put the selected fields as a new model
