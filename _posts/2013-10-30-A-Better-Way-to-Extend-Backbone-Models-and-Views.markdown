---
layout: post
title: "A Better Way to Extend Backbone Models and Views"
author: Serkan Yersen
author_avatar: http://www.redbeacon.com/media/about/images/serkan.jpg
excerpt: Although Backbone has some level of object inheritance support, it was only meant to extend it's own Classes and nothing more. When you want to use an already existing Model or View as a base for your new objects, the default extend method usually falls short of doing it meaningful way.
---

Although Backbone has some level of object inheritance support, it was only meant to extend it's own Classes and nothing more. When you want to use an already existing Model or View as a base for your new objects, the default extend method usually falls short of doing it meaningful way.

For example, you have no way of using the methods of Parent class on your Child class. And if you want to extend an already existing Model's `defaults` or View's `events` you'll have to either call them via `prototype` and extend them or re-write them for your Child class again.

In order to solve these issues, I put together a quick new method for Views and Models. It automatically extends `defaults` and `events` attributes for you and defines a `_super` property which you can safely reference to your Parent class and use it's methods while overwriting them.

Here is the code:

{% highlight javascript %}
(function(Model){
    'use strict';
    // Additional extension layer for Models
    Model.fullExtend = function(protoProps, staticProps){
        // Call default extend method
        var extended = Model.extend.call(this, protoProps, staticProps);
        // Add a usable super method for better inheritance
        extended._super = this.prototype;
        // Apply new or different defaults on top of the original
        if(protoProps.defaults){
            for(var k in this.prototype.defaults){
                if(!extended.prototype.defaults[k]){
                    extended.prototype.defaults[k] = this.prototype.defaults[k];
                }
            }
        }
        return extended;
    };

})(Backbone.Model);

(function(View){
    'use strict';
    // Additional extension layer for Views
    View.fullExtend = function(protoProps, staticProps){
        // Call default extend method
        var extended = View.extend.call(this, protoProps, staticProps);
        // Add a usable super method for better inheritance
        extended._super = this.prototype;
        // Apply new or different events on top of the original
        if(protoProps.events){
            for(var k in this.prototype.events){
                if(!extended.prototype.events[k]){
                    extended.prototype.events[k] = this.prototype.events[k];
                }
            }
        }
        return extended;
    };

})(Backbone.View);
{% endhighlight %}

And here is an example of how to use it with Models, same applies for Views too


{% highlight javascript %}
 var Car = Backbone.Model.extend({
  defaults:{
    engine: 'gasoline',
    hp: 0,
    doors: 4,
    color: 'generic'
  },
  engine: function(){
    return 'Wroomm';
  }
});

// Ferrari will have all attributes from Car Model
// But will also have it's own modifications
var Ferrari = Car.fullExtend({
  defaults: {
    hp: 500,
    color: 'red',
    doors: 2
  },
  // Engine method can use the engine method on Car too
  engine: function(){
    var ret = this._super.engine();
    return ret + '!!!!';
  }
});
{% endhighlight %}

Hope it's useful for you.
