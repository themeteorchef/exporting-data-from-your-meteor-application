@Friends = new Meteor.Collection 'friends'

# Allow
Friends.allow
  insert: ->
    false
  update: ->
    false
  remove: ->
    false
