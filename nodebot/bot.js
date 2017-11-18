const twit = require('twit');
const config = require('./config.js');
const http = require('http');
const fetch = require('node-fetch');
const towords = require('number-to-words');

const Twitter = new twit(config);

/*
Twitter.post('statuses/update', { status: 'hello world!' }, function(err, data, response) {
      console.log(data)
})
*/


getExternalIP().then((data) => {
      console.log(data);
      console.log(getUptime().then((data) => {
            console.log(data);
      }));
});

function getUptime() {
      const child = require('child_process');
      return new Promise((resolve, reject) => {
            child.exec('uptime', function (error, stdout, stderr) {
                  resolve(stdout);
            });
      });
}

function getExternalIP() {
      return fetch('https://api.ipify.org?format=json')
            .then(function (res) {
                  return res.json();
            }).then(function (json) {
                  const a = json.ip.split('.');
                  var str = '';
                  a.forEach(function (e) {
                        str += towords.toWords(e) + '.';
                  });
                  return str;
                  //console.log(json.ip + ' = ' + str);
            });
}
