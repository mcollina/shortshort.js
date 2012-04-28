# ShortShort.js: a really short URL shortener library

**ShortShort.js** is a short library to encode and resolve URLs
and other content to a base62 strings.
It uses [Redis](http://redis.io) as a backend.

## Installation instruction

```
npm install shortshort
```

## Usage

```
var redis = require("redis");
var ShortShort = require("shortshort");

var shortener = new ShortShort(redis.createClient());

shortener.shorten("http://www.google.com", function(err, result) {
  console.log("Your key is " + result.key);

  shortener.resolve(result.key, function(err, url) {
    console.log("The encoded url by key " + result.key + " is " + url);
  });
});

```

## Configuration options

When you create a new **ShortShort** instance, you have the ability to
specify some of the behaviour of **ShortShort**.
You may pass:
* `validation`: to validate the first argument of shorten against an URL
  regexp. It defaults to true.
* `globalCounter`: to specify the name of the redis key that will be
  used to generate the global identifiers. It defaults to
  `ss-global-counter`.
* `keyPrefix`: the prefix that will be used to save the shortened keys
   in redis. It defaults to `ss-key-`.

## Contributing to ShortShort

* Check out the latest master to make sure the feature hasn't been
  implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't
  requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it
  in a future version unintentionally.
* Please try not to mess with the Cakefile and package.json. If you
  want to have your own version, or is otherwise necessary, that is
  fine, but please isolate to its own commit so I can cherry-pick around
  it.

## LICENSE - "MIT License"

Copyright (c) 2012 Matteo Collina, http://matteocollina.com

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
