###
  Load Fixtures
  Load data into our database for demonstration purposes.
###

Meteor.methods(

  loadFixtures: ->

    # Get the userID for the test account.
    getUser = Meteor.users.findOne({"emails.address": "venkman@ghostbusters.com"})
    userId  = getUser._id

    # Load Friends
    friends = FRIENDS_FIXTURE
    for friend in friends
      friend.owner = userId
      Friends.insert(friend, (error)->
        console.log error if error
      )

    # Load Posts
    posts = POSTS_FIXTURE
    for post in posts
      post.owner = userId
      Posts.insert(post, (error)->
        console.log error if error
      )

    # Load Comments
    comments = COMMENTS_FIXTURE
    for comment in comments
      comment.owner = userId
      Comments.insert(comment, (error)->
        console.log error if error
      )

)
