PCIVault ACH Data Form
===

This ACH Data form makes it easy for you to collect ach data and
submitting it to the PCIVault without touching your own servers.

You can use the form by adding `ach_form.js` and `ach_form.css` to your page, and calling
`window.ach_form()` from your own javascript: Here's a quick example:
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <link rel="stylesheet" href="https://api.pcivault.io/ach/ach_form.css" />
  <script src="https://api.pcivault.io/ach/ach_form.js"></script>
</head>
<body>
  <div id="ach_form"></div>

  <script defer>
      window.pcd_form(document.getElementById("ach_form"), {
          submit_secret: "your_secret_here",
          submit_url: "/v1/capture/demo",
      })
  </script>
</body>
</html>
```

The first argument to the `ach_form` method is the DOM element where you want to mount
the form. The second argument is a settings object, of which `submit_secret` 
and `submit_url` is required. These two values can be obtained by making a POST request
to `/v1/capture` on the PCIVault API. All the options are documented below:

submit_secret
---
Required. This is the secret associated to the capture endpoint that was created through our API.

submit_url
---
Required. The capture endpoint to use. The format must be `/v1/capture/{unique_endpoint_name}`.

success_callback
---
Optional, default: `() => {}`. A javascript function to call if the card was successfully
submitted. The function will be invoked with one argument, which contains the result 
from PCIVault in a JSON object. The result typically looks like this:
```json
{
  "user": "DDD1",
  "token": "63eb17a9e5561ba4efd655c2ccf16e4595bc605b3602b7fb59d8ef6d0d7f2c0c",
  "reference": "DD0137EM"
}
```

error_callback
---
Optional, default: `() => {}`. A javascript function to call if submission failed.
The function will be invoked with one argument, a JSON object which contains the HTTP error code
and the response body of the HTTP request. For example:
```json
{
  "status": 400,
  "data": {
    "error": "Descriptive Error Message."
  }
}
```

extra_data
---
Optional, default: `{}`. A javascript object that will be submitted along with the
payment card data. The following field of this object will be overwritten by form
input: `card_number`, `card_holder`, `cvv`, `expiry`. If `extra_data` is not an object,
the submission behaviour will be undefined.
