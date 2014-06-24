//slyce_server.js

'use strict';

var http            = require('http'),
    connect         = require('connect'),
    bodyParser      = require('body-parser'),
    morgan          = require('morgan'),
    methodOverride  = require('method-override'),
    express         = require('express'),
    anyDB           = require('any-db-postgres'),
    begin           = require('any-db-transaction'),
    FB              = require('fb'),
    config          = require('./config');

//Prod DB setup
var prod = true,
sqlDriver = (prod ? config.env.prod.sqlDriver : config.env.dev.sqlDriver);
console.log(sqlDriver);

var conn = anyDB.createConnection(sqlDriver, function(err){
    if (err) throw err;
});

//create db
var sql = 'CREATE TABLE IF NOT EXISTS slyce (id integer NOT NULL PRIMARY KEY, email VARCHAR(255) UNIQUE NOT NULL)';

conn.query(sql, function (err, result) {
    if(err) throw err;
});

//
//Express Server config

var app = connect();
var port = process.env.PORT || 3000;

if(!config.facebook.appId || !config.facebook.appSecret) {
    throw new Error('facebook appId and appSecret required in config.js');
}

app.use(morgan({ format: 'dev', immediate: true }));
app.use(bodyParser.json());
app.use(methodOverride('X-HTTP-Method-Override'));
app.use(function(req, res, next){
    if (req.method === 'POST' && req.headers['content-type'] === 'application/json') {
        console.log(req.body);
        res.end("POST request okay.\n");
        FB.api('me', { fields: ['id', 'name', 'installed'], access_token: req.body.access_token }, function (res) {
            if(res.id === req.body.id && res.installed === true){
                console.log('valid access token', res);
            }else{
                console.log('invalid access token', res);
            }
        });
    } else {
        next();
    }
});


http.createServer(app).listen(port, function() {
    console.log("Express server listening on port " + port);
});


