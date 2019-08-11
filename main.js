var ScreenshotClass = require("@brightsign/screenshot");
var screenshot = new ScreenshotClass();

function takeAsyncScreenshot(args) {
    screenshot.asyncCapture(args).then().catch();
};

screenshotParams = {};
screenshotParams.fileName = "SD:/screen.jpg";
screenshotParams.quality = 75;

setInterval(takeAsyncScreenshot(screenshotParams), 5000);
