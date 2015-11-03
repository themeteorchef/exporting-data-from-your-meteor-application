Posts = new Meteor.Collection( 'posts' );

Posts.allow({
  insert: () => false,
  update: () => false,
  remove: () => false
});

Posts.deny({
  insert: () => true,
  update: () => true,
  remove: () => true
});

let PostsSchema = new SimpleSchema({
  "owner": {
    type: String,
    label: "The ID of the owner of this document."
  },
  "text": {
    type: String,
    label: "The text of this post."
  },
  "name": {
    type: String,
    label: "The name of the person writing this post."
  },
  "date": {
    type: String,
    label: "The date this post was published."
  }
});

Posts.attachSchema( PostsSchema );
