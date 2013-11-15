---
layout: post
title: "Hitchhiker's Guide to Writing Articles"
author: Renan Cakirerk
author_avatar: http://www.redbeacon.com/media/about/images/Renan.jpg
excerpt: "This article is for giving you a quick-start about writing and publishing your articles on jekyll using markdown and liquid highlighter. It will not be published on Github pages since it is in the _drafts directory, but it will always be visible on your DEV server."
---

This article will give you a quick-start to how to write and publish your articles on `jekyll` using `markdown` and `liquid highlighter`. It will not be published on Github since it is in the `_drafts` directory, but will always be visible on your DEV server.

I've written this article using markdown. Checkout the source code [here](https://raw.github.com/redbeacon/redbeacon.github.io/master/_drafts/2016-03-24-Hitchhiker's-Guide-to-Writing-Articles.markdown) if you're interested. My first blog post was a hybrid that contains both markdown and html. You can see the source [here](https://github.com/redbeacon/redbeacon.github.io/blob/master/_posts/2013-10-20-The-Title-Would-Be-Hello-World-If-We-Werent-Aiming-Higher.markdown).


9 Easy Steps for Creating and Publishing Your Article
-----------------------------------------------------

Here are the basic steps for creating your article:

1. Clone `git@github.com:redbeacon/redbeacon.github.io.git` in your working directory on your development server.
    - **Optional:** Create a separate branch before doing any changes.
2. Create a file under `_drafts` directory with the following file name format `YYYY-MM-DD-My-Awesome-Blog-Post.markdown` where the date is the day you are publishing.
3. Insert `Front Matter`. (see **Front Matter**)
4. Write an awesome post in `markdown` format. (see **Introduction to Markdown**) You can also use html tags with `bootstrap` classes. Or a mixture of markdown and html.
5. You can commit and push your changes anytime. Your article `will not` be published yet.
6. If you have any images put them under `assets/images` directory. (see **Adding Images**)
7. To see how your article looks like, type `./run.sh` under your `redbeacon.github.io` directory.
   Your blog will be accessible from `YOUR_REDBEACON_DEV_SERVER_URL/blog/` note that there is a `/` in the end.
8. When you are done writing and ready to publish, move your file under the `_posts` directory. Commit and push. Your article will be online in 5 minutes.
    - Note that if you give a `future date` to your article, it will be published automatically on that date.
9. **Share** your article on Twitter, Facebook, LinkedIn, Google+ and be proud of it!


Front Matter
------------

Every post **must** have a front matter. Front matter contains information about you and your article. It is written between `triple dashes` on the top of your article.

The front matter of this post is like this:

{% highlight html %}
---
layout: post
title: "An Example Post For You"
author: Renan Cakirerk
author_avatar: http://www.redbeacon.com/media/about/images/Renan.jpg
excerpt: "This is the text that will be displayed on the front page. A short description about the article or the first paragraph without images or code."
---
{% endhighlight %}

> **layout:** tells which template this post will use. We currently have one layout for our posts. Layouts can be found under the `_layouts` directory.
>
> **title:** is the title of this article and `should be same with your file name.`
>
> **author:** is your name. If you wrote this with someone else just write your names comma separated.
>
> **author avatar:** Put the link of your avatar here.
>
> **excerpt:** This is the text that will be displayed on the front page. A short description about the article or the first paragraph of your article without images or code.


Article Titles
--------------

The title of your article must be in `Title Case` except words like `for` `a` `the` `to` that are after the first word.
Remember that the `file name` and `title:` in the front matter should be same.

**Example**: Requiem for a Dream


Adding Images
-------------

Your images should be under `assets/images` directory. For displaying an image we use the syntax:

{% highlight html %}
{% raw %}
<img src="{{ site.baseurl }}assets/images/tardis.png">
{% endraw %}
{% endhighlight %}

The `markdown` equivalent is

{% highlight html %}
{% raw %}
![ ]({{ site.baseurl }}assets/images/tardis.png)
{% endraw %}
{% endhighlight %}

Note that we must **always** add `{% raw %}{{ site.baseurl }}{% endraw %}` to the beginning of the link.

---


Introduction to Markdown
------------------------

### Headers

We only use `H2`, `H3` and `H4` tags in our articles. But I'll give a complete list of how `h tags` are represented in markdown.

{% highlight html %}
# H1
## H2
### H3
#### H4
##### H5
###### H6
{% endhighlight %}

> Will output:
> # H1
> ## H2
> ### H3
> #### H4
> ##### H5
> ###### H6

Alternatively `H2`, can be represented as:

{% highlight html %}
This is an H2 title
-------------------
{% endhighlight %}

> Will output:
> This is an H2 title
> -------------------

Note again that we only use `H2` for titles and `H3` for sub titles and if you need one more level use `H4`.


### Emphasis

For bold, italic and strikout we use the following syntax:

{% highlight html %}
this is **bold**
this is *italic*
this is ~~striked out~~
{% endhighlight %}

> Will output:
>
> this is **bold**
> this is *italic*
> this is ~~striked out~~


### Lists

Lists can be bulleted or numbered. The indentation matters.

#### Numbered Lists

There is one important thing you should know about numbered lists:
Even if you give the wrong number order, they will be corrected on the front-end.

Lets create a numberesd list where the items are not ordered correctly:

{% highlight html %}
3. Item 1
    5. Sub-item 1
        6. Sub-sub-item 1
        4. Sub-sub-item 2
    2. Sub-item 2
    3. Sub-item 3
9. Item 2
{% endhighlight %}

> Will output the correct order:
>
> 3. Item 1
>     5. Sub-item 1
>         6. Sub-sub-item 1
>         4. Sub-sub-item 2
>     2. Sub-item 2
>     3. Sub-item 3
> 9. Item 2


#### Bullet Lists

{% highlight html %}
- Item 1
    - Sub-item 1
- Item 2
    - Sub-item 1
        - Sub-sub-item 1
- Item 3
- Item 4
- Item 5
{% endhighlight %}

> Will output:
>
> - Item 1
>     - Sub-item 1
> - Item 2
>     - Sub-item 1
>         - Sub-sub-item 1
> - Item 3
> - Item 4
> - Item 5


### Blockquotes
Blockquotes can be used when you want to grab attention on a specific phrase. In this article I'm showing the output in blockquotes.

They are written with a `>` in the beginning like:

{% highlight html %}
> Some intelligent quote by *someone* **clever**
>
> <small>Someone Clever</small>
{% endhighlight %}

> Will output:
>
> > Some intelligent quote by *someone* **clever**
> >
> > <small>Someone Clever</small>


### Links

{% highlight html %}
[I'm an inline-style link](https://www.redbeacon.com)

[I'm an inline-style link with title](https://www.redbeacon.com "Redbeacon Homepage")
{% endhighlight %}

> Will output:
>
> [I'm an inline-style link](https://www.redbeacon.com)
>
> [I'm an inline-style link with title `hold your mouse over to see the title`](https://www.redbeacon.com "Redbeacon Homepage")


### Images

{% highlight html %}
![](http://redbeacon.com/media/common/images/logo_redbeacon_outline_trans_20.png "Redbeacon Logo")
{% endhighlight %}

> Will output:
>
> ![](http://redbeacon.com/media/common/images/logo_redbeacon_outline_trans_20.png "Redbeacon Logo")


### Code and Syntax Highlighting

Your `highlight` tags will be parsed by the `Liquid Templating Engine` and colored by `pygments`. Pygments supports tons of languages.

iHere's an `HTML` example

    {% raw %}
    {% highlight html %}
        <strong>Your</strong> code <i>here</i>
    {% endhighlight %}
    {% endraw %}

> Will output:
> {% highlight html %}
<strong>Your</strong> code <i>here</i>
{% endhighlight %}

And here's a `Python` example:

    {% raw %}
    {% highlight python %}
        class Animal:
            def __init__(self):
                print "Omg I'm colored!"
    {% endhighlight %}
    {% endraw %}

> Will output:
> {% highlight python %}
class Animal:
    def __init__(self):
        print "OMG I'm colored!"
{% endhighlight %}

And finally a `Javascript` example. This time we'll show the `line numbers`:

    {% raw %}
    {% highlight javascript linenos %}
        $('.redbeacon').on('click', function() {
            console.log('Wait this doesn\'t make sense');
        });
    {% endhighlight %}
    {% endraw %}

> Will output:
> {% highlight javascript linenos %}
$('.redbeacon').on('click', function() {
    console.log('Wait this doesnt make sense');
});
{% endhighlight %}


### Gist

Use the gist tag to easily embed a GitHub Gist onto your site:

    {% raw %}
    {% gist 4183807 %}
    {% endraw %}

> Will output:
>
> {% gist 4183807 %}


You may also optionally `specify the filename` in the gist to display:

    {% raw %}
    {% gist 7367101 main.py %}
    {% endraw %}

> Will output:
>
> {% gist 7367101 main.js %}

The gist tag also works with `private gists`, which require the gist owner’s github username.
The private gist syntax also supports filenames.

    {% raw %}
    {% gist bit2pixel/9ba1a64a4f79d9eb812d %}
    {% endraw %}

> Will output:
>
> {% gist bit2pixel/9ba1a64a4f79d9eb812d %}


### Tables

For creating pretty tables, use bootstrap classes.
{% highlight html %}
<table class="table table-striped">
    <thead>
        <tr>
            <th>Column 1</th>
            <th>Column 2</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Row 1 Column 1</td>
            <td>Row 1 Column 2</td>
        </tr>
        <tr>
            <td>Row 2 Column 1</td>
            <td>Row 2 Column 2</td>
        </tr>
    </tbody>
</table>
{% endhighlight %}

> Will output:
>
> <table class="table table-striped">
    <thead>
        <tr>
            <th>Column 1</th>
            <th>Column 2</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Row 1 Column 1</td>
            <td>Row 1 Column 2</td>
        </tr>
        <tr>
            <td>Row 2 Column 1</td>
            <td>Row 2 Column 2</td>
        </tr>
    </tbody>
</table>


### Horizontal Line

{% highlight html %}
---
{% endhighlight %}

> Will output:
>
> ---

The rest depends on your imagination. Happy writing!