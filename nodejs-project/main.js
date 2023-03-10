var http = require('http');
var crypto = require('crypto')

var crypto = require('crypto');

var mykey = crypto.createCipher('aes-128-cbc', 'mypassword');
var mystr = mykey.update('abc', 'utf8', 'hex')
mystr += mykey.final('hex');

var versions_server = http.createServer( (request, response) => {
    
  response.end('Crypto: ' + mystr);
//  response.end('Versions: ' + JSON.stringify(process.versions));
});
versions_server.listen(3000);
