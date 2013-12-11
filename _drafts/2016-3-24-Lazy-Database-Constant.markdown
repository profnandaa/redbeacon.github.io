---
layout: post
title: "Lazy Database Constant"
author: Chao Ma
author_avatar: http://www.redbeacon.com/media/about/images/Chao.jpg
excerpt: "We can find the trace of constant variables in almost any programming language. This article talks about how to initiate such variables from your database. We present a simple design and implementation solution in Django framework. It is just a tip of the iceberg of Redbeacon code base. We Redbeacon engineers never stop improving our coding skills!"
---

We deal with constants in everyday programming. Most constants are truly constant across product life cycles. For example, one day has 86,400 seconds. On the other hand, some are used as parameters to tune business logics. For example:
{% highlight python %}
PROMOTION_CREDIT = 25 # in the unit of dollars
{% endhighlight %}
I think most programmers are familiar with these kinds of "variable" constants. These variables preserve the same value in a specific build, such as macros in C/C++. This provides a certain convenience for changing product behavior.

In web development, some values are saved in the database and treated as "constants." I personally favor saving the city, state, and zip code in a relational database because a relational database natively supports the relationship between these variables. In addition, the city may become the foreign key of some other tables. It is handy to put everything in a central host.

At Redbeacon, it is a common routine to test if a zip code is legal or not. In the past, we had a list of zip codes dumped to a constant file.

Instead of doing something like:
{% highlight python %}
Zipcode.objects.filter(zipcode=zipcode_val).exists()
{% endhighlight %}
Simply:
{% highlight python %}
zipcode_val in valid_zipcode_values
{% endhighlight %}
This reduces database load, but the side effect is obvious: duplicate information. As Redbeacon expands to more cities, we have two copies of zip code lists to maintain. Any discrepancy between database and hard-coded zip codes likely results in a run-time error.
One of the reasons to use hard-coded constants is to avoid database load. Considering this, proxy is a better solution. A proxy establishes database connection and fetch data only if necessary. Then, the proxy saves the constant data, so that a database connection is no longer needed. The proxy does not need to support all interface of set or map. For example in Python, Dict implements SetItem method. This method is irrelevant if the dictionary is constant. Taking everything together, Redbeacon implements lazy constant utilities. An illustrative design diagram and pseudocode are shown below:

<img src="{{ site.baseurl }}assets/images/lazy_const_cls_diagram.png">

LazyConstSet and LazyConstDict classes are abstract proxies that shrinks the interface of Python built-in set and dictionary data types. To declare a lazy zip code set:
{% highlight python %}
zipcode_set=ValidZipcodeSet()
{% endhighlight %}
As LazyConstSet supports iteration and "contains" interface, zipcode_set fetches zip codes from the database when any of its interface is invoked:
{% highlight python %}
94401 in zipcode_set # hit database if private _cached_data is None
94405 in zipcode_set # use private _cached_data, not hitting database anymore
{% endhighlight %}
LazyConstSet supports iteration method so that internal data could be exported. For example, we can create a Django queryset:
{% highlight python %}
City.objects.filter(zipcode__in=zipcode_set)
{% endhighlight %}
Furthermore, LazyConstDict extends the interface by adding an indexing method. Regarding business logic, concrete classes inherit proper abstract classes and implement uncached_instantiate method. In this diagram, ValidZipcodeSet class is sketched as an example for legal zip code set.
Set and Dictionary are candidates for constant collections. In Django, we often deal with "read-only" ORM (object relational model) objects. It may be economical to hit the database only when object attributes are fetched. For this use case, Django implements a handy class, SimpleLazyObject. For example, given a user_id,
{% highlight python %}
lazy_user_obj = SimpleLazyObject(lambda: User.objects.get(pk=user_id))
{% endhighlight %}
Django hits database only when an attribute is fetched:
{% highlight python %}
print lazy_user_obj.email
{% endhighlight %}
Unfortunately, SimpleLazyObject does not support iteration and indexing methods. Thus, we present this blog and point out a potential complement to Django SimpleLazyObject.

