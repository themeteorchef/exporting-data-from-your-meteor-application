Router.route('index',
  path: '/'
  # Note: we're not defining a template here because Iron Router is going to
  # assume this is the same as the route name (i.e. profile).
  onBeforeAction: ->
    Session.set 'currentRoute', 'index'
    @next()
)

Router.route('profile',
  path: '/profile'
  # Note: we're not defining a template here because Iron Router is going to
  # assume this is the same as the route name (i.e. profile).
  waitOn: ->
    Meteor.subscribe 'profile'
  onBeforeAction: ->
    Session.set 'currentRoute', 'profile'
    @next()
)

Router.route('export',
  path: '/export'
  # Note: we're not defining a template here because Iron Router is going to
  # assume this is the same as the route name (i.e. export).
  onBeforeAction: ->
    Session.set 'currentRoute', 'export'
    @next()
)
