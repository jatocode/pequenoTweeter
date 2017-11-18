const twit = require('twit');
const config = require('./config.js');
const http = require('http');
const fetch = require('node-fetch');
const towords = require('number-to-words');
const qrcode = require('qrcode-npm');

const Twitter = new twit(config);

/*
Twitter.post('statuses/update', { status: 'hello world!' }, function(err, data, response) {
      console.log(data)
})
*/


getExternalIP().then((ip) => {
      console.log(ip);
      const a = ip.split('.');
      var ipwords = '';
      a.forEach(function (e) {
            ipwords += towords.toWords(e) + '.';
      });
      console.log(ipwords);

      //post(ip);
      const b64content = generateCode(ip);
      Twitter.post('media/upload', { media_data: b64content }, function (err, data, response) {
            // now we can assign alt text to the media, for use by screen readers and
            // other text-based presentations and interpreters
            var mediaIdStr = data.media_id_string
            var altText = "I'm right here"
            var meta_params = { media_id: mediaIdStr, alt_text: { text: altText } }

            Twitter.post('media/metadata/create', meta_params, function (err, data, response) {
                  if (!err) {
                        // now we can reference the media and post a tweet (media will attach to the tweet)
                        var params = { status: ipwords, media_ids: [mediaIdStr] }

                        Twitter.post('statuses/update', params, function (err, data, response) {
                              console.log('Posted media')
                        })
                  } else {
                        console.log('Error when posting');
                        console.log(err);
                  }
            })
      })
      
});

getUptime().then((uptime) => {
      console.log(uptime);
      //post(uptime);
});

function generateCode(data) {
      var qr = qrcode.qrcode(4, 'L');
      qr.addData(data);
      qr.make();
      var qrimgtag = qr.createImgTag(4);
      var idx = qrimgtag.indexOf("base64,") + 7;
      qrimgtag = qrimgtag.substring(idx);
      idx = qrimgtag.indexOf("\"");
      
      return qrimgtag.substring(0,idx);
} 
      
function post(message) {
Twitter.post('statuses/updae ', { status: message }, function (err, data, response) {
                console.log(data) 
      })
}

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
                  return json.ip;
            });
}
