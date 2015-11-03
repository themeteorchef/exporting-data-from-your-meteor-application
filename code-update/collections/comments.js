Comments = new Meteor.Collection( 'comments' );

Comments.allow({
  insert: () => false,
  update: () => false,
  remove: () => false
});

Comments.deny({
  insert: () => true,
  update: () => true,
  remove: () => true
});

let CommentsSchema = new SimpleSchema({
  "owner": {
    type: String,
    label: "The ID of the owner of this document."
  },
  "avatar": {
    type: String,
    label: "The URL of the avatar for this comment."
  },
  "commenterName": {
    type: String,
    label: "The name of the person posting this comment."
  },
  "commentDate": {
    type: String,
    label: "The date this comment was posted."
  },
  "commentContent": {
    type: String,
    label: "The content for this comment."
  }
});

Comments.attachSchema( CommentsSchema );
