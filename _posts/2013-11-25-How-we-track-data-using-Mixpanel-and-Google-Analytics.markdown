---
layout: post
title: "How we track data using Mixpanel and Google Analytics"
author: Vinay Jain
author_avatar: http://www.redbeacon.com/media/about/images/Vinay.jpg
excerpt: "This article is an introduction to how we track data at Redbeacon and specifically how we track certain data using Mixpanel and Google Analytics."
---
This article is an introduction to how we track data at Redbeacon and specifically how we track certain data using Mixpanel and Google Analytics.

We at Redbeacon are constantly trying out new features and improvements in our core product and measuring these changes with some data points to understand the impact on our customers. We track and analyze all sorts of data, such as user events, site usage, mobile usage, job-conversion funnels across various channels, system stats, backend service performance, and application performance. Our goals for managing all this data are:

- Cost and resource effectiveness
- Easy to analyze and ask questions
- Automated reporting and monitoring wherever possible


We believe Mixpanel and Google Analytics are very similar in functionality but are yet different in terms of features at which they excel.

**Mixpanel** is an *event-centric* platform where tracking is not automated and is based on events. This works really well for certain event-based analysis like below:

*How did the new variant of homepage perform compared to the old one in terms of job-request conversion?*
<img src="{{ site.baseurl }}assets/images/homepage_test.png")>


**Google Analytics** on the other hand is feature-rich and does a good job in tracking pageviews, site usage, and link clicks in an automated manner but the trade off is the complexity it adds, which loses the ease of use for certain parts of the product. We have used Google Analytics to perform some aggregated analysis like below:

*Count of unique page views on the homepage for the month of October?*
<img src="{{ site.baseurl }}assets/images/pageviews.png")>

Below is a simplistic comparison of the two tools in terms of features they provide and which tool worked better for us.

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
            <td>Manually fire events on page load for every page that is cumbersome and error-prone</td>
            <td>Automatically done via embedding the tracking code</td>
        </tr>
        <tr>
            <td>Funnel tracking</td>
            <td>Tracking is event-centric and easy to set up funnels</td>
            <td>Setting up funnels is complex based on custom user events</td>
        </tr>
        <tr>
            <td>Real-time event tracking</td>
            <td>Live view for real-time events that makes QA and engineering easy</td>
            <td>Event tracking not displayed in real time</td>
        </tr>
        <tr>
            <td>Querying for events</td>
            <td>Easy slicing and querying for events based on properties</td>
            <td>Event filtering done via customs reports that are complex to setup</td>
        </tr>
        <tr>
            <td>A/B testing</td>
            <td>Manually pass events with custom properties to track metrics for A/B variants</td>
            <td>A/B testing framework is automated but complex to use</td>
        </tr>
        <tr>
            <td>Link clicks tracking on a page</td>
            <td>Tough to do it in an automated way for changing pages</td>
            <td>Automated site wide in-page analytics based on URLs</td>
        </tr>
        <tr>
            <td>Cost</td>
            <td>Charged per data point, so must be careful about not wasting the quota</td>
            <td>Free up to 10M data points a month</td>
        </tr>
        <tr>
            <td>Support</td>
            <td>Quick support from an engineer in a short period of time</td>
            <td>Official documentation is the best source of help</td>
        </tr>
    </tbody>
</table>
