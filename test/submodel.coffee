chai = require('chai')
should = chai.should()
chai.use(require('chai-things'))
index = require('../index')
mongoose = require("mongoose-q")()
SubModel = require "../src/submodel"
Model = require "../src/model"
Q = require "q"
_ = require "lodash"

mongoose.model "Ticket", {
  title: String
  body: String
  likes: Number
  comments: [{
    body: String
    upvotes: Number
    downvotes: Number
  }]
}

Comment = new SubModel
  model: mongoose.model "Ticket"
  collection: "tickets"
  location: "comments"
  paths: ['body','upvotes','downvotes']
  link: "ticket"

Ticket = new Model
  model: mongoose.model "Ticket"
  collection: "tickets"
  likes: "Number"

user = {}

someModel = undefined

mongoose.connection.collections.users.drop ->
mongoose.connection.collections.stories.drop ->

FS = require("q-io/fs")
aTicket = {}

describe 'SubModel', ->
  it 'is a constructor ', ->
    Model.should.be.a 'function'

  it 'can mount fixtures', (done) ->
    FS.read('test/fixtures03.json').then (data) ->
      fixtures = JSON.parse data
      promises = []

      for fixture in fixtures.tickets
        promises.push Ticket.create fixture

      Q.allSettled promises
    .then ->
      done()
    .fail done


  describe "#find()", ->
    before (done) ->
      Ticket.find(likes: 42).then (tickets) ->
        aTicket = tickets[0]
        done()
      .fail done
    it 'supports no parameter', (done) ->
      @timeout 5000
      Comment.find(ticket: aTicket._id , true, user).then (comments) ->
        comments.should.have.length 2
        done()
      .fail done

    it 'supports `sort` parameter', (done) ->
      Comment.find(sort: "upvotes", ticket: aTicket._id, true, user).then (comments) ->
        oldUpvotes = 0
        for comment in comments
          oldUpvotes.should.be.at.most comment.upvotes
          oldUpvotes = comment.upvotes
        done()
      .fail done

    it 'supports `limit` parameter', (done) ->
      Comment.find(limit: 1, ticket: aTicket._id, true, user).then (stories)->
        stories.should.have.length 1
        done()
      .fail done

    it 'supports `skip` parameter', (done) ->
      Comment.find(offset: 1, ticket: aTicket._id, true, user).then (stories)->
        stories.should.have.length 1
        done()
      .fail done

    it 'supports `select` parameter', (done) ->
      Comment.find(select: 'upvotes', ticket: aTicket._id, true, user).then (comments)->
        comments.should.have.length 2
        for comment in comments
          should.not.exist comment.title
          should.not.exist comment.downvotes
          should.exist comment.upvotes
        Comment.find(select: '-upvotes', ticket: aTicket._id)
      .then (comments)->
        comments.should.have.length 2
        for comment in comments
          should.exist comment.body
          should.exist comment.downvotes
          should.not.exist comment.upvotes
        done()
      .fail done

    describe 'where', ->

      it 'supports `=`', (done) ->
        Comment.find(upvotes: '2', ticket: aTicket._id, true, user).then (comments)->
          comments.should.have.length 1
          comments.should.all.have.property 'upvotes', 2
          done()
        .fail done



      it 'supports `<`', (done) ->
        Comment.find(upvotes: '<3', ticket: aTicket._id, true, user).then (comments)->
          comments.should.have.length 1

          for comment in comments
            comment.upvotes.should.be.below 3
          done()
        .fail done

      it 'supports `<=`', (done) ->
        Comment.find(upvotes: '<=2', ticket: aTicket._id, true, user).then (comments)->
          comments.should.have.length 1

          for comment in comments
            comment.upvotes.should.be.most 2
          done()
        .fail done

      it 'supports `>`', (done) ->
        Comment.find(upvotes: '>3', ticket: aTicket._id, true, user).then (comments)->
          comments.should.have.length 1

          for comment in comments
            comment.upvotes.should.be.above 3
          done()
        .fail done

      it 'supports `>=`', (done) ->
        Comment.find(upvotes: '>=5', ticket: aTicket._id, true, user).then (comments)->
          comments.should.have.length 1

          for comment in comments
            comment.upvotes.should.be.least 5

          someModel = comments[0]
          done()
        .fail done


  describe '#findById()', ->

    it 'supports finding one doc', (done) ->
      Comment.findById(someModel._id, true , user).then (other) ->
        someModel._id = someModel._id?.toString()
        other.should.deep.equal someModel
        done()

      .fail done
    it 'supports finding one doc with `select`', (done) ->

      Comment.findById(someModel._id, select: 'upvotes').then (other) ->
        should.not.exist other.downvotes
        should.not.exist other.body
        done()

      .fail done
  describe '#create()', ->
    it 'can create a submodel', (done) ->
      props =
        body: "This is a long bodddddyyyyyyyyyyyy"
        upvotes: 2e5
        downvotes: 2e2
        ticket: aTicket._id
      Comment.create(props, true, user).then (comment) ->
        someModel = _.clone comment
        delete comment._id
        delete props.ticket
        comment.should.deep.equal props
        done()
      .fail done
  describe '#set()' ,->
    it 'can set some properties', (done) ->
      Comment.set(someModel._id,
        upvotes: 2e3
        body: "King's Landing"
      , true, user).then (result) ->
        result.upvotes.should.equal 2e3
        result.body.should.equal "King's Landing"
        result._id.toString().should.equal someModel._id.toString()

        Comment.findById someModel._id, true, user
      .then (result) ->
        result.upvotes.should.equal 2e3
        result.body.should.equal "King's Landing"
        result._id.toString().should.equal someModel._id.toString()

        done()
      .fail done

  describe '#delete()', ->
    it 'can delete a comment', (done) ->
      Comment.delete(someModel._id, true, user).then ->
        Comment.findById someModel._id
      .then (comment) ->
        comment.should.deep.equal {}
        done()
      .fail done
