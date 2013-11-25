---
layout: post
title: "How we track data using Mixpanel and Google analytics"
author: Vinay Jain
author_avatar: http://www.redbeacon.com/media/about/images/Vinay.jpg
excerpt: "This article is an introduction to how we track data at Redbeacon and specifically how we track data using Mixpanel and Google analytics"
---
This article is an introduction to how we track data at Redbeacon and specifically how we track certain data using *Mixpanel* and *Google analytics*

We at Redbeacon are constantly trying out new features and improvements in our core product and measuring these changes with some data points to understand the impact of them on our customers. We track and analyze all sorts of data like user events, site usage, mobile usage, job conversion funnel across various channels, system stats, backend service performance and application performance. Our goals for managing all this data are
- Cost and resource effectiveness
- Easy to analyze and ask questions
- Automated reporting and monitoring wherever possible

We also think there is no silver bullet for analytics and answering various data related questions and hence we use some tools effectively in conjunction with each other to solve specific needs.

For measuring our core metrics like site usage and conversion funnel we use *Mixpanel* and *Google analytics*. The two products are very similar yet very different in our experience with using them. Below is a simplistic comparison of the two tools in terms of features they provide and which tool worked better for us.

<table class="table table-striped">
    <thead>
        <tr>
            <th></th>
            <th><img src="{{ site.baseurl }}assets/images/mixpanel-logo.png")></th>
            <th><img src="{{ site.baseurl }}assets/images/google-logo.png")></th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Page views across site</td>
            <td>Manually fire events on page load for every page</td>
            <td>Automatically done via embedding the tracking code</td>
        </tr>
        <tr>
            <td>Funnel tracking</td>
            <td>Tracking is event centric and easy to setup funnels</td>
            <td>Setting up funnels is complex based on custom user events</td>
        </tr>
        <tr>
            <td>Realtime event tracking</td>
            <td>Live view for realtime events</td>
            <td>Event tracking not displayed in realtime</td>
        </tr>
        <tr>
            <td>Querying for events</td>
            <td>Easy slicing and querying for events based on properties</td>
            <td>Event filtering done via customs reports which are complex to setup</td>
        </tr>
        <tr>
            <td>A/B testing</td>
            <td>Manually pass events with custom properties to track metrics for A/B variants</td>
            <td>A/B testing framework is automated but complex to use</td>
        </tr>
        <tr>
            <td>Click tracking on a page</td>
            <td>Tough to do it in an automated way for changing pages</td>
            <td>Automated site wide in page click tracking</td>
        </tr>
        <tr>
            <td>Cost</td>
            <td>Charged per data point so need to be careful about not wasting the quota</td>
            <td>Free upto 10M data points a month</td>
        </tr>
    </tbody>
</table>

Example usage of Mixpanel and Google Analytics
----------------------------------------------

**Question** How did the new variant of homepage perform compared to the old one in terms of job request conversion ?
**Answer** We simply passed events to *Mixpanel* with a custom property indicating the landing page as old vs new and build a simple funnel to track conversion to the job request page.
<img src="{{ site.baseurl }}assets/images/homepage_test.png")>

**Question** Count of unique page views on the homepage for the month of October ?
**Answer** *Google Analytics* gives this answer with no development effort and a few clicks.
<img src="{{ site.baseurl }}assets/images/pageviews.png")>

Conclusion
----------
This is our first blog post about how we track data and there will be follow up posts about how we track other data in our system.
