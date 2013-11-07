---
layout: post
title: Promises as Helpers for Async QUnit Testing
excerpt: "Writing QUnit is fun and very useful to keep your code future-proof, but sometimes you need to handle some hairy asynchronous flows and then your tests become hard to read."
author_avatar: http://www.redbeacon.com/media/about/images/Dummy.jpg
author: Lorenzo Gil
---

Writing QUnit is fun and very useful to keep your code future-proof, but sometimes you need to handle some hairy asynchronous flows and then your tests become hard to read.

Let me show you an example of what I mean:

{% highlight javascript %}
test('test with many async calls', function () {
    strictEqual($('a.first-link').length, 1,
                'There is link with a "first-link" class');
    strictEqual($('#initialy-hidden-element').is(':visible'), false);

    // After clicking on the link, the hidden element
    // will be faded in (3 seconds)
    $('a.first-link').click();

    stop();

    _.delay(_.bind(function () {
        start();

        strictEqual($('#initialy-hidden-element').is(':visible'), true);
        strictEqual($('a.second-link').length, 1,
                    'There is link with a "second-link" class');

        // After clicking on the second link, a very expensive computation
        //  is done, so in order to not block the main thread, the code
        // will call setTimeout(..., 0);
        $('a.second-link').click();

        stop();

        _.defer(_.bind(function () {
            start();

            strictEqual($('#expensive-computation-result').text(), '3.1416');
            strictEqual($('a.third-link').length, 1,
                        'There is link with a "third-link" class');
            strictEqual($('#streched-element').width(), 10);

            // After clicking on the third link, there will be an animation
            $('a.third-link').click();

            stop();

            _.delay(_.bind(function () {
                start();
                strictEqual($('#streched-element').width(), 500);
            }, 5000, this);
        }, this);
    }, 3000, this));
});
{% endhighlight %}

As you can see, we have a serious stairway to hell syndrome here. There should be a better way to write this test. Something like this:

{% highlight javascript %}
test('test with many async calls', function () {
    strictEqual($('a.first-link').length, 1,
                'There is link with a "first-link" class');
    strictEqual($('#initialy-hidden-element').is(':visible'), false);

    // After clicking on the link, the hidden element will be faded in (3 seconds)
    $('a.first-link').click();

    var secondStep = createDelayedStep(function () {
        strictEqual($('#initialy-hidden-element').is(':visible'), true);
        strictEqual($('a.second-link').length, 1,
                      'There is link with a "second-link" class');

        // After clicking on the second link, a very expensive computation
        // is done so in order to not block the main thread, the code will
        //  call setTimeout(..., 0);
        $('a.second-link').click();
    }, 3000, this);

    var thirdStep = createDeferredStep(function () {
        strictEqual($('#expensive-computation-result').text(), '3.1416');
        strictEqual($('a.third-link').length, 1,
                    'There is link with a "third-link" class');
        strictEqual($('#streched-element').width(), 10);

        // After clicking on the third link there will be an animation
        $('a.third-link').click();
    }, this);

    var fourthStep = createDelayedStep(function () {
        strictEqual($('#streched-element').width(), 500);
    }, 5000, this);

    stop();

    secondStep()
      .pipe(thirdStep)
      .pipe(fourthStep)
      .pipe(start);
});
{% endhighlight %}

Now we just define steps and run them one after the other. All the magic is on the createDeferredStep and createDelayedStep functions. Let me show you:

{% highlight javascript %}
var createDeferredStep = function (step, context) {
    return function () {
        var outterArguments = arguments;
        var deferred = $.Deferred();

        _.defer(_.bind(function () {
            start();
            var result = step.apply(context, outterArguments);
            stop();
            deferred.resolve(result);
        }, context));

        return deferred.promise();
    };
};

var createDelayedStep = function (step, delay, context) {
    return function () {
        var outterArguments = arguments;
        var deferred = $.Deferred();

        _.delay(_.bind(function () {
            start();
            var result = step.apply(context, outterArguments);
            stop();
            deferred.resolve(result);
        }, context), delay);

        return deferred.promise();
    };
};
{% endhighlight %}

As you can see we are using jQuery Deferred and Promises object to make our async steps run in serial. Each deferred will resolve with the result of the step function, which will be passed as an argument to the next step.

Oh, note that I'm using the pipe method to orchestrate all the steps. That's because we have a pretty old jQuery version (1.7) in this particular page. If you use a recent jQuery, you probably want to replace that method with the .then() method.

That's all for today. I hope you find this syntactic sugar useful!
