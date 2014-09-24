var express = require('express');
var app = express();
var mongoose = require('mongoose');
Schema = mongoose.Schema;
mongoose.connect('mongodb://localhost:27017/', function(){
});
nap = require('../../index');
User = mongoose.model('User', {
  username: String,
  password: String
});

Article = mongoose.model('Article', {
  title: String,
  created_at: {
    type: Date, default: Date.now
  },
  body: String,
  author: {
    type: Schema.Types.ObjectId,
    ref: 'User'
  },
  comments: [{
    content: String,
    author: {
      type: Schema.Types.ObjectId,
      ref: 'User'
    },
    created_at: {
      type: Date, default: Date.now
    },
  }]
})

app.get('/', function(req, res){
  res.send('hello world');
});


api = nap({
  mongoose: mongoose
});
api.add({
  model: 'User'
})
api.add({
  model: 'Article',
  submodels: ['comments']
});


api.inject(app, express.bodyParser, function (req, res, next) {
  req.user = {
    username: "Foo"
  };
  next();
}, function (req, res, next) {
  req.allow = true;
  next();
})

app.listen(3000);
