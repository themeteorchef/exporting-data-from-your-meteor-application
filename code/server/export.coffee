###
  Export
  Method for handling data export from our app.
###

###
  Import our NPM packages using the meteorhacks:npm package (thanks, Arunoda!).
  See: https://atmospherejs.com/meteorhacks/npm.

  The final require, 'fs', is using the core Npm.require method to pull in the
  file system from Node.js core. We're doing this because fs is not an npm
  package that we need to load. It's already available via Meteor, we just need
  to tell Meteor to give us access to it here.
###

jsZip      = Meteor.npmRequire 'jszip'
xmlBuilder = Meteor.npmRequire 'xmlbuilder'
fastCsv    = Meteor.npmRequire 'fast-csv'

Meteor.methods(

  exportData: (userId)->

    # Check the format of the userId.
    check(userId,String)

    # Get the data we'll need to work with from the DB.
    # Note: we're using the .fetch() method so that our data is returned as
    # an array instead of a plain cursor.
    getUser     = Meteor.users.findOne({"_id": userId}, {fields: {"profile.name": 1, "profile.photo": 1, "profile.biography": 1, "profile.location": 1, "profile.career": 1}})
    getFriends  = Friends.find({"owner": userId}, {fields: {"_id": 1, "photo": 1, "name": 1}}).fetch()
    getComments = Comments.find({"owner": userId}, {fields: {"_id": 1, "commenterName": 1, "commentDate": 1, "commentContent": 1}}).fetch()
    getPosts    = Posts.find({"owner": userId}, {fields: {"_id": 1, "text": 1, "name": 1, "date": 1}}).fetch()

    # Setup our zip instance and define folders for each type of data.
    # Note: folders are optional but nice for organization. Here, we're only
    # making one folder to demonstrate the technique.
    zip            = new jsZip()
    friendsFolder  = zip.folder 'friends'

    ###
      DELETE MEEEEEEE
      - Show off creating an HTML file that has all of our data.
    ###

    ###
      Export friends as a .csv file.
    ###

    # Create an instance of Fast CSV
    csv = fastCsv

    # Create a CSV string that we can pass to our friends.csv file.
    csv.writeToString(getFriends,
      # Tell fast CSV that we want our first row to be column headers.
      {headers: true},
      (err,data) ->
        # Get the string (data) returned from Fast CSV and add it as a file
        # to our friends folder in our .zip file.
        friendsFolder.file('friends.csv', data)
    )

    ###
      Export full profile (friends, comments, and posts) as a .xml file.
    ###

    # Create an instance of XML Builder. Here, profile means the most top level
    # XML element <profile> which wraps all of our output. For example:
    # <profile>
    #  Our XML data goes here.
    # </profile>

    profile = xmlBuilder.create('profile')

    # Create a <user> element to nest our user's profile data within.
    userData = profile.ele('user')

    # Next, we add each element independently to our <user-data-> element.
    userData.ele('name', getUser.profile.name)
    userData.ele('photo', getUser.profile.photo)
    userData.ele('biography', getUser.profile.biography)
    userData.ele('location', getUser.profile.location)
    userData.ele('career', getUser.profile.career)

    # Create a <friends> element to nest our user's friends data within.
    friendsData = profile.ele('friends')

    # Here we'll loop through the friends, outputting an element for each.
    for friend in getFriends
      friendData = friendsData.ele('friend')
      friendData.ele('name', friend.name)
      friendData.ele('photo', friend.photo)

    # Create a <comments> element to nest our user's comments data within.
    commentsData = profile.ele('comments')

    # Here we'll loop through the comments, outputting an element for each.
    for comment in getComments
      commentData = commentsData.ele('comment')
      commentData.ele('name', comment.commenterName)
      commentData.ele('avatar', comment.avatar)
      commentData.ele('date', comment.commentDate)
      commentData.ele('content', comment.commentContent)

    # Create a <posts> element to nest our user's post data within.
    postsData = profile.ele('posts')

    # Here we'll loop through the posts, outputting an element for each.
    for post in getPosts
      postData = postsData.ele('post')
      postData.ele('name', post.name)
      postData.ele('date', post.date)
      postData.ele('text', post.text)

    # Now with all of our data output, we finish off our <profile> XML element
    # and make sure that the formatting is set as a string ({pretty: true})
    # instead of a data object ({pretty: false}). Note: we must set the result
    # of profile.end({pretty: true}) to a variable in order to get the string.
    profileXmlString = profile.end({pretty: true})

    # Assign our XML file to a file in our .zip file.
    zip.file('profile.xml', profileXmlString)
)
