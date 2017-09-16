let Pusher     = require('pusher');
let express    = require('express');
let bodyParser = require('body-parser');
let app        = express();
let pusher     = new Pusher(require('./config.js'));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.post('/simulate', (req, res, next) => {
  var loopCount = 0;

  let sendToPusher = setInterval(function(){
    let count = Math.floor((Math.random() * (100 - 1)) + 1)
    pusher.trigger('visitorsCount', 'addNumber', {count:count})

    loopCount++;
    if (loopCount === 20) {
      clearInterval(sendToPusher);
    }
  }, 2000);

  res.json({success: 200})
})

app.get('/', (req, res) => {
  res.json("It works!");
});

app.use((req, res, next) => {
    let err = new Error('Not Found');
    err.status = 404;
    next(err);
});

app.listen(4000, function(){
    console.log('App listening on port 4000!')
});
