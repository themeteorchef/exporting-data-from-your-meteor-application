###
  Load Fixtures
  Load data into our database for demonstration purposes.
###

Meteor.methods(

  loadFixtures: ->

    # Load Friends
    friends = FRIENDS_FIXTURE
    for friend in friends
      Friends.insert(friend, (error)->
        console.log error if error
      )

    # Load Posts
    posts = POSTS_FIXTURE
    for post in posts
      Posts.insert(post, (error)->
        console.log error if error
      )

    # Load Comments
    comments = COMMENTS_FIXTURE
    for comment in comments
      Comments.insert(comment, (error)->
        console.log error if error
      )

)
