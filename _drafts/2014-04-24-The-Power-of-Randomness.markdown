---
layout: post
title: "The Power of Randomness"
author: Robert Miller
author_avatar: http://www.redbeacon.com/media/about/images/Robert.jpg
excerpt: "A survey of the sometimes surprising ways randomness can be used as a powerful tool."
---

<img src="{{ site.baseurl }}assets/images/Pi_30K.gif" style="width: 65% !important; float: right;">
If you have never thought about this topic before, you might be surprised at the things you can do with random numbers. For example, you can generate random points in the unit square to approximate π. (Hint: the area of the quarter circle is π/4.)

This is a terrible example because the approximation converges very slowly. But it is easy enough to implement:
<div style="clear: both"></div>
{% highlight python %}
import random
def approximate_pi(n):
    n_in_circle = 0
    for _ in xrange(n):
        x = random.random()
        y = random.random()
        if x**2 + y**2 < 1:
            n_in_circle += 1
    return 4.0*n_in_circle/n
{% endhighlight %}
If you want fast convergence, the last few records for digits of π have been achieved using the <a href="http://en.wikipedia.org/wiki/Chudnovsky_algorithm" target="_blank">Chudnovsky algorithm</a>, a deterministic algorithm based on this series:
<div style="text-align: center">
<img src="{{ site.baseurl }}assets/images/chudnovsky.png" style="width: inherit !important">.
</div>
In the following, we'll discuss some more impressive examples.

Las Vegas and Monte Carlo Algorithms
------------------------------------

First off, let's get a little formal. We'll be talking about randomized algorithms-- these are algorithms that have access to a random number generator (RNG). It isn't easy for a deterministic computer to generate random numbers. In fact it is impossible, so we must settle for <a href="http://en.wikipedia.org/wiki/Cryptographically_secure_pseudorandom_number_generator" target="_blank">pseudorandom</a>. But for the purposes of this blog post, we'll blur the lines and just assume we have access to an RNG.

A <a href="http://en.wikipedia.org/wiki/Monte_Carlo_algorithm" target="_blank">Monte Carlo algorithm</a> is essentially a randomized algorithm that is allowed to make mistakes, as long as they are not that common. It runs using a deterministic amount of resources (time and memory), and there is some small probability of error.

A <a href="http://en.wikipedia.org/wiki/Las_Vegas_algorithm" target="_blank">Las Vegas algorithm</a> is a randomized algorithm that is not allowed to make mistakes, but it can take up an unpredictable amount of resources. Since being an algorithm means that it terminates, this is a slightly abusive name. You can't say every Las Vegas algorithm is guaranteed to terminate, <a href="http://en.wikipedia.org/wiki/Almost_surely" target="_blank">even if the probability is 1</a>.

Any Las Vegas algorithm can be converted into a Monte Carlo algorithm simply by limiting the resources available and returning a random result if they run out. If you have a way of determining correctness of output, then a Monte Carlo algorithm can be converted into a Las Vegas one by running it multiple times and returning once you have a correct result.

A brief diversion: <a href="https://www.youtube.com/watch?v=NbInZ5oJ0bc" target="_blank">This scene</a> of <i>Rosencrantz and Guildenstern Are Dead</i> makes a very good point about the subtlety of probability. Because something improbable happens Guildenstern wrongly assumes that the law of probability has been suspended. The dramatic irony is that it has been, since Tom Stoppard has written it to be so!

Avoiding Things
---------------

<a href="http://en.wikipedia.org/wiki/Quicksort">Quicksort</a> is a <a href="http://cs.stackexchange.com/questions/3/why-is-quicksort-better-than-other-sorting-algorithms-in-practice" target="_blank">fast</a> sorting algorithm which is often claimed to outperform other sorts in practice.

load balancing
quicksort
local minima

Finding Things
--------------

<a href="http://www.mapequation.org/apps/MapDemo.html">clustering</a>
factors
polynomial equality testing
subgroups

Hiding Things
-------------

cryptography

Simplifying Things
------------------

random projections
sampling




