---
layout: post
title: "My love affair with AngularJS"
author: Sean Caetano Martin
author_avatar: http://www.redbeacon.com/media/about/images/Sean.jpg
excerpt: "An ode to AngularJS and the benefits it brings to frontend development."
---

After completing a 4-month sprint building a new product with AngularJS, I can honestly say that when it comes to frontend development, Angular is my choice.  I've seen countless posts questioning it and its approach, design, and team. I'm here to show that the opposite also exists and why it worked so incredibly well for us.

Angular is a framework, not a library. It does not simply give you the tools to get the job done (Backbone, I'm looking at you), but it also structures your code base. While this is something most commonly seen in backend frameworks like ExpressJS or Django, it is great for a team of engineers to have it on the front end as well. I can't tell how many times I had to do some *grepping* to find out where some Javascript code is so I can update it. This costs time for developers and creates code that changes *automagically*. What I mean is that without knowing all the components of your frontend app, a seemingly simple change can have horrible impact on other parts of your code.

Another way to look at Angular is to give it the sheriff's star in the cowboy land of frontend development. The lack of official documentation and the ever decreasing differences between browser implementations groomed a culture of "whatever gets the job done." The *Angular way* tries to change that. You can no longer just shoehorn your favorite third party plugin at the bottom of the HTML file and call it done. Most of the time, as soon as you touch the DOM inside your Angular app, Angular will throw a few errors your way. That's what you get for using shortcuts. So something like this, using jQuery would not work:

{% highlight javascript %}
$(function () {
    $('[mRelativeTime]').each(function (idx, el) {
        var ts = $(el).attr('mRelativeTime'),
            m = moment.unix(ts);

        $(el).text(m.local().fromNow());
    });
});
{% endhighlight %}

So what do you do? You still want to use that third party script, and you don't want to rewrite it. You wrap it in a directive and *introduce* it to Angular this way. Now you can allow it to change your DOM safely without Angular throwing any errors. This is important, because now any engineer knows that if something is changing the DOM, it will be in the `directives.js` file. Here is an example of what that looks like:

{% highlight javascript %}
// moment js time directive, converts time to local, and shows relative¬
// time.¬
.directive('mRelativeTime', [function () {
    return function (scope, el, attr) {
        scope.$watch(attr.mRelativeTime, function (ts, old) {
            ts = Number(ts);
            var m = moment.unix(ts);
            el.text(m.local().fromNow());
        });
    };
}])
{% endhighlight %}

In this example, if I had gone in outside of a directive and started changing the times, Angular would freak out. Rightfully so, because I would have destroyed the DOM that Angular was using as its template. Angular doesn't use string-based templates; it uses the DOM itself.

This approach is the same for controllers, services, and filters. You have a file for each, and they are neatly placed in the most useful folder structure. As opposed to having controller logic inside a view that is acting as a controller, seen in so many Backbone apps. I'll show you what I mean: If you compare [this Backbone view](https://github.com/tastejs/todomvc/blob/gh-pages/architecture-examples/backbone/js/views/todo-view.js) to [this Angular controller](https://github.com/tastejs/todomvc/blob/gh-pages/architecture-examples/angularjs/js/controllers/todoCtrl.js), you'll notice that they are similar, but the Backbone view does the controller logic and renders the view itself. On the other hand, the Angular controller only contains logic and no rendering-related code. I'm of the opinion that the latter is the correct way to create a clean and organized codebase that is intuitive to all engineers in the team and not only the one with the *tribal knowledge* (expression used to imply that only some *tribe* members have the know-how).

If you're having a hard time coming up with a useful folder structure, just follow [Angular's seed app](https://github.com/angular/angular-seed). In the end, the goal is to have a sound way to structure your code base: something that works for everyone in your team and that helps each engineer find what they need to work on quickly.

Now, no love affair is perfect, and mine and Angular's it's not an exception. I would like to see the Angular team spend more time addressing the people who use their code. The documentation leaves a lot to be desired, because it's sometimes incomplete or out of sync, leaving the actual source code as the only source of truth. Now this is not cumbersome for an experienced engineer, but it's daunting for a new engineer to even read, much less understand. The Angular source code is not the most straightforward implementation. There is also another issue, and I see this one as being pretty bad: Angular is not accepting any pull requests to add projects to [Built with Angular](http://builtwith.angularjs.org/). This is where the Angular community can showcase the amazing things you can accomplish with this wonderful framework, and it is very sad to see so many projects being ignored for months, especially because all we wanted was to give Angular some *street cred*.

You can see our work with Angular live at [Redbeacon Experts](//redbeacon.com/experts).
