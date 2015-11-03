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

# Define our exportData method.
Meteor.methods(

  exportData: (userId)->

    # Check the format of the userId. Check allows us to assert that arguments
    # to a function have the right types and structure to preven unwanted data
    # being inserted into the DB.
    # See: https://docs.meteor.com/#/full/check_package
    # See: https://docs.meteor.com/#/full/auditargumentchecks
    check(userId,String)

    # Setup our zip instance and define folders for each type of data.
    # Note: folders are optional but nice for organization. Here, we're only
    # making one folder to demonstrate the technique.
    zip           = new jsZip()
    assetsFolder  = zip.folder 'assets'

    # Get our data out of the DB. Note: for the user's profile information,
    # we're using the findOne method. For everything else, we're using the
    # find method along with the .fetch() method to convert our cusor into
    # an object array. We do this to loop through the data easily.
    getUser     = Meteor.users.findOne({"_id": userId}, {fields: {"profile.name": 1, "profile.photo": 1, "profile.biography": 1, "profile.location": 1, "profile.career": 1}})
    getFriends  = Friends.find({"owner": userId}, {fields: {"_id": 1, "photo": 1, "name": 1}}).fetch()
    getComments = Comments.find({"owner": userId}, {fields: {"_id": 1, "avatar": 1, "commenterName": 1, "commentDate": 1, "commentContent": 1}}).fetch()
    getPosts    = Posts.find({"owner": userId}, {fields: {"_id": 1, "text": 1, "name": 1, "date": 1}}).fetch()

    exportFriendsAsCsv = ->
      ###
        Export friends as a .csv file.
      ###

      # Create an instance of Fast CSV
      csv = fastCsv

      # Create a CSV string that we can pass to our friends.csv file.
      csv.writeToString(getFriends,
        # Tell fast CSV that we want our first row to be column headers.
        {headers: true},
        (error,data) ->
          if error
            console.log error
          else
            # Get the string (data) returned from Fast CSV and add it as a file
            # to our friends folder in our .zip file.
            zip.file('friends.csv', data)
      )

    exportProfileAsXml = ->
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

    exportProfileAsHtml = ->

      # Here, we're making use of Meteor's Asset.getText() method that allows us
      # to pull in the text of a file from our /private directory. To keep
      # things clean we've created a directory called /export in our /private
      # directory (/private/export) to store our CSS and JS files that we'll
      # bundle with our export.
      # See: https://docs.meteor.com/#/full/assets
      exportCss = Assets.getText("export/style.css")
      exportJs  = Assets.getText("export/bootstrap.js")

      assetsFolder.file('style.css', exportCss)
      assetsFolder.file('bootstrap.js', exportJs)

      # Define structural elements of our HTML as strings set to variables.
      head = "
        <head>
          <title>Blerg | Data Export</title>
          <meta charset='utf-8'>
          <meta name='viewport' content='width=device-width, initial-scale=1'>
          <link rel='stylesheet' type='text/css' href='assets/style.css'>
        </head>
      "
      scripts = "
        <script src='https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js'></script>
        <script src='assets/bootstrap.js'></script>
      "
      header = "<html>#{head}<body>"
      footer = "#{scripts}</body></html>"

      # Build out the friend list by concatenating the friendsList string while
      # looping through our getFriends variable from above.
      friendsList = "<ul>"
      for friend in getFriends
        friendsList += "<li><img src='#{friend.photo}' class='img-responsive' alt='#{friend.name}'></li>"
      friendsList += "</ul>"

      # Build out our sidebar.
      profileSidebar = "
        <img src='#{getUser.profile.photo}' class='profile-photo img-responsive img-rounded' alt='#{getUser.profile.photo}' />
        <div class='panel panel-default user-information'>
          <div class='panel-heading'>About #{getUser.profile.name}</div>
          <div class='panel-body'>
            <div class='panel-block'>
              <strong>Friends</strong>
              #{friendsList}
            </div>
            <div class='panel-block'>
              <strong>Location</strong>
              <p>#{getUser.profile.location}</p>
            </div>
            <div class='panel-block'>
              <strong>Career</strong>
              <p>#{getUser.profile.career}</p>
            </div>
          </div>
        </div>
      "

      # Build out our posts content.
      postsContent = ""
      for post in getPosts
        postsContent += "
          <div class='panel panel-default'>
            <div class='panel-body'>
              #{post.text}
            </div>
            <div class='panel-footer'>By <strong>#{post.name}</strong> on #{post.date}</div>
          </div>
        "

      # Build out our comments content.
      commentsContent = ""
      for comment in getComments
        commentsContent += "
          <div class='panel panel-default'>
            <div class='panel-body'>
              <img class='comment-avatar' src='#{comment.avatar}' alt='#{comment.commenterName}'>
              <div class='comment-content'>
                #{comment.commentContent}
              </div>
            </div>
            <div class='panel-footer'>By <strong>#{comment.commenterName}</strong> on #{comment.commentDate}</div>
          </div>
        "

      # Build out the profile body.
      profileBody = "
        <h2>#{getUser.profile.name}</h2>
        <p>#{getUser.profile.biography}</p>
        <ul class='nav nav-tabs' role='tablist'>
          <li class='active'><a href='#posts' role='tab' data-toggle='tab'>Posts</a></li>
          <li><a href='#comments' role='tab' data-toggle='tab'>Comments</a></li>
        </ul>
        <div class='tab-content'>
          <div class='tab-pane active posts' id='posts'>
            #{postsContent}
          </div>
          <div class='tab-pane comments' id='comments'>
            #{commentsContent}
          </div>
        </div>
      "

      # Wrap the sidebar and body in their respective containers.
      container = "
        <div class='container'>
          <div class='row'>
            <div class='col-xs-12 col-sm-4'>
              #{profileSidebar}
            </div>
            <div class='col-xs-12 col-sm-8'>
              #{profileBody}
            </div>
          </div>
        </div>
      "

      # Combine all of our HTML strings for export.
      htmlExportString = header + container + footer

      # Export our HTML as a single file in the zip root.
      zip.file('index.html', htmlExportString)

    exportProfileAsJSON = ->
      # Define our profile object that we'll "load" our profile's data into.
      # Note: here, we pre-define each of the parent keys (e.g friends) as
      # empty objects and arrays so that we can easily set or push data into
      # them later.
      profile =
        user: {}
        friends: []
        comments: []
        posts: []

      # Set our user's profile info to the profile.user object.
      profile.user =
        name: getUser.profile.name
        photo: getUser.profile.photo
        biography: getUser.profile.biography
        location: getUser.profile.location
        career: getUser.profile.career

      # Here we loop through friends, comments, and posts, pushing the objects
      # from each result set into the respective array defined above.
      for friend in getFriends
        profile.friends.push friend

      for comment in getComments
        profile.comments.push comment

      for post in getPosts
        profile.posts.push post

      # Convert our profile to a string for our .zip.
      profile = JSON.stringify(profile)

      # Add our JSON string to our .zip.
      zip.file('tester.json', profile)

    # Run our export functions.
    exportFriendsAsCsv()
    exportProfileAsXml()
    exportProfileAsHtml()
    exportProfileAsJSON()

    # Complete our .zip file and return it to our client-side method call
    # as a base64 encoded string.
    zip.generate({type: "base64"})
)
