###
  Startup
  Collection of methods and functions to run on server startup.
###

# Define an array of users to create.
users = [
  {
    name: "Peter Venkman"
    email: "venkman@ghostbusters.com"
    password: "slimer"
    photo: "https://s3.amazonaws.com/themeteorchef-storage/recipes/001_exporting-data-from-your-meteor-application/peter-venkman.jpg"
    location: "New York, NY"
    career: "Scientist, Ghostbuster"
    biography: "I was born in Brooklyn, New York. I'm one of three doctors of parapsychology on the Ghostbusters team. I hold PhDs in both parapsychology and psychology."
  }
]

# Loop through array of user accounts.
for user in users

  # Check if the user already exists in the DB.
  checkUser = Meteor.users.findOne({"emails.address": user.email});

  # If an existing user is not found, create the account.
  if not checkUser

    # Create the user.
    id = Accounts.createUser(
      email: user.email
      password: user.password
      profile:
        name: user.name
        photo: user.photo
        location: user.location
        career: user.career
        biography: user.biography
    )

    # Call method to insert fixture data.
    Meteor.call 'loadFixtures'
