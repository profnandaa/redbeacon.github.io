---
layout: post
title: "The Power of Randomness"
author: Robert Miller
author_avatar: http://www.redbeacon.com/media/about/images/Robert.jpg
excerpt: "A survey of the sometimes surprising ways randomness can be used as a powerful tool."
---

<img src="{{ site.baseurl }}assets/images/Pi_30K.gif" style="width: 65% !important; float: right;">
If you have never thought about this topic before, you might be surprised at the things you can do with random numbers. For example, you can generate random points in the unit square to approximate π. (Hint: the area of the quarter circle is π/4 and the area of the square is 1.)

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
If you want fast convergence, the last few records for digits of π have been achieved using the <a href="http://en.wikipedia.org/wiki/Chudnovsky_algorithm">Chudnovsky algorithm</a>, a deterministic algorithm based on this hypergeometric series:
<div style="text-align: center">
<img src="{{ site.baseurl }}assets/images/chudnovsky.png" style="width: inherit !important">
</div>
In the following, we'll discuss some more impressive examples.

Las Vegas and Monte Carlo Algorithms
------------------------------------

First off, let's get a little formal. We'll be talking about randomized algorithms-- these are algorithms that have access to a random number generator (RNG). It isn't easy for a deterministic computer to generate random numbers. In fact it is impossible, so we must settle for <a href="http://en.wikipedia.org/wiki/Cryptographically_secure_pseudorandom_number_generator">pseudorandom</a>. But for the purposes of this blog post, we'll blur the lines and just assume we have access to a RNG.

A <a href="http://en.wikipedia.org/wiki/Monte_Carlo_algorithm">Monte Carlo algorithm</a> is essentially a randomized algorithm that is allowed to make mistakes, as long as they are not that common. It runs using a deterministic amount of resources (time and memory), and there is some small probability ε of error.

A <a href="http://en.wikipedia.org/wiki/Las_Vegas_algorithm">Las Vegas algorithm</a> is a randomized algorithm that is not allowed to make mistakes, but it can take up an unpredictable amount of resources. Since being an algorithm means that it terminates, this is a slightly abusive name. You can't say every Las Vegas algorithm is guaranteed to terminate, <a href="http://en.wikipedia.org/wiki/Almost_surely">even if the probability is 1</a>!

Any Las Vegas algorithm can be converted into a Monte Carlo algorithm simply by limiting the resources available and returning a random result if they run out. If you have a way of determining correctness of output, then a Monte Carlo algorithm can be converted into a Las Vegas one by running it multiple times and returning once you have a correct result.

Avoiding Things
---------------

load balancing
quicksort
local minima

Finding Things
--------------

clustering
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




