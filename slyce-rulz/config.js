//config.js
var config = { };

// should end in /
config.rootUrl  = process.env.ROOT_URL                  || 'http://slyce-rulz.herokuapp.com/';

config.facebook = {
    appId:          process.env.FACEBOOK_APPID          || '264678703732974',
    appSecret:      process.env.FACEBOOK_APPSECRET      || '3eb6be1b239ee50a6ec42bb8a26a225a',
    appNamespace:   process.env.FACEBOOK_APPNAMESPACE   || 'slyce',
    redirectUri:    process.env.FACEBOOK_REDIRECTURI    ||  config.rootUrl + 'login/callback'
};

config.env = {
    prod: {
        sqlDriver: 'driver://inuwvtvagyudpx:vXvTonI46H-6HBtlUllai726-s@ec2-54-243-49-204.compute-1.amazonaws.com:5432/dapgarjped5d70'
    },
    dev: {
        sqlDriver: 'driver://amir@localhost/slyce'
    }
}

module.exports = config;
