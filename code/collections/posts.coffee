@Posts = new Meteor.Collection 'posts'

# Allow
Posts.allow
  insert: ->
    false
  update: ->
    false
  remove: ->
    false
