---
layout: post
title: "Don't Use Code Beyond Its Expiration Date"
author: Billy McCarthy
author_avatar: http://www.redbeacon.com/media/about/images/Billy.jpg
excerpt: "Just because you can fix it, doesn't mean you shouldn't rebuild it from scratch."
---
Sometimes code needs to be taken out back and shot.
Then it needs to be burned.
Then the ashes need to be buried at an undisclosed location.

I took over responsibility for our Selenium test runner.  We use fabric to simply common tasks, such as running our Selenium tests.  The test runner was written by an engineer who had left the company by the time I started looking at his code and my boss was breathing down my neck to just fix 1 thing.  The system that I found was a fabric command which called a custom python script, which called nosetest to actually run the tests.

Originally all of the tests were run using Sauce Labs' service.  It worked, but we had a limit of how many tests we could run at a time, which means every time we added a new test, the suite would take even longer to run.  It was pushing an hour just to give us a result.  The solution was to build a farm of Selenium servers that could run the tests for us.  We found that the farm was more fragile than Sauce Labs and sometimes would give use timeout errors.  The answer to this situation was to run the suite in our own farm, then retry any failing tests in Sauce.

This cut down on our run time, but our Sauce allocations were idle until the whole suite ran and I could parse the output to see which tests failed.  I was told to find a way to run the tests immediately after failure.  (This may be a good time to mention that I am the company's Sysadmin, so my way of thinking might be different from **real** engineers)  It turns out that both nosetest and fabric suppress output while things are running.  This makes for pretty reports, but makes finding out what's happening right now a bit of a pain.  Cue the Sysadmin and turn off all output suppression and use *tee* to print info both to the screen and to a temp file.  Now I could poll the output file, as well as give the user something to look at while things were running, and spawn a Sauce test as soon as the test failed in the farm.

Given that our site is used by a myriad of people with various different web browsers we had to run each test with several different browsers.  The initial code just re-ran the test against every browser, but that wasn't terribly efficient.  We were re-running test/browser combinations that had already passed because 1 of them failed.  So I figured out how to write a nosetest plugin that would output the browser name and version when the test ended.  Insert some parsing code and now we could run the exact test/browser combination that failed.

Everything was working.

It wasn't working particularly well, though.  Sometimes the CPU load on the test server would get quite high, approaching 100% utilization.  A few days of debugging later (maybe hours, but it felt like days) and I realized that I was polling the output file as fast as the server could read it, then polling it again and again and again.  Insert a sleep and things became much calmer.

The only problem was that the code was way beyond its expiration date.  Here's the loop that would check to see if the tests failed and run it in Sauce if it did.

{% highlight python %}
    status = subprocess.Popen(['bash', '-c', 'tail -f %s' % (outfile)])
    err = re.compile('^test_.*EXCEPTION$')
    fail = re.compile('^test_.*FAILURE$')
    repeat = set()
    failed = set()
    output = open(outfile)
    while True:
        polling = 0
        for p in procs:
            poll = p.poll()
            if poll is None:
                polling += 1
                # don't check for failures if only running in Sauce Labs
                if opts.sauce:
                    continue
                for line in output.readlines():
                    if err.match(line) or fail.match(line):
                        if line not in repeat:
                            repeat.add(line)
                            test_info = line.split()
                            test_name = test_info[0]
                            browser_code = get_code(test_info[1])
                            browsers = opts.browsers
                            opts.browsers = (browser_code,)
                            procs += run_tests(opts, test_name, sauce=True)
                            opts.browsers = browsers
                        else:
                            failed.add(line)
            else:
                procs.remove(p)
        if polling == 0:
            break
        time.sleep(15) # wait for tests to run, so CPU doesn't catch on fire
{% endhighlight %}

This was about the point, after 3 months of piling chewing gum on top of duct tape, that I finally convinced my boss that this setup was unmaintainable and should really be rewritten from scratch.  An actual engineer agreed to take over the mess that I had made and built some OO classes that did all of the work in a way that didn't induce vomiting in lesser souls.  It took him several weeks to get everything back to the full set of features I had created, but the result was much better and thus there was much rejoicing.
