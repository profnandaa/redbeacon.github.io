---
layout: post
title: "The Power of Randomness"
author: Robert Miller
author_avatar: http://www.redbeacon.com/media/about/images/Robert.jpg
excerpt: "A survey of the sometimes surprising ways randomness can be used as a powerful tool."
---

<img src="{{ site.baseurl }}assets/images/Pi_30K.gif" style="width: 60% !important; float: right;">
If you have never thought about this topic before, you might be surprised at the things you can do with random numbers. For example, you can generate random points in the unit square to approximate π. (Hint: the area of the quarter circle is π/4.)

This is a terrible example because the approximation converges very slowly. You can learn more about different methods and how quickly they converge <a href="http://www.johngiovannis.com/content/calculating-pi" target="_blank">here</a>. But it is easy enough to implement:
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
In the following, we'll discuss more useful examples.

Las Vegas and Monte Carlo Algorithms
------------------------------------

First off, let's get a little formal. We'll be talking about randomized algorithms-- these are algorithms that have access to a random number generator (RNG). It isn't easy for a deterministic computer to generate random numbers. In fact it is impossible, so we must settle for <a href="http://en.wikipedia.org/wiki/Cryptographically_secure_pseudorandom_number_generator" target="_blank">pseudorandom</a>. But for the purposes of this blog post, we'll blur the lines and just assume we have access to an RNG.

A <a href="http://en.wikipedia.org/wiki/Monte_Carlo_algorithm" target="_blank">Monte Carlo algorithm</a> is essentially a randomized algorithm that is allowed to make mistakes, as long as they are not that common. It runs using a deterministic amount of resources (time and memory), and there is some small probability of error.

A <a href="http://en.wikipedia.org/wiki/Las_Vegas_algorithm" target="_blank">Las Vegas algorithm</a> is a randomized algorithm that is not allowed to make mistakes, but it can take up an unpredictable amount of resources. Since being an algorithm means that it terminates, this is a slightly abusive name. You can't say every Las Vegas algorithm is guaranteed to terminate, <a href="http://en.wikipedia.org/wiki/Almost_surely" target="_blank">even if the probability is 1</a>.

Any Las Vegas algorithm can be converted into a Monte Carlo algorithm simply by limiting the resources available and returning a random result if they run out. If you have a way of determining correctness of output, then a Monte Carlo algorithm can be converted into a Las Vegas one by running it multiple times and returning once you have a correct result.

Avoiding Things
---------------
<img src="{{ site.baseurl }}assets/images/quicksort.gif" style="width: 40% !important; float: right;">
<a href="http://en.wikipedia.org/wiki/Quicksort">Quicksort</a> is a <a href="http://cs.stackexchange.com/questions/3/why-is-quicksort-better-than-other-sorting-algorithms-in-practice" target="_blank">fast</a> sorting algorithm which is often claimed to outperform other sorts in practice. The key to this outperformance is randomness. 

Quicksort is a recursive algorithm. At each step, you pick a pivot element from the list. Then you move the smaller elements in front of the pivot and the larger elements behind it, recursing on each of those two sets. If you aren't careful about choosing pivots, you can get into trouble: imagine choosing the largest element at every step. Then you have to move things around once for every element. If the list starts out in a bad ordering, you could end up with an <i>O(n<sup>2</sup>)</i> runtime.

You can't guarantee that this will not happen without spending extra time elsewhere. However, you can make it really unlikely by either shuffling the list to start or by choosing random pivots. Note that doing both will not help any more than doing just one.
<div style="clear: both"></div>

<img src="{{ site.baseurl }}assets/images/energy-landscape-trajectory.gif" style="width: 45% !important; float: right;">
In optimization problems, you typically try to find parameters that maximize or minimize some quantity. For a very simple example, let's say your data is a set of observations (<i>x<sub>1</sub>, x<sub>2</sub>, y</i>) and you think the relationship is linear: <i>y = ax<sub>1</sub> + bx<sub>2</sub></i>. In this case, <i>a</i> and <i>b</i> are the parameters and you are trying to minimize the observed error <i>y - ax<sub>1</sub> - bx<sub>2</sub></i>.

In the illustration, think of the landscape as the value of the function you are trying to minimize. Some algorithms find solutions by choosing a starting position, examining the landscape around that position, and moving the position in the direction of steepest descent. So the idea of a ball rolling down a hill and finding the lowest point is not far from the truth.

The problem is that you can find local minima with this method, but due to larger features (a crater, say) you may never observe the global minimum. Repeating the process with different random start positions can give you a better chance of finding the global solution. You can even use observations to form an opinion of <a href="http://en.wikipedia.org/wiki/Topological_data_analysis" target="_blank">where to look</a> for fruitful initial positions.
<div style="clear: both"></div>

Hiding Things
-------------

<img src="{{ site.baseurl }}assets/images/rock-paper-scissors.svg.png" style="width: 40% !important; float: right;">
If you have ever played rock, paper, scissors or watched <a href="http://en.wikipedia.org/wiki/WarGames" target="_blank">WarGames</a>, you're aware that not every game has a deterministic winning strategy.

In rock, paper, scissors you can play with a fixed strategy, but it's not a good idea. You can repeatedly play paper, but your opponent will quickly catch on and start playing scissors. You could alternate between paper and scissors, but again you will be quickly faced with alternating scissors and rock. The more complicated your strategy, the longer it will take your opponent to figure out, but as long as it follows some fixed pattern, you will lose out in the long run.

However if you choose randomly every time, you can expect to break even in the long run, which is the best possible outcome probabilistically. You can think of this as using randomness to hide your strategy-- a technique often useful in poker.
<div style="clear: both"></div>

<img src="{{ site.baseurl }}assets/images/SHA-2.svg" style="width: 40% !important; float: right;">
The essence of randomness in cryptography is the same. Randomness makes it harder to guess things, such as secret keys. In order to build a strong system, according to <a href="http://en.wikipedia.org/wiki/Kerckhoffs's_principle" target="_blank">Kerckhoffs's principle</a>, you must assume that everything about the system except the key is public information. This allows the involved parties to expend their effort keeping only the keys secret, a much easier task than trying to contain knowledge of the whole system.

Whenever you are designing a cryptographic system, you need to be prepared against brute force attacks. This is when an attacker tries lots of keys very quickly, and can quickly discover weak passwords (such as "temporary", "guest", "password", and common dates like birthdays, anniversaries, etc.). Often the strength of a cryptographic system is measured by how long it would take a brute force attacker to break in. In these calculations, you might want to consider the resources (electricity, chip technology, time) available to an attacker. If you know that the richest organization on the planet would be guessing until the heat death of the universe before they found the key, then that would be a pretty secure system, at least for now (since algorithms, technology, and geopolitics can change this).

Avoiding detection under a brute force attack is <a href="http://splashdata.com/press/worstpasswords2013.htm" target="_blank">very difficult</a> if you use a weak password. For example, it would be easy to traverse an English dictionary and try out every word, together with a large set of common character substitutions and case mixings. However, if you draw a key randomly from a large sample space, it becomes much harder to guess. You don't even have to use a completely random string of bits, <a href="http://xkcd.com/936/" target="_blank">four random common words</a> can even do the job!
<div style="clear: both"></div>

Finding Things
--------------

Let's say we're given a number and we want to determine whether it's prime. There are a variety of tests which can give us one-way information about this problem. We'll focus on the <a href="http://en.wikipedia.org/wiki/Fermat_primality_test" target="_blank">Fermat test</a> which is based on Fermat's little theorem. This theorem states that if <i>p</i> is prime and <i>a</i> is any integer, then <i>a<sup>p</sup>-a</i> is divisible by <i>p</i>.

So one way to determine a number <i>n</i> is <i>not</i> prime is to generate lots of random numbers <i>a</i> such that <i>0 < a < n</i>. If at any point we find an <i>a</i> such that <i>a<sup>n</sup>-a</i> is not divisible by <i>n</i>, then we know that <i>n</i> is not prime. However, because of problems like the <a href="http://en.wikipedia.org/wiki/Carmichael_number" target="_blank">Charmichael numbers</a>, this test is not used in practice. If you're interested, take a look at some of the <a href="http://en.wikipedia.org/wiki/Primality_test#Probabilistic_tests" target="_blank">others</a>.

<a href="http://www.mapequation.org/apps/MapDemo.html" target="_blank">Here</a> is a great visualization of the idea behind a graph clustering algorithm based on information theory. To see it in action follow the link, click "Random Walker" at the top, and "Start/Stop" on the bottom. What you see is a random walker traversing the graph. As the algorithm tracks the random walker across the graph, you see certain areas where the walker stays for a bit before moving on.

The idea is to turn these areas into clusters, and use these clusters to simplify the graph. In order to measure the effectiveness of these clusters, we give them "area codes," which are shown on the right hand side. The more frequently a group is visited, the shorter its area code should be so that it is easier to dial in to that area. As the random walker traverses the graph, we obtain statistics on how often it crosses from one area to another, and we try to minimize the total amount of digits we need to dial to track the walker.

Think of the number of digits we have to dial as how much data is required to specify the location of the walker. What we want is to find the minimal representation so that we can convey the information with the least number of digits possible. In other words, we seek to maximize the information per digit. Finally, click "Optimize" at the top to see the optimal configuration.

Conclusion
----------

Randomness is powerful. Sometimes you can't control that power, so it can come back and bite you if you're not careful. Use program control and probability theory to stay safe. You get to choose how unlikely the problems are.

The following scene from <i>Rosencrantz and Guildenstern Are Dead</i> makes a very good point about the subtlety of probability. Because something improbable happens Guildenstern wrongly assumes that the law of probability has been suspended. The dramatic irony is that it has been, since Tom Stoppard has written it to be so!
<iframe width="420" height="315" src="//www.youtube.com/embed/NbInZ5oJ0bc?rel=0" frameborder="0" allowfullscreen></iframe>

