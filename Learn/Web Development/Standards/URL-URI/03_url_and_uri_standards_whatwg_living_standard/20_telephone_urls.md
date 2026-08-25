## Telephone URLs


Telephone URLs enable click-to-call functionality on devices with telephony capabilities. They use the tel: scheme defined in RFC 3966.

Syntax: `tel:phone-number[;parameter][?parameter]`

**Example:**

```
tel:+1-201-555-0123
tel:+1-201-555-0123;ext=123
tel:+1-201-555-0123;phone-context=+1-201
```

Phone numbers should include country codes using + notation. Extensions can be specified using ";ext=" parameter. The tel: scheme initiates the default phone application on supported devices.

