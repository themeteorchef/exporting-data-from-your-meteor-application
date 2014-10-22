Meteor.publish('data', ->
  [
    Posts.find()
    Friends.find()
    Comments.find()
  ]
)
