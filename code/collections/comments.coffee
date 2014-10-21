@Comments = new Meteor.Collection 'comments'

# Allow
Comments.allow
  insert: ->
    false
  update: ->
    false
  remove: ->
    false
