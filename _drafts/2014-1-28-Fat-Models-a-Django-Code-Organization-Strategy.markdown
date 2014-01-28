---
layout: post
title: "Fat Models - A Django Code Organization Strategy"
author: John Schulte
author_avatar: https://0.gravatar.com/avatar/5ae41638bae77621f46e2bc54a3f2aa7
excerpt: "Good code organization can help you build Django projects faster while avoiding cruft and brittle code.  This article will present a code organization strategy that we like to call Fat Models."
---

## A Warning:

Almost all Django code examples will lead you down a path of poor code organization. If your project becomes long-lived, the code organization learned from Django examples will create non-trivial obstacles. This article will present a rarely seen, alternative code organization strategy that can save you a lot of headaches down the road.

## The Backstory – Redbeacon Builds Very Fast

Product iteration at breakneck speed is part of the Redbeacon identity and history. The most intense era was a two-year period of insanely fast development – the year before our acquisition by the Home Depot and the year after. During that time, I knew an engineer who worked at a startup with a similar product scope, which iterated on their product at a similar lightening fast pace. That startup had twenty engineers; Redbeacon only had five. We were building very fast and with 4x efficiency.

Most Django projects go through a short period of development and then into maintenance. Not us. Redbeacon's Django project has been in very active development for more than four years. Imagine that for a minute: For four years, we've been bolting stuff on to our Django codebase like an nine-armed carpenter monkey who drank a liter of coffee made with Red Bull.

When you make as many changes to a codebase as rapidly as we have, your biggest enemies become cruft and brittle code. Fortunately, good code organization can help mitigate these problems and allow you iterate faster on your project.

## The MVCs of Django, A.K.A. MTV with a built-in C

Have you ever tried to explain the Django MTV pattern to a Ruby on Rails developer? A lot of people will say that the templates are the views and the views the controllers. This is not true. The controller is the request/response/url-routing framework, which Django does for you. While the views are written by you to collect data to be presented in the templates. The templates and views together make up the presentation layer.

There's a lot to like about Django's MTV pattern. It makes building simple-use-case applications easy. However, the MTV pattern leaves it unclear where processing and updating are supposed to live. Let's take a look a couple of potential homes for code that processes, updates, or that we just want to abstract out of the way to improve legibility.

## Candidate 1: The View

Almost all Django examples use views to hold the bulk of code. Most look something like the following:

{% highlight python linenos %}
def accept_quote(request, quote_id, template_name="accept-quote.html"):

    quote = Quote.objects.get(id=quote_id)
    form = AcceptQuoteForm()

    if request.METHOD == 'POST':
        form = AcceptQuoteForm(request.POST)
        if form.is_valid():

            quote.accepted = True
            quote.commission_paid = False

            # charge the comission
            provider_credit_card = CreditCard.objects.get(user=quote.provider)
            braintree_result = braintree.Transaction.sale({
                'customer_id': provider_credit_card.token,
                'amount': quote.commission_amount,
            })
            if braintree_result.is_success:
                quote.commission_paid = True
                transaction = Transaction(card=provider_credit_card,
                                          trans_id = result.transaction.id)
                transaction.save()
                quote.transaction = transaction
            elif result.transaction:
                # processing issue, we'll retry in a scheduled celery task
                logger.error(result.message)
            else:
                # processing issue, we'll retry in a scheduled celery task
                logger.error('; '.join(result.errors.deep_errors))

            quote.save()
            return redirect('accept-quote-success-page')

    data = {
        'quote': quote,
        'form': form,
    }
    return render(request, template_name, data)
{% endhighlight %}

Examples follow this pattern because it's easy at first. All the code is in one place. However, this approach scales poorly and quickly leads to illegible code. I have personally seen following this pattern result in 500 line view functions that would make even the most hardened engineer cry. Overstuffed views lead to duplicate code, cruft, and they are hard to unit test unless you unit test the entire view. Altogether this leads to code that's tough to debug and brittle.

## Candidate 2: The Form

Django forms are object-oriented, and since they validate and clean data, they might make a good candidate to process and update.

{% highlight python linenos %}
def accept_quote(request, quote_id, template_name="accept-quote.html"):

    quote = Quote.objects.get(id=quote_id)
    form = AcceptQuoteForm()

    if request.METHOD == 'POST':
        form = AcceptQuoteForm(request.POST)
        if form.is_valid():

            # encapsulation in forms
            form.accept_quote()
            success = form.charge_commission()
            return redirect('accept-quote-success-page')

    data = {
        'quote': quote,
        'form': form,
    }
    return render(request, template_name, data)
{% endhighlight %}

This is already much better. The problem is that we now have credit card charging code in a form for accepting a quote. This seems like the wrong place. What if we want to change credit cards in other places that have nothing to do with accepting quotes? I suppose we could create a credit card charging form mixin, but what if we want to charge from the Django shell or a Celery task. We shouldn't have to use a form instance in order to charge a user's credit card.

## Candidate 3: Class-Based Views

Like using forms, using class-based views will make the view code more readable, but there is a similar trade off. We can't access the charging logic from the shell or Celery task. We'd have to use complex inheritance to include it in additional views that are otherwise unrelated.

## Candidate 4: Util Functions

One simple approach is to make util helper functions to abstract code away from the view. This approach is tempting. It solves all the above problems, but it creates its own issues.

{% highlight python linenos %}
def accept_quote(request, quote_id, template_name="accept-quote.html"):

    quote = Quote.objects.get(id=quote_id)
    form = AcceptQuoteForm()

    if request.METHOD == 'POST':
        form = AcceptQuoteForm(request.POST)
        if form.is_valid():

            # encapsulation in a utility function
            accept_quote_and_charge(quote)
            return redirect('accept-quote-success-page')

    data = {
        'quote': quote,
        'form': form,
    }
    return render(request, template_name, data)
{% endhighlight %}

Looks good, right? The problem is there is no obvious location for these functions to live. When your project is a couple of years old and your engineering team expands from four to twenty, it becomes hard for an engineer to know what util functions exist. When discoverability of functionality is a problem, time gets wasted and the door is open for duplicate functionality. Sometimes we catch duplication in code reviews, but by then it's already wasted development effort.

## Solution: Fat Models and Fat Managers

Models and model managers make an excellent candidate for encapsulation of code that processes and updates, especially if it has a strong logical or functional connection to the model. It also makes the models into an API with clear usage.

{% highlight python linenos %}
def accept_quote(request, quote_id, template_name="accept-quote.html"):

    quote = Quote.objects.get(id=quote_id)
    form = AcceptQuoteForm()

    if request.METHOD == 'POST':
        form = AcceptQuoteForm(request.POST)
        if form.is_valid():

            # encapsulation in a model method
            quote.accept()
            return redirect('accept-quote-success-page')

    data = {
        'quote': quote,
        'form': form,
    }
    return render(request, template_name, data)
{% endhighlight %}

You can see that there is a right way to mark a quote instance as accepted. The credit card processing code is properly encapsulated. Best of all, all the logic is in a place that makes sense and is easy to find and reference.

## The Strategy

There is one caveat: If code deals with the request object, it should almost definitely be in the view. Outside of that, ask yourself where the code should live in the following in order:

1. Should it be a model method?
2. Should it be a model manager method?
3. Should it be a form method?
4. Should it be a method of a view class?

If the answer to those four is no, then it consider a util function.

## TL;DR
Using model methods makes Django apps better.
