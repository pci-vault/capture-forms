PCI Vault PCD Form
===

This PCD (Payment Card Data) form makes it easy for you to collect payment card data and
submitting it to the PCIVault without touching your own servers.

You can use the form by adding `pcd_form.js` and `pcd_form.css` to your page, and calling
`window.pcd_form()` from your own javascript: Here's a quick example:
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <link rel="stylesheet" href="https://api.pcivault.io/pcd/LATEST/pcd_form.css" />
  <script src="https://api.pcivault.io/pcd/LATEST/pcd_form.js"></script>
</head>
<body>
  <div id="pcd_form"></div>

  <script defer>
      window.pcd_form(document.getElementById("pcd_form"), {
          submit_secret: "your_secret_here",
          submit_url: "/v1/capture/demo",
      })
  </script>
</body>
</html>
```

The first argument to the `pcd_form` method is the DOM element where you want to mount
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

reference
---
Optional, default: `""`. A unique reference to be submitted to the capture endpoint.

strip_spaces
---
Optional, default: `false`. Remove any and all spaces in the card number. This field only strips spaces from the card number, and no other field.

extra_data
---
Optional, default: `{}`. A javascript object that will be submitted along with the
payment card data. The following field of this object will be overwritten by form
input: `card_number`, `card_holder`, `cvv`, `expiry`. If `extra_data` is not an object,
the submission behaviour will be undefined.

hide_card
---
Optional, default: `false`. Make this `true` to hide the example credit card.

disable_luhn
---
Optional, default: `false`. The PCD form validates the credit card number against luhn's
algorithm by default. This behaviour can be switched off by setting this to `true`.

force_keypad
---
Optional, default: `false`. Setting this option to `true` will disable keyboard input for the card number field. Instead, a randomised keypad will be displayed on the screen for the user to input the card number with the mouse. This is handy for preventing key-logger exploits.

field_options
---
Optional, default: `{}`. A javascript object, specifying which fields to validate or display. The following keys are accepted in the object: `card_number`, `card_holder`, `expiry`, `reference` and `cvv`. Each of these keys are optional, but must have an object value with `validate` and/or `visible` as keys containing `true` or `false` as values. Unspecified, undefined, or null keys will be overridden by `true` values. Invisible fields will not be validated.

theme
---
Optional, default: 
```json
{
  "primary_color": "#009844",
  "success_color": "#12b331",
  "error_color": "#ff0000",
  "card_shadow_color": "#069848",
  "card_primary_color": "#68B645",
  "logo_image": ""
}
```
A javascript object, specifying custom colours for the card image, buttons and messages.

