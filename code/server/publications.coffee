###
  Publications
  Data being published to the client.
###

# /profile

Meteor.publish('profile', ->
  [
    Posts.find()
    Friends.find()
    Comments.find()
  ]
)
