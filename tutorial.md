# How to build a realtime chart in iOS
In the world we live in right now, gathering data is one of the keys to understanding how people perceive your products, seeing how people use your products, seeing how many people use your product…the list is endless. However, all the data in the world would be useless except there is a way to visualize them.

In this article, we will explore how to create a simple realtime chart in iOS. The chart will receive data and update in realtime to the screens of everyone currently logged into your iOS application. We will assume this is a chart that monitors how many visitors are using a website. Let’s begin.

For context, here is a sample of what we will be building:

![](https://www.dropbox.com/s/pobbjdhg6g59kwm/build-realtime-chart-in-ios-using-pusher.gif?raw=1)



## Requirements for building a realtime chart in iOS

Before we begin this tutorial, you will need to have the following requirements settled:


- A MacBook Pro
- [Xcode](https://developer.apple.com/xcode/) installed on your machine
- Basic knowledge of [Swift](https://developer.apple.com/swift/) and using Xcode
- Basic knowledge of JavaScript (NodeJS)
- [NodeJS](https://docs.npmjs.com/getting-started/installing-node) and NPM installed on your machine
- [Cocoapods](http://www.raywenderlich.com/12139/introduction-to-cocoapods) ****installed on your machine.
- A [Pusher](https://pusher.com) application.

If you have all the requirements, then we can begin.

## Preparing to create our realtime chart application in Xcode

Launch Xcode on your Mac and create a new project (call it whatever you want). Follow the new application wizard and create a new **Single-page application**. Once the project has been created, close Xcode and launch your terminal application.

In the terminal, `cd` to the root of the application directory. Then run the command `pod init`. This will generate a **Podfile**. Update the contents of the Podfile to the contents below (replace `PROJECT_NAME` with your project name):


    platform :ios, '9.0'
    target 'PROJECT_NAME' do
      use_frameworks!
      pod 'Charts', '~> 3.0.2'
      pod 'PusherSwift', '~> 4.1.0'
      pod 'Alamofire', '~> 4.4.0'
    end

Save the Podfile and then go to your terminal and run the command: `pod install`.

Running this command will install all the third-party packages we need to build our realtime iOS chart application.

The first package it will install is [Charts](https://github.com/danielgindi/Charts) which is a package for making beautiful charts on iOS. The second package is the Pusher swift SDK. The last package is [Alamofire](https://github.com/Alamofire/Alamofire); a package for making HTTP requests on iOS.

Once the installation is complete, open the `**.xcworkspace**` file in your project directory root. This should launch Xcode. Now we are ready to start creating our iOS application.


## Creating our realtime chart application views in Xcode

To begin, we will create the necessary views we need for our realtime chart application. Open the **Main.storyboard** file and let’s start designing our view.

First, create a rectangular view from edge to edge at the top of the View Controller in the storyboard. In that view, add a button and add the title “Simulate Visits”. Next, create another view that is also a rectangle, spanning from the end of the first view above to the bottom of the screen. This view will be where we will render the realtime chart.

When you are done creating the views, you should have something like what is shown in the image below.


![Realtime iOS Chart application using Pusher](https://www.dropbox.com/s/ct08rr61g9qhi7r/build-realtime-chart-in-ios-using-pusher-1.png?raw=1)


As it currently stands, the views do nothing. Let us connect some functionality to the iOS chart application view.


## Adding basic functionality to our iOS chart application

As said before, our application’s views and buttons are not connected to our `ViewController` so let’s fix that.

In Xcode, while the storyboard is still open, click on the “Show the Assistant Editor” button on the top right of the page to split the view into storyboard and code view. Now, click once on the button you created, and while holding `control`, click and drag the link to the code editor. Then create an `@IBaction` as seen in the images below:


![Create an @IBAction](https://www.dropbox.com/s/s6oklju8uxdrw76/build-realtime-chart-in-ios-using-pusher-2.png?raw=1)

![Create an @IBAction and name it simulateButtonPressed](https://www.dropbox.com/s/chzdgyzhzchr1kn/build-realtime-chart-in-ios-using-pusher-3.png?raw=1)


When the link is complete, you should see something like this added to the code editor:


    @IBAction func simulateButtonPressed(_ sender: Any) {
    }

Great! Now that you have created the first link, we will have to create one more link to the chart view.

On your storyboard, click the view and on the “Identity Inspection” tab, make sure the view is connected to `LineChartView`  as seen below.

![](https://www.dropbox.com/s/1hzuh0k1ns4anr3/build-realtime-chart-in-ios-using-pusher-4.png?raw=1)


Now that the view is connected to a view class, repeat the same we did before to link the button but this time, instead of creating an `@IBAction` we will create an `@IBOutlet`. Images are shown below:


![](https://www.dropbox.com/s/wkcrbm7txbiqwjf/build-realtime-chart-in-ios-using-pusher-5.png?raw=1)

![](https://www.dropbox.com/s/jxssa0behteaqkf/build-realtime-chart-in-ios-using-pusher-6.png?raw=1)


When the link is complete, you should see something like this added to the code editor:


    @IBOutlet weak var chartView: LineChartView!

Finally, at the top of the `ViewController` import the Charts package. You can add the code below right under the `import UIKit` in the `ViewController`.


    import Charts

Now that we have linked both elements to our code, every time the **Simulate Visits** button is pressed, the **simulateButtonPressed** function will be called.


## Adding realtime functionality to our iOS chart application

The final piece of the puzzle will be displaying a chart and making it update realtime across all devices viewing the chart.

To achieve this, we will do the following:


- We will create a function that updates our chart depending on the numbers
- Make our request button trigger a backend which will in turn send simulated data to Pusher
- We will create a function that listens for events from Pusher and when one is received, it triggers the update chart function we created earlier

**Create a trigger function to update our chart**
Let’s create the function that updates our chart depending on the number supplied to it. Open the `ViewController`, and in it, declare a class property right under the class declaration. We will use this property to track the visitors:


    var visitors: [Double] = []

Next, we will add the function that will do the actual update to the chart view:


    private func updateChart() {
        var chartEntry = [ChartDataEntry]()

        for i in 0..<visitors.count {
            let value = ChartDataEntry(x: Double(i), y: visitors[i])
            chartEntry.append(value)
        }

        let line = LineChartDataSet(values: chartEntry, label: "Visitor")
        line.colors = [UIColor.green]

        let data = LineChartData()
        data.addDataSet(line)

        chartView.data = data
        chartView.chartDescription?.text = "Visitors Count"
    }

In the code above, we declare `chartEntry` where we intend to store all our chart data, and then we loop through the available `visitors` then for each of them, we add a new `ChartDataEntry(x: Double(i), y: visitors[i])` that tells the chart the X and Y positions.

We also set the options for the chart by setting the color of the line chart. We create the `LineChartData` and add the `line` which contains our data points. Finally, we add the data to the `chartView` and set the chart view description.

**Make our simulate button call an endpoint**
The next thing we need to do is make our request button trigger a backend which will in turn send simulated data to Pusher.

To do this, we need to update the view controller one more time. In the `ViewController` import the Alamofire package right under the Charts package.


    import Alamofire

Now replace the `simulateButtonPressed` function with the code below:


    @IBAction func simulateButtonPressed(_ sender: Any) {
        Alamofire.request("http://localhost:4000/simulate", method: .post).validate().responseJSON { (response) in
            switch response.result {
            case .success(_):
                _ = "Successful"
            case .failure(let error):
                print(error)
            }
        }
    }

In the code below, we use Alamofire to send a POST request to http://localhost:4000/simulate (we will create this backend soon). We do not need to pass any parameters so we can keep the tutorial simple. We also do not need to do anything with the response. We just need the POST request to be sent every time the simulate visits button is pressed.

**Tie in realtime functionality using Pusher**
To make all these work, we will create a function that listens for events from Pusher and when one is received, we save the value to `visitors` and then trigger the update chart function we created earlier.

To do this, open the `ViewController` and import the `PusherSwift` SDK under the Alamofire package at the top:


    import PusherSwift

Next, we will declare a class property for the Pusher instance. We can do this right under the `visitors` declaration line:


    var pusher: Pusher!

Then after declaring the property, we need to add the function below to the class so it can listen in to events:


    private func listenForChartUpdates() {
        pusher = Pusher(key: "PUSHER_KEY", options: PusherClientOptions(host: .cluster("PUSHER_CLUSTER")))

        let channel = pusher.subscribe("visitorsCount")

        channel.bind(eventName: "addNumber", callback: { (data: Any?) -> Void in
            if let data = data as? [String: AnyObject] {
                let count = data["count"] as! Double
                self.visitors.append(count)
                self.updateChart()
            }
        })

        pusher.connect()
    }

In the code above, we instantiate Pusher, then we pass in our key and the cluster (you can get your key and cluster from your Pusher application’s dashboard). We then subscribe to the `visitorsChannel` and bind to the event name `addNumber` on that channel.

When the event is triggered, we fire the logic in the callback which simply appends the count to `visitors` and then calls the `updateChart` function which updates the actual Chart in realtime.

Finally we call `pusher.connect()` which forms the web socket connection to Pusher.

In the `viewDidLoad` function just add a call to the `listenForChartUpdates` method.


    override func viewDidLoad() {
        super.viewDidLoad()

        // ...stuff

        listenForChartUpdates()
    }

That’s all! We have created our application in Xcode and we are ready for testing. However, to test, we need to create the backend that we send a post request to when the button is clicked. To create this backend, we will be using NodeJS. Let’s do that now.


## Creating the backend service for our realtime iOS chart application

To get started, create a directory for the web application and then create some new files inside the directory:

File: **index.js**


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

The file above is a simple Express JS application written in JavaScript. We instantiate all the packages we require and configure pusher using a config file we will create soon. Then we create a route `/simulate` and in this route we trigger the `addNumber` event in the `visitorCount` channel. The same channel and event the application is listening for.

To make it a little easy, we use `setInterval` to send a random visitor count to the Pusher backend every 2000 milliseconds. After looping for 20 times, the loop stops. This should be sufficient to test our application.

Create the next file **config.js**:


    module.exports = {
        appId: 'PUSHER_APP_ID',
        key: 'PUSHER_APP_KEY',
        secret: 'PUSHER_APP_SECRET',
        cluster: 'PUSHER_APP_CLUSTER',
    };

Replace the `PUSHER_APP_*` keys with the credentials from your own Pusher application.

The next and final file is **package.json**:


    {
      "main": "index.js",
      "dependencies": {
        "body-parser": "^1.16.0",
        "express": "^4.14.1",
        "pusher": "^1.5.1"
      }
    }

In this file we simply declare dependencies.

Now open terminal and `cd` to the root of the web application directory and run the commands below to install the NPM dependencies and run the application respectively:


    $ npm install
    $ node index.js

When installation is complete and the application is ready you should see the output below:

![](https://www.dropbox.com/s/t8vjw4d4o22jdxt/build-realtime-chart-in-ios-using-pusher-7.png?raw=1)

## Testing the application

Once you have your local node web server running, you will need to make some changes so your application can talk to the local web server. In the `info.plist` file, make the following changes:


![](https://www.dropbox.com/s/dowldt75ws70cnk/build-realtime-chart-in-ios-using-pusher-8.png?raw=1)


With this change, you can build and run your application and it will talk directly with your local web application.


## Conclusion

This article has shown you how you can combine Pusher and the Charts package to create a realtime iOS chart application. There are many other chart types you can create using the package but for brevity, we have done the easiest. You can explore the other chart types and even pass in multiple data points per request.

If you have any questions, feedback or corrections, you can post them in the comments section below.

The source code to the tutorial above is available on [GitHub](https://github.com).

