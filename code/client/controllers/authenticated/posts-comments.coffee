Template.postsComments.helpers(
  posts: ->
    Posts.find()
  comments: ->
    Comments.find()
)
