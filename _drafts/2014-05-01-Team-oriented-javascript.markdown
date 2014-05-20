---
layout: post
title: "Team Oriented javascript"
author: Sean Caetano Martin
author_avatar: http://www.redbeacon.com/media/about/images/Sean.jpg
excerpt: "Share testable code accross teams and implementations"
---

Here at work, we like the cutting edge, and we like test coverage. The two don't always play nice with each other. Each framework has its own test suits, and most of the time the code with test coverage is very attached to the framework we were using at the time of implementation. Refactoring these bits to play nice with the new framework is too time-consuming, so we hack a new version of the code that does the same thing but uses the new, modern framework. Now we have duplicate functionality and have a hole in our tests that is being shadowed by the coverage of the original code. We can do better than this.

How can we avoid this pattern, specially as the team grows and takes on more projects? We surely don't want to use the framework we started with 4 years ago, and we don't want to re write our code base every 4 years. Design iteration adds even more complexity to this, as it's not unusual to update the design of page, re-brand or tweak. More often than not, these involve changes in the business logic, which in turn requires changes in the code. At this point, I would push back on the design team and tell them that we need spare cycles to clean up old code to properly accommodate the new changes. It's a battle I usually loose (with good reason, since the extra cycles wasted to not contribute to business goals directly) and end up with either the hack I described in the previous paragraph, or by sticking with the existing framework and doing the best we can to ignore the juicy new things that weren't available back when this code was new.

The solution we've come to, is simple, sexy and elegant. I got to it when I was researching how commonly used libraries and frameworks package their javascript. If you are familiar with the implementation of Bootstrap's jQuery plugins you'll see what I'm going for. For shared code, we use javascript prototypes and bundle them with their dependencies, and the less dependencies the better. Along with these we add adapters that implement the 3rd party syntax around the original prototype. This way, as long as the prototype is well tested, the only place for errors is in the adapters, and those are caught by integration tests.

Breaking this code apart is not easy, so I want to introduce 3 concepts: the bundle, the prototype, and the adapters. I'll go over these one by one:

### The Prototype

This is your code, your fancy algorithm that implements your disruptive business logic. Something you want to test once and share with your whole team so that no one else has to ever duplicate it. This usually consists of one or more javascript prototype definitions and it's respective test suits. At this point you don't have a hard dependency on any test framework because you are writing in a format that is native to the language itself. I have found that the biggest use case for this are data models and their attached logic.

Example:
{% highlight javascript %}
function User(options) {
    // build the user properties from options
    // options can be anything that can be passed in s JSON format
}

User.prototype = {
    toJSON: function () { /* ... */ },
    signin: function () { /* ... */ },
    // etc ...
};
{% endhighlight %}

### The Adapters

These guys are what makes your code shareable across different frameworks and products. Because all you are loading is standard javascript you can easily write an adapter layer with framework specific syntax that uses the prototype above, I'll give you a couple examples:

With Backbone.js:

{% highlight javascript %}
var BackboneUserModel = Backbone.Model.extend({
    constructor: function (options) {
        this._user = new User(options);
        Backbone.Model.apply(this, this._user.toJSON());
    },

    signin: function () {
        return this._user.signin();
    },

    // etc...
});
{% endhighlight %}

With AngularJS:

*Note*: I realize that there could be a ton of ways to do this in AngularJS, so I'll just stick with this minimal example. It's possible that the best place to use this example would have been in an interceptor.

{% highlight javascript %}
MyResource.get({ param: 'value' }, function (res) {
    var myUser = new User(res);
    // etc ...
});
{% endhighlight %}

With jQuery:

{% highlight javascript %}
$.fn.myUser = function () {
    // Do things with the User proto.
};

$(function () {
    $('.user-container').myUser();
});
{% endhighlight %}

### The Bundle

This is what you share with your team. At it's simple it can be a single JS file that contains everything, or it can get as fancy as a folder with a `package.json` file that integrates in your build process.  How complicated it gets is entirely up to you and your existing setup. A couple of things to look at for reference could be Bootstrap jQuery plugins or a Bower or NPM module structure. 

*Note*: This is the folder structure I have been using for my little projects. I've set up my [grunt](http://gruntjs.com/) build system to minify and concatenate the prototype and the adapters together. After that it will add the dependencies if they haven't been added by another plugin yet. The dependencies file is a simple json description of dependencies and where to get them. So far it's working great.

    MyPlugin
        MyPluginsPrototype.js
        Adapters.js
        dependencies.json

As I said before there are some downsides to this, perhaps the most glaring one is that you need to commit extra time to write the adapters, or delegate that to whoever will need to use your prototype later. We decided to live with this because if we follow this pattern we won't have to do big rewrites later on, and we won't have the urge to duplicate code that is already tested.

This is a really new concept for our team that solves a problem we face here every day. If this helps your team or you have suggestions on how to make this even better or even other solutions, we would love to hear from you!
