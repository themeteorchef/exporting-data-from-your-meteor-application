let startup = () => {
  _setEnvironmentVariables();
  _setBrowserPolicies();
  _generateAccounts();
  _loadFixtures();
};

var _setEnvironmentVariables = () => Modules.server.setEnvironmentVariables();

var _setBrowserPolicies = () => {
  BrowserPolicy.content.allowOriginForAll( '*.amazonaws.com' );
};

var _generateAccounts = () => Modules.server.generateAccounts();

var _loadFixtures = () => Modules.server.loadFixtures();

Modules.server.startup = startup;
