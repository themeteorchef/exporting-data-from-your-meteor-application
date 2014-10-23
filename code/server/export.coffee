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

JSZip      = Meteor.npmRequire 'jszip'
XMLBuilder = Meteor.npmRequire 'xmlbuilder'
fastCSV    = Meteor.npmRequire 'fast-csv'
fs         = Npm.require 'fs'

Meteor.methods(

  exportData: (userId)->

    # Check the format of the userId.

    check(userId,String)

    # Get the data we'll need to work with from the DB. We're super excited about this.

    FRIENDS  = Friends.find({"owner": userId}, {fields: {"_id": 1, "photo": 1, "name": 1}}).fetch()
    COMMENTS = Comments.find({"owner": userId}, {fields: {"_id": 1, "commenterName": 1, "commentDate": 1, "commentContent": 1}}).fetch()
    POSTS    = Posts.find({"owner": userId}, {fields: {"_id": 1, "text": 1, "name": 1, "date": 1}}).fetch()

    # Setup our zip instance and define folders for each type of data.
    # Note: folders are optional but nice for organization.

    ZIP            = new JSZip()
    friendsFolder  = ZIP.folder 'friends'
    commentsFolder = ZIP.folder 'comments'
    postsFolder    = ZIP.folder 'posts'

    # Iterate through each set of data returned. This is the meat and potatoes of our
    # export. This is where we actually pull data from the database, format it for export,
    # and assign it to a file to be added to our .zip file.

    csv = fastCSV
    csv.writeToString(POSTS,
      {headers: true},
      (err,data) ->
        console.log data
    )

)
