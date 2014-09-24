# TOC
   - [API](#api)
   - [bare hypermedia formatter](#bare-hypermedia-formatter)
   - [module](#module)
   - [Model](#model)
     - [#find()](#model-find)
       - [where](#model-find-where)
     - [#findById()](#model-findbyid)
     - [#set()](#model-set)
     - [#delete()](#model-delete)
   - [server](#server)
   - [SubModel](#submodel)
     - [#find()](#submodel-find)
       - [where](#submodel-find-where)
     - [#findById()](#submodel-findbyid)
     - [#create()](#submodel-create)
     - [#set()](#submodel-set)
     - [#delete()](#submodel-delete)
   - [authorizations](#authorizations)
     - [guests](#authorizations-guests)
     - [users](#authorizations-users)
     - [admins](#authorizations-admins)
<a name=""></a>
 
<a name="api"></a>
# API
have a `add` function.

```js
return API.add.should.be.a('function');
```

should add new routes to the stack.

```js
var result;
result = API.add({
  model: 'Story'
});
result.should.equal(1);
result = API.add({
  model: 'User'
});
return result.should.equal(2);
```

should inject routes to the router.

```js
var expected, routerMock, routes, uri, _i, _len;
routes = {};
routerMock = {
  get: function(url, mw2, mw3, route) {
    return routes["GET " + url] = route;
  },
  post: function(url, mw, mw2, mw3, route) {
    return routes["POST " + url] = route;
  },
  "delete": function(url, mw2, mw3, route) {
    return routes["DELETE " + url] = route;
  },
  put: function(url, mw, mw2, mw3, route) {
    return routes["PUT " + url] = route;
  }
};
API.inject(routerMock, function() {});
expected = ["GET /api/stories", "GET /api/stories/:id", "GET /api/stories/:id/:collection", "PUT /api/stories/:id", "DELETE /api/stories/:id", "POST /api/stories", "GET /api/users", "GET /api/users/:id", "GET /api/users/:id/:collection", "PUT /api/users/:id", "DELETE /api/users/:id", "POST /api/users"];
for (_i = 0, _len = expected.length; _i < _len; _i++) {
  uri = expected[_i];
  if (!routes[uri]) {
    console.log(uri);
  }
  should.exist(routes[uri]);
  routes[uri].should.be.a('function');
}
return Object.keys(routes).should.have.length(expected.length);
```

<a name="bare-hypermedia-formatter"></a>
# bare hypermedia formatter
should return json data bare.

```js
var houses;
houses = {
  lannister: ['Tywin', 'Cersei', 'Tyrion', 'Jaimie'],
  baratheon: ['Robert', 'Renly', 'Stannis'],
  stark: ['Ned', 'Catelyn', 'Sansa', 'Robb', 'Bran', 'Rickon']
};
return bare(houses).should.deep.equal(houses);
```

<a name="module"></a>
# module
returns a function.

```js
return scapegoat.should.be.a('function');
```

<a name="model"></a>
# Model
is a constructor .

```js
return Model.should.be.a('function');
```

can mount fixtures.

```js
return FS.read('test/fixtures.json').then(function(data) {
  var fixture, fixtures, promises, _i, _j, _len, _len1, _ref, _ref1;
  fixtures = JSON.parse(data);
  promises = [];
  _ref = fixtures.users;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    fixture = _ref[_i];
    promises.push(User.create(fixture));
  }
  _ref1 = fixtures.stories;
  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
    fixture = _ref1[_j];
    promises.push(Story.create(fixture));
  }
  return Q.allSettled(promises);
}).then(function() {
  return done();
}).fail(done);
```

<a name="model-find"></a>
## #find()
supports no parameter.

```js
this.timeout(5000);
return Story.find({}, true, user).then(function(stories) {
  stories.should.have.length(12);
  return done();
});
```

supports `sort` parameter.

```js
return Story.find({
  sort: "likes"
}, true, user).then(function(stories) {
  var oldLikeCount, s, _i, _len;
  oldLikeCount = 0;
  for (_i = 0, _len = stories.length; _i < _len; _i++) {
    s = stories[_i];
    oldLikeCount.should.be.at.most(s.likes);
    oldLikeCount = s.likes;
  }
  return done();
}).fail(done);
```

supports `limit` parameter.

```js
return Story.find({
  limit: 3
}, true, user).then(function(stories) {
  stories.should.have.length(3);
  return done();
}).fail(done);
```

supports `skip` parameter.

```js
return Story.find({
  offset: 3
}, true, user).then(function(stories) {
  stories.should.have.length(9);
  return done();
}).fail(done);
```

supports `select` parameter.

```js
return Story.find({
  select: 'likes'
}, true, user).then(function(stories) {
  var s, _i, _len;
  stories.should.have.length(12);
  for (_i = 0, _len = stories.length; _i < _len; _i++) {
    s = stories[_i];
    should.not.exist(s.title);
    should.not.exist(s.body);
    should.exist(s.likes);
  }
  return Story.find({
    select: '-likes'
  });
}).then(function(stories) {
  var s, _i, _len;
  stories.should.have.length(12);
  for (_i = 0, _len = stories.length; _i < _len; _i++) {
    s = stories[_i];
    should.exist(s.title);
    should.exist(s.body);
    should.not.exist(s.likes);
  }
  return done();
}).fail(done);
```

<a name="model-find-where"></a>
### where
supports `=`.

```js
return Story.find({
  likes: '7'
}, true, user).then(function(stories) {
  stories.should.have.length(2);
  stories.should.all.have.property('likes', 7);
  return done();
}).fail(done);
```

supports `<`.

```js
return Story.find({
  likes: '<7'
}, true, user).then(function(stories) {
  var story, _i, _len;
  stories.should.have.length(2);
  for (_i = 0, _len = stories.length; _i < _len; _i++) {
    story = stories[_i];
    story.likes.should.be.below(7);
  }
  return done();
}).fail(done);
```

supports `<=`.

```js
return Story.find({
  likes: '<=7'
}, true, user).then(function(stories) {
  var story, _i, _len;
  stories.should.have.length(4);
  for (_i = 0, _len = stories.length; _i < _len; _i++) {
    story = stories[_i];
    story.likes.should.be.most(7);
  }
  return done();
}).fail(done);
```

supports `>`.

```js
return Story.find({
  likes: '>7'
}, true, user).then(function(stories) {
  var story, _i, _len;
  stories.should.have.length(8);
  for (_i = 0, _len = stories.length; _i < _len; _i++) {
    story = stories[_i];
    story.likes.should.be.above(7);
  }
  return done();
}).fail(done);
```

supports `>=`.

```js
return Story.find({
  likes: '>=7'
}, true, user).then(function(stories) {
  var story, _i, _len;
  stories.should.have.length(10);
  for (_i = 0, _len = stories.length; _i < _len; _i++) {
    story = stories[_i];
    story.likes.should.be.least(7);
  }
  someModel = stories[0];
  return done();
}).fail(done);
```

<a name="model-findbyid"></a>
## #findById()
supports finding one doc.

```js
return Story.findById(someModel._id, true, user).then(function(other) {
  other._id.toString().should.equal(someModel._id.toString());
  other.likes.should.equal(someModel.likes);
  other.title.should.equal(someModel.title);
  other.body.should.equal(someModel.body);
  return done();
}).fail(done);
```

supports finding one doc with `select`.

```js
return Story.findById(someModel._id, {
  select: 'likes'
}).then(function(other) {
  other._id.toString().should.equal(someModel._id.toString());
  other.likes.should.equal(someModel.likes);
  should.not.exist(other.title);
  should.not.exist(other.body);
  return done();
}).fail(done);
```

<a name="model-set"></a>
## #set()
can set some properties.

```js
return Story.set(someModel._id, {
  likes: 2e3,
  title: "King's Landing"
}, true, user).then(function(result) {
  result.likes.should.equal(2e3);
  result.title.should.equal("King's Landing");
  result._id.toString().should.equal(someModel._id.toString());
  return Story.findById(someModel._id, true, user);
}).then(function(result) {
  result.likes.should.equal(2e3);
  result.title.should.equal("King's Landing");
  result._id.toString().should.equal(someModel._id.toString());
  return done();
}).fail(done);
```

<a name="model-delete"></a>
## #delete()
can delete a mod.

```js
return Story["delete"](someModel._id, true, user).then(function() {
  return Story.findById(someModel._id);
}).then(function(story) {
  should.not.exist(story);
  return done();
}).fail(done);
```

<a name="server"></a>
# server
GET / should return `hello world`.

```js
return request.get('/').expect('hello world').expect(200, done);
```

should POST fixtures to stories.

```js
this.timeout(5000);
mongoose.connection.db.dropDatabase();
return FS.read('test/fixtures02.json').then(function(data) {
  var createObject, fixture, promises, _i, _len, _ref;
  fixtures = JSON.parse(data);
  promises = [];
  createObject = function(collection, data) {
    var deferred, req;
    deferred = Q.defer();
    req = request.post("/api/" + collection);
    req.send(data);
    req.end(function(err, res) {
      if (err) {
        return deferred.reject(err);
      }
      if (res.statusCode !== 200) {
        return deferred.reject(new Error("Status code #" + res.statusCode));
      }
      return deferred.resolve(res);
    });
    return deferred.promise;
  };
  _ref = fixtures.stories;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    fixture = _ref[_i];
    promises.push(createObject("stories", fixture));
  }
  return Q.allSettled(promises);
}).then(function(results) {
  var r, _i, _len;
  for (_i = 0, _len = results.length; _i < _len; _i++) {
    r = results[_i];
    if (r.status !== 'fulfilled') {
      return done(r.reason);
    }
  }
  return done();
}).fail(done);
```

should GET stories.

```js
return request.get('/api/stories').end(function(err, res) {
  var story, _i, _len, _ref;
  try {
    res.statusCode.toString().should.equal("200");
    res.body.should.have.length(fixtures.stories.length);
    _ref = res.body;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      story = _ref[_i];
      should.exist(story.title);
      should.exist(story.body);
      should.exist(story.likes);
    }
    someModel = res.body[0];
    return done();
  } catch (error) {
    return done(error);
  }
});
```

should GET stories, filter and sort the via query.

```js
this.timeout(5000);
return request.get('/api/stories?select=title&limit=2').end(function(err, res) {
  var story, _i, _len, _ref;
  try {
    res.statusCode.toString().should.equal("200");
    res.body.should.have.length(2);
    _ref = res.body;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      story = _ref[_i];
      should.exist(story.title);
      should.not.exist(story.body);
      should.not.exist(story.likes);
    }
    return request.get("/api/stories?likes=>=11").end(function(err, res) {
      var _j, _len1, _ref1;
      res.statusCode.toString().should.equal("200");
      res.body.should.have.length(3);
      _ref1 = res.body;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        story = _ref1[_j];
        should.exist(story.title);
        should.exist(story.body);
        should.exist(story.likes);
        story.likes.should.be.at.least(11);
      }
      return done();
    });
  } catch (error) {
    return done(error);
  }
});
```

should GET a single story.

```js
return request.get("/api/stories/" + someModel._id).end(function(err, res) {
  try {
    res.statusCode.toString().should.equal("200");
    res.body.should.deep.equal(someModel);
    return done();
  } catch (error) {
    return done(error);
  }
});
```

should PUT a story.

```js
return request.put("/api/stories/" + someModel._id).send({
  title: "Another title"
}).end(function(err, res) {
  try {
    res.statusCode.toString().should.equal("200");
    res.body.title.should.equal("Another title");
    return request.get("/api/stories/" + someModel._id).end(function(err, res) {
      try {
        res.statusCode.toString().should.equal("200");
        res.body.title.should.equal("Another title");
        return done();
      } catch (error) {
        return done(error);
      }
    });
  } catch (error) {
    return done(error);
  }
});
```

should DELETE a story.

```js
return request["delete"]("/api/stories/" + someModel._id).end(function(err, res) {
  try {
    res.statusCode.toString().should.equal("200");
    return request.get("/api/stories/" + someModel._id).end(function(err, res) {
      try {
        res.statusCode.toString().should.equal("200");
        res.body.should.deep.equal({});
        return done();
      } catch (error) {
        return done(error);
      }
    });
  } catch (error) {
    return done(error);
  }
});
```

<a name="submodel"></a>
# SubModel
is a constructor .

```js
return Model.should.be.a('function');
```

can mount fixtures.

```js
return FS.read('test/fixtures03.json').then(function(data) {
  var fixture, fixtures, promises, _i, _len, _ref;
  fixtures = JSON.parse(data);
  promises = [];
  _ref = fixtures.tickets;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    fixture = _ref[_i];
    promises.push(Ticket.create(fixture));
  }
  return Q.allSettled(promises);
}).then(function() {
  return done();
}).fail(done);
```

<a name="submodel-find"></a>
## #find()
supports no parameter.

```js
this.timeout(5000);
return Comment.find({
  ticket: aTicket._id
}, true, user).then(function(comments) {
  comments.should.have.length(2);
  return done();
}).fail(done);
```

supports `sort` parameter.

```js
return Comment.find({
  sort: "upvotes",
  ticket: aTicket._id
}, true, user).then(function(comments) {
  var comment, oldUpvotes, _i, _len;
  oldUpvotes = 0;
  for (_i = 0, _len = comments.length; _i < _len; _i++) {
    comment = comments[_i];
    oldUpvotes.should.be.at.most(comment.upvotes);
    oldUpvotes = comment.upvotes;
  }
  return done();
}).fail(done);
```

supports `limit` parameter.

```js
return Comment.find({
  limit: 1,
  ticket: aTicket._id
}, true, user).then(function(stories) {
  stories.should.have.length(1);
  return done();
}).fail(done);
```

supports `skip` parameter.

```js
return Comment.find({
  offset: 1,
  ticket: aTicket._id
}, true, user).then(function(stories) {
  stories.should.have.length(1);
  return done();
}).fail(done);
```

supports `select` parameter.

```js
return Comment.find({
  select: 'upvotes',
  ticket: aTicket._id
}, true, user).then(function(comments) {
  var comment, _i, _len;
  comments.should.have.length(2);
  for (_i = 0, _len = comments.length; _i < _len; _i++) {
    comment = comments[_i];
    should.not.exist(comment.title);
    should.not.exist(comment.downvotes);
    should.exist(comment.upvotes);
  }
  return Comment.find({
    select: '-upvotes',
    ticket: aTicket._id
  });
}).then(function(comments) {
  var comment, _i, _len;
  comments.should.have.length(2);
  for (_i = 0, _len = comments.length; _i < _len; _i++) {
    comment = comments[_i];
    should.exist(comment.body);
    should.exist(comment.downvotes);
    should.not.exist(comment.upvotes);
  }
  return done();
}).fail(done);
```

<a name="submodel-find-where"></a>
### where
supports `=`.

```js
return Comment.find({
  upvotes: '2',
  ticket: aTicket._id
}, true, user).then(function(comments) {
  comments.should.have.length(1);
  comments.should.all.have.property('upvotes', 2);
  return done();
}).fail(done);
```

supports `<`.

```js
return Comment.find({
  upvotes: '<3',
  ticket: aTicket._id
}, true, user).then(function(comments) {
  var comment, _i, _len;
  comments.should.have.length(1);
  for (_i = 0, _len = comments.length; _i < _len; _i++) {
    comment = comments[_i];
    comment.upvotes.should.be.below(3);
  }
  return done();
}).fail(done);
```

supports `<=`.

```js
return Comment.find({
  upvotes: '<=2',
  ticket: aTicket._id
}, true, user).then(function(comments) {
  var comment, _i, _len;
  comments.should.have.length(1);
  for (_i = 0, _len = comments.length; _i < _len; _i++) {
    comment = comments[_i];
    comment.upvotes.should.be.most(2);
  }
  return done();
}).fail(done);
```

supports `>`.

```js
return Comment.find({
  upvotes: '>3',
  ticket: aTicket._id
}, true, user).then(function(comments) {
  var comment, _i, _len;
  comments.should.have.length(1);
  for (_i = 0, _len = comments.length; _i < _len; _i++) {
    comment = comments[_i];
    comment.upvotes.should.be.above(3);
  }
  return done();
}).fail(done);
```

supports `>=`.

```js
return Comment.find({
  upvotes: '>=5',
  ticket: aTicket._id
}, true, user).then(function(comments) {
  var comment, _i, _len;
  comments.should.have.length(1);
  for (_i = 0, _len = comments.length; _i < _len; _i++) {
    comment = comments[_i];
    comment.upvotes.should.be.least(5);
  }
  someModel = comments[0];
  return done();
}).fail(done);
```

<a name="submodel-findbyid"></a>
## #findById()
supports finding one doc.

```js
return Comment.findById(someModel._id, true, user).then(function(other) {
  var _ref;
  someModel._id = (_ref = someModel._id) != null ? _ref.toString() : void 0;
  other.should.deep.equal(someModel);
  return done();
}).fail(done);
```

<a name="submodel-create"></a>
## #create()
can create a submodel.

```js
var props;
props = {
  body: "This is a long bodddddyyyyyyyyyyyy",
  upvotes: 2e5,
  downvotes: 2e2,
  ticket: aTicket._id
};
return Comment.create(props, true, user).then(function(comment) {
  someModel = _.clone(comment);
  delete comment._id;
  delete props.ticket;
  comment.should.deep.equal(props);
  return done();
}).fail(done);
```

<a name="submodel-set"></a>
## #set()
can set some properties.

```js
return Comment.set(someModel._id, {
  upvotes: 2e3,
  body: "King's Landing"
}, true, user).then(function(result) {
  result.upvotes.should.equal(2e3);
  result.body.should.equal("King's Landing");
  result._id.toString().should.equal(someModel._id.toString());
  return Comment.findById(someModel._id, true, user);
}).then(function(result) {
  result.upvotes.should.equal(2e3);
  result.body.should.equal("King's Landing");
  result._id.toString().should.equal(someModel._id.toString());
  return done();
}).fail(done);
```

<a name="submodel-delete"></a>
## #delete()
can delete a comment.

```js
return Comment["delete"](someModel._id, true, user).then(function() {
  return Comment.findById(someModel._id);
}).then(function(comment) {
  comment.should.deep.equal({});
  return done();
}).fail(done);
```

<a name="authorizations"></a>
# authorizations
should connect the server with passport.

```js
return request.get('/').set('Authorization', fooToken).end(function(err, res) {
  res.body.should.deep.equal({
    username: 'Foo',
    role: 'user',
    _id: someUser._id.toString()
  });
  return done();
});
```

<a name="authorizations-guests"></a>
## guests
should have access to stories.

```js
return request.get('/api/stories').end(function(err, res) {
  res.body.should.have.length(7);
  aStory = res.body[0];
  return done();
});
```

should have access to one story.

```js
return request.get("/api/stories/" + aStory._id).end(function(err, res) {
  res.body.should.deep.equal(aStory);
  return done();
});
```

should not be able to post mod.

```js
var req;
req = request.post("/api/stories");
req.send({
  title: "This is a title",
  body: "This is a bodty"
});
return req.end(function(err, res) {
  try {
    if (err) {
      return done(err);
    }
    res.statusCode.should.equal(401);
    return done();
  } catch (err) {
    return done(err);
  }
});
```

should not be able to put mod.

```js
var req;
req = request.put("/api/stories/" + aStory._id);
req.send({
  title: "This is a title",
  body: "This is a bodty"
});
return req.end(function(err, res) {
  try {
    if (err) {
      return done(err);
    }
    res.statusCode.should.equal(401);
    return request.get("/api/stories/" + aStory._id).end(function(err, res) {
      res.body.should.deep.equal(aStory);
      return done();
    });
  } catch (err) {
    return done(err);
  }
});
```

should not be able to delete mod.

```js
var req;
req = request["delete"]("/api/stories/" + aStory._id);
return req.end(function(err, res) {
  try {
    if (err) {
      return done(err);
    }
    res.statusCode.should.equal(401);
    return request.get("/api/stories/" + aStory._id).end(function(err, res) {
      res.body.should.deep.equal(aStory);
      return done();
    });
  } catch (err) {
    return done(err);
  }
});
```

<a name="authorizations-users"></a>
## users
should be able to post a mod.

```js
var req;
req = request.post("/api/stories");
req.set('Authorization', token);
req.send({
  title: "This is a title",
  body: "This is a bodty"
});
return req.end(function(err, res) {
  try {
    if (err) {
      return done(err);
    }
    res.statusCode.should.equal(200);
    otherStory = res.body;
    return done();
  } catch (err) {
    return done(err);
  }
});
```

should be able to put his mod.

```js
var req;
req = request.put("/api/stories/" + otherStory._id);
req.set('Authorization', token);
req.send({
  title: "This is another title"
});
return req.end(function(err, res) {
  try {
    if (err) {
      return done(err);
    }
    res.statusCode.should.equal(200);
    res.body.title.should.equal("This is another title");
    return done();
  } catch (err) {
    return done(err);
  }
});
```

shouldn't be able to put one's mod.

```js
var req;
req = request.put("/api/stories/" + otherStory._id);
req.set('Authorization', fooToken);
req.send({
  title: "This is not another title"
});
return req.end(function(err, res) {
  try {
    if (err) {
      return done(err);
    }
    res.statusCode.should.equal(403);
    return request.get("/api/stories/" + otherStory._id).end(function(err, res) {
      if (err) {
        done(err);
      }
      res.body.title.should.equal("This is another title");
      return done();
    });
  } catch (err) {
    return done(err);
  }
});
```

shouldn't be able to delete one's mod.

```js
var req;
req = request["delete"]("/api/stories/" + otherStory._id);
req.set('Authorization', fooToken);
return req.end(function(err, res) {
  try {
    if (err) {
      return done(err);
    }
    res.statusCode.should.equal(403);
    return request.get("/api/stories/" + otherStory._id).end(function(err, res) {
      if (err) {
        done(err);
      }
      res.body.title.should.equal("This is another title");
      return done();
    });
  } catch (err) {
    return done(err);
  }
});
```

should be able to delete his mod.

```js
var req;
req = request["delete"]("/api/stories/" + otherStory._id);
req.set('Authorization', token);
return req.end(function(err, res) {
  try {
    if (err) {
      return done(err);
    }
    res.statusCode.should.equal(200);
    return request.get("/api/stories/" + otherStory._id).end(function(err, res) {
      if (err) {
        done(err);
      }
      res.body.should.deep.equal({});
      return done();
    });
  } catch (err) {
    return done(err);
  }
});
```

<a name="authorizations-admins"></a>
## admins
should be able to post a mod.

```js
var req;
req = request.post("/api/stories");
req.set('Authorization', adminToken);
req.send({
  title: "This is a title",
  body: "This is a bodty"
});
return req.end(function(err, res) {
  try {
    if (err) {
      return done(err);
    }
    res.statusCode.should.equal(200);
    anotherStory = res.body;
    return done();
  } catch (err) {
    return done(err);
  }
});
```

should be able to put his mod.

```js
var req;
req = request.put("/api/stories/" + anotherStory._id);
req.set('Authorization', adminToken);
req.send({
  title: "This is another title"
});
return req.end(function(err, res) {
  try {
    if (err) {
      return done(err);
    }
    res.statusCode.should.equal(200);
    res.body.title.should.equal("This is another title");
    return done();
  } catch (err) {
    return done(err);
  }
});
```

should be able to put one's mod.

```js
var req;
req = request.put("/api/stories/" + otherStory._id);
req.set('Authorization', adminToken);
req.send({
  title: "This is indeed another title"
});
return req.end(function(err, res) {
  try {
    if (err) {
      return done(err);
    }
    res.statusCode.should.equal(200);
    return request.get("/api/stories/" + otherStory._id).end(function(err, res) {
      if (err) {
        done(err);
      }
      res.body.title.should.equal("This is indeed another title");
      return done();
    });
  } catch (err) {
    return done(err);
  }
});
```

should be able to delete one's mod.

```js
var req;
req = request["delete"]("/api/stories/" + otherStory._id);
req.set('Authorization', adminToken);
return req.end(function(err, res) {
  try {
    if (err) {
      return done(err);
    }
    res.statusCode.should.equal(200);
    return request.get("/api/stories/" + otherStory._id).end(function(err, res) {
      if (err) {
        done(err);
      }
      res.body.should.deep.equal({});
      return done();
    });
  } catch (err) {
    return done(err);
  }
});
```

should be able to delete his mod.

```js
var req;
req = request["delete"]("/api/stories/" + anotherStory._id);
req.set('Authorization', adminToken);
return req.end(function(err, res) {
  try {
    if (err) {
      return done(err);
    }
    res.statusCode.should.equal(200);
    return request.get("/api/stories/" + otherStory._id).end(function(err, res) {
      if (err) {
        done(err);
      }
      res.body.should.deep.equal({});
      return done();
    });
  } catch (err) {
    return done(err);
  }
});
```

