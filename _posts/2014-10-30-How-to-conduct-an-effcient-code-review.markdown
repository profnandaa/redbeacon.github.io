---
layout: post
title: "How to conduct an efficient code review?"
author: Yi-Wei Wu
author_avatar: http://www.redbeacon.com/media/about/images/Yi-Wei.jpg
excerpt: "Good code view process can help you build a better team that moves fast and delivers stable product. "
---

To work efficiently as a team, code review is a critical component of our development process in Redbeacon. First, it helps us catch the mistakes overlooked in the early process. It's better to have a second pair of eyes to review the code that's going into master. Second, it's a tool that helps us learn a different or potentially better way of writing code. Third, it provides us a channel to work more closely and communicate more often.

Since Redbeacon is on Github, we use pull requests to review the code before merging the branch to master. After using it for a few months, we create a flow that works well, and we would like to share it with you.

# Pull request
We use a pull request to conduct pre-merge code review, which means no code or pull request is merged to master without getting a review in our development process. Also, it can be used to open a discussion and show your teammates an example of the code.

When working on a task, it's better to think about how you break it down and create multiple small pull requests rather than one huge pull request. Putting the bug fixes and new features in a single pull request is definitely a bad idea. Sometimes it's just an instinct to pick up the bug when you're working on a feature. However, there might be some comments from the reviewers that you need to fix for the feature and the bug fix looks good. Because both of them are in the same pull request, the fix can't be merged to master until all the comments are fixed!

Now let's see what the workflow is and what the requirements of a pull request are:

## Workflow
1. Create a pull request from your feature branch
2. Make sure your pull request meets the [requirements](#requirements)
3. Communicate with reviewers and revise your code when needed
4. Repeat 3 until the pull request is merged or closed

<h2 id="requirements">Requirements</h2>
### Summary
It's very important that the reviewer can easily understand what this pull request is about and why it's implemented in this way. All the information should be listed in either Asana (from a product viewpoint) or in pull request (from a technical viewpoint).

* **A link of Asana task -** The reviewers need to know the intent of the pull request and verify if the fix/implementation meets the requirements in the task.
* **Suggested reviewers -** There should be at least one reviewer mentioned in the summary.
* **A list of details (optional) -** Include this if the Asana task doesn't cover the details that is included in the pull request. For example, the new method that has been introduced and the old method that has been deprecated.
* **Screenshots or gifs (optional) -** It would be great to see the visual differences on the pull request before reading the code.
* **Some comments on the code (optional) -** It's better to leave comments on the lines of the code that reviewers should pay attention to or explain to the reviewer why you implemented it in this way. For example, there are some conditions you didn't check in the pull request because it's implemented in another pull request.

### Changed code

No one wants to waste time on reviewing the broken build or an outdated branch, so it's better to continuously make sure that the following minimum requirements are met:

* **Can be merged to master -** Please update your feature branch with current master. The code won't be reviewed unless the branch can be merged to master.
* **Compilable -** The reviewer should be able to compile and run the build.
* **Tested -** The code should be tested with comprehensive test cases. If you're not sure about the test cases or feature sets, please see Asana, or ask your PM or your teammates for more information.
* **Compatibility -** The app should be able to run and not look funny on different OS versions.
* **Cleaned-** If there is a change in resource, like new png files, it's better to clean the project and delete the app to make sure the new resource is in the bundle.

# Code review
* [What do you do before you start reviewing the code?](#what-to-do-before-you-start-reviewing-the-code)
* [What do you do while you review the code?](#what-to-do-while-you-review-the-code)
* [What you should pay attention to?](#what-you-should-pay-attention-to)
* [What do you do after you review the code?](#what-to-do-after-you-review-the-code)

<h2 id="what-to-do-before-you-start-reviewing-the-code">What do you do before you start reviewing the code?</h2>

### Ensure the pull request is valid
An invalid pull request is the one that doesn't satisfy the requirements of a pull request. You can remind the creator that the pull request can't be reviewed because a certain requirement is missing. However, it's definitely the creator's responsibility to make sure the pull request is worth the reviewer spending time on it.

<h2 id="what-to-do-while-you-review-the-code">What do you do while you review the code?</h2>

### Ask questions
Don't be shy to ask questions. The team is here to help. If you're not clear about the task or not sure about the implementation, please feel free to ask questions. It's not a good idea to ignore the problem while you're doing the code review.
### Provide feedback with an open mind
Leave a comment on the line of code that needs attention. Most of the rules in the guidelines should be enforced and addressed during code review. However, there is not only one solution to the problem. We can discuss it on the pull request rather than forcing people to accept your idea. A different perspective is always appreciated.
### Give your teammate a thumb-up
Don't forget to praise your teammate when he/she does a good job in the pull request. We can always learn something from other people, especially, when we have a team of smart people.

<h2 id="what-you-should-pay-attention-to">What you should pay attention to?</h2>

In general, the pull request is going to be merged to master after a few runs of code reviews. We have to ensure that the code is good enough to go to production. The whole team takes the responsibility of getting rid of smelly code and spreading good practice. Here are a few things that we should take into consideration when writing and reviewing the code:

### Style and convention
It will be easier for reviewers to read and for developers to maintain or change the code in the future if we have consistent style and convention in our code base.

Please see [Redbeacon iOS coding style](https://github.com/redbeacon/ios-coding-style) for the guidelines that we follow in our team.

### Correctness
Reviewers should make sure that the implementation is correct. Ask yourself:
* Does it actually solve the problem?
* Is it a hack? Is there a better way to do it?
* Should it be implemented on the client or on the API side? We should rely on the API to do most of the business logic and avoid doing it on the client.

### Maintainability/Scalability
* The code should be easy to read. Comments are welcome.
* There should not be multiple methods/classes created to perform similar tasks. We should write the code that is reusable.
* The method or class should only perform the task that's named. For example, the `layoutSubviews` method should only lay out the subviews and not set the text of the labels.
* MVC pattern should be applied. There should be no business logic in the view or view controller.
* Please avoid using Boolean if we can use a data source to reach the same goal. For example, it's better to use the status in NSOperation instead of adding Boolean to the view controller to know whether or not the operation is still executing.

### Performance
* Choose the best data structure to fit your need.
* Avoid performing unnecessary selectors.
* Avoid making redundant API calls.
* Reuse expensive objects.
* and more...

### Error handling
Because we should rely on the API to do a lot of jobs for us, API error handling plays an important role in our app. We can't assume the API always works and the API is mutable. The app should be flexible enough to adopt the change without crashing. Of course, the same rules apply to validation errors, file system errors, and so on.

### Multi-threading
UIKit should be used on the main thread. The expensive/time-consuming operation should be done in the background thread.

### Test coverage
We should aim for 100% test coverage so that we are confident in changing the code without breaking another part of the app. It will increase productivity in the long run by avoiding manual testing.

<h2 id="what-to-do-after-you-review-the-code">What do you do after you review the code?</h2>

* **Communicate with the creator -** If there are issues that need to be addressed by the creator, please send the pull request back to him or her with  feedback.
* **Review it again -** Sometimes, reviewing the code once is not enough. We might have to go back and forth until we are  all satisfied with the pull request.
* **Leave "LGTM" -** This is to let other reviewers or the assignee know that you've reviewed the code and you approve the pull request.
* **Merge -** If you're the assignee of the pull request, you're responsible to merge the pull request to master once all the comments have been addressed and it looks good to you. At this point, the code is going into master, and we are all in the same boat!
* **Move Asana task to build section -** Once the pull request for the Asana task is merged to master, move the Asana task to the build section. It will help the QA team to close the task or comment on it when they test the build.
* **Update change log -** Copy the title and the link of the completed Asana task to our change log, which is visible to the team and the PM.
* **Inform the team -** Most of people don't pay attention to Github emails (though we should). We are using Slack for now to inform the team that the pull request has been merged to master.
