---
layout: post
title: "Lazy Database Constant"
author: Chao Ma
author_avatar: http://www.redbeacon.com/media/about/images/Chao.jpg
excerpt: "We can find the trace of constant variables in almost any programming languages.
This artible talks about how to initiate such variables from database.
We present a simple design and implementation solution in Django framework.
It is just a tip of iceberg of Redbeacon code base. But this kind of coding makes programming at Redbeacon enjoyable."
---

We deal with constants in everyday programming. Most constants are truly constant across product life cycle. For example, one day has 86400 seconds. On the other hand, some are used as parameters to tune business logics. For example,
{% highlight python %}
PROMOTION_CREDIT = 25 # in the unit of dollars
{% endhighlight %}
I think most programmers are familiar with this kind of "variable" constants. These variables preserve the same value in a specific build, such as macros in C/C++. This provides certain convenience for changing product behavior.


In web development, some values are saved in database and treated as "constants". I personally favor saving city, state and zip code in relational database because relational database natively supports the relationship between these variables. In addition, city may become the foreign key of some other tables. It is handy to put everything in a central host.

In Redbeacon, it is a common routine to test if a zip code is legal or not. In the past, we had a list of zip codes dumped to a constant file. 

Instead of doing something like:
{% highlight python %}
Zipcode.objects.filter(zipcode=zipcode_val).exists()
{% endhighlight %}
Simply:
{% highlight python %}
zipcode_val in valid_zipcode_values
{% endhighlight %}
This reduces database load, but the side effect is obvious, duplicate information. As Redbeacon expands to more cities, we have two copies of zip code lists to maintain. Any discrepancy between database and hard-coded zip codes likely results in run-time error.
One of the reasons to use hard-coded constants is to avoid database load. Considering this, proxy is a better solution. A proxy establishes database connection and fetch data only if necessary. Then, the proxy saves the constant data, so that a database connection is no longer needed. The proxy does not need to support all interface of set or map. For example in Python, Dict implements __setitem__ method. This method is irrelevant if the dictionary is constant. Taking everything together, Redbeacon implements lazy constant utilities. An illustrative design diagram and pseudocode are shown below:

<img src="{{ site.baseurl }}assets/images/lazy_const_cls_diagram.png">

LazyConstSet and LazyConstDict classes are abstract proxies that shrinks the interface of Python built-in set and dictionary data types. To declare a lazy zip code set:
{% highlight python %}
zipcode_set=ValidZipcodeSet()
{% endhighlight %}
As LazyConstSet supports iteration and "contains" interface, zipcode_set fetches zip codes from database when any of its interface is invoked:
{% highlight python %}
94401 in zipcode_set # hit database if private _cached_data is None
94405 in zipcode_set # use private _cached_data, not hitting database anymore
{% endhighlight %}
LazyConstSet supports iteration method so that internal data could be exported. For example, we can run such Django query:
{% highlight python %}
City.objects.filter(zipcode__in=zipcode_set). # no database hit once instantiated
{% endhighlight %}
Furthermore, LazyConstDict extends the interface by adding an indexing method. Regarding business logics, concrete classes inherit proper abstract classes and implement uncached_instantiate method. In this diagram, ValidZipcodeSet class is sketched as an example for legal zip code set.
Set and dictionary are candidates for constant collections. In Django, we often deal with "read-only"ORM (object relational model) objects. It may be economical to hit database only when object attributes are fetched. For this use case, Django implements a handy class, SimpleLazyObject. For example, given a user_id,
{% highlight python %}
lazy_user_obj = SimpleLazyObject(lambda: User.objects.get(pk=user_id))
{% endhighlight %}
Django hits database only when an attribute is fetched:
{% highlight python %}
print lazy_user_obj.email
{% endhighlight %}
Unfortunately, SimpleLazyObject does not support iteration and indexing methods. Thus, we present this blog and point out a potential complement to Django SimpleLazyObject.

