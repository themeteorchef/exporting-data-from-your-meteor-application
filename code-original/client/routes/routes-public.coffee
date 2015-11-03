Router.route('signup',
  path: '/signup'
  template: 'signup'
  onBeforeAction: ->
    @next()
)

Router.route('login',
  path: '/login'
  template: 'login'
  onBeforeAction: ->
    @next()
)

Router.route('recover-password',
  path: '/recover-password'
  template: 'recoverPassword'
  onBeforeAction: ->
    @next()
)

Router.route('reset-password',
  path: '/reset-password/:token'
  template: 'resetPassword'
  onBeforeAction: ->
    Session.set 'resetPasswordToken', @params.token
    @next()
)
