const authenticatedRedirect = () => {
  if ( !Meteor.loggingIn() && !Meteor.userId() ) {
    FlowRouter.go( 'login' );
  }
};

const authenticatedRoutes = FlowRouter.group({
  name: 'authenticated',
  triggersEnter: [ authenticatedRedirect ]
});

authenticatedRoutes.route( '/profile', {
  name: 'profile',
  action() {
    BlazeLayout.render( 'default', { yield: 'profile' } );
  }
});

authenticatedRoutes.route( '/export', {
  name: 'export',
  action() {
    BlazeLayout.render( 'default', { yield: 'export' } );
  }
});
