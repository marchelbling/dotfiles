module.exports = {
  defaultBrowser: "Firefox",
  options: {
    // Hide the finicky icon from the top bar. Default: false
    hideIcon: true,
    // Check for update on startup. Default: true
    checkForUpdate: true,
  },
  handlers: [
    {
      // Open apple.com and example.org urls in Safari
      match: ["apple.com/*"],
      browser: "Safari"
    },
    {
      // Open GCP and Datadog urls in Google Chrome
      match: [
        "https://console.cloud.google.com/*", // match GCP
        "https://*.datadoghq.com/*", // match Datadog
      ],
      browser: "Google Chrome"
    }
  ]
};