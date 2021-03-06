const twit = require('twit');
const config = require('./config.js');
const http = require('http');
const fetch = require('node-fetch');
const towords = require('number-to-words');
const qrcode = require('qrcode-npm');
const wikifakt = require('wikifakt');

const Twitter = new twit(config);
var externalIp = '';

// Start checking server status 
postInfo();
setInterval(postInfo, 4 * 60 * 60 * 1000);

function dmTo(user, data) {
      console.log('Skickar DM om ny extern IP');
      var request = { 'event': { 
          'type': 'message_create',
          'message_create': {
              'target' : { 'recipient_id': user },
              'message_data' : { 'text': data }
          }
        } 
      };
      Twitter.post('direct_messages/events/new', request, 
            function (err, data, response) {
                if(err) {
                  console.log('DM failed');
                  console.log(err);
                }
            }
      );
}

function postInfo() {
      console.log('Posting to twitter ' + Date.now());
      getExternalIP().then((ip) => {
            console.log(`Min externa IP är just nu ${ip} och den sparade är ${externalIp}`);
            if(externalIp.length > 0 && ip != externalIp) {
                  dmTo('167767078', 'Jag har en ny ip-address verkar det som: ' + ip);
            }
            externalIp = ip;
            const a = ip.split('.');
            var ipwords = '';
            a.forEach(function (e) {
                  ipwords += towords.toWords(e) + '.';
            });

            wikifakt.getRandomFact().then((fact) => {
                var tweet = ip.replace(/\./g, '-') + '\n' + fact;
                console.log('Postar IP och random wikifakta');
                post(tweet.substring(0, 279));
            });

          /*
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
            */

      });

      getUptime().then((uptime) => {
           console.log('Postar status om uptime');
           post(uptime);
      });

}

function generateCode(data) {
      var qr = qrcode.qrcode(4, 'L');
      qr.addData(data);
      qr.make();
      var qrimgtag = qr.createImgTag(4);
      var idx = qrimgtag.indexOf("base64,") + 7;
      qrimgtag = qrimgtag.substring(idx);
      idx = qrimgtag.indexOf("\"");

      return qrimgtag.substring(0, idx);
}

function post(message) {
      Twitter.post('statuses/update', { status: message }, function (err, data, response) {
            if(err) {
                console.log('Error when posting:' + message);
                console.log(JSON.stringify(err));
            }
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
