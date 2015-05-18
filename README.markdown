# Garage Tool

This is for integrating a [Chamberlain MyQ](https://www.amazon.com/gp/product/B00EAD65UW/?tag=cc0a0-20) into OpenHAB.

The Chamberlain MyQ is a terrible device with a closed ecosytem that often crashes.  I recommend you don't get one.  
But if you do, this can help keep OpenHAB up on it.

### Requirements

- Ruby (2.1+)
- [Chamberlain MyQ](https://www.amazon.com/gp/product/B00EAD65UW/?tag=cc0a0-20)
- OpenHAB

### Installation

- Clone this repo `git clone https://www.github.com/JustinAiken/garage`
- `cd garage`
- `cp settings.sample.yml settings.yml` and edit to taste

### Usage

- See status: `bin/garage status`
- Post status to openHAB: `bin/garage update`
- Open garage door: `bin/garage open`
- Close garage door: `bin/garage close`

### OpenHAB Use

- I install this on the same rPI running openHAB
- I add a cronjob that runs the `bin/garage update`
- When a garage opener `Switch` item is pressed, it does the open/close command

### Credits

- Author: [JustinAiken](https://github.com/JustinAiken)
- Lots of MyQ API interactions borrowed from the [liftmaster_myq gem](https://github.com/pfeffed/liftmaster_myq).

[MIT](LICENSE)
