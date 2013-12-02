breadcrumbsEatr
===============

breadcrumbsEatr.js is a jQuery plugin that allows you to transform non-responsive breadcrumbs into a responsive 
one. Useful when developing a website that is responsive and at the same time has breadcrumbs.

Basic Usage
-----------

*Note:* you must resize the window in order to see the plugin in action.

`$('#basic-usage').breadcrumbsEatr();`


*Note:*
-------
To build the plugin you must have NodeJS, NPM, Grunt and Bower. Grunt and Bower depends on NodeJS and NPM so you must install these first. Grunt for compiling the plugin from coffee and less to js and css. Bower for installing the project's dependencies.

From the Terminal/Command Line run the command: <br />
SomeUser@Computer $ `npm install` <br />

After running the `npm install` command run this: <br />
SomeUser@Computer $ `bower install`

Finally, execute this command: <br />
SomeUser@Computer $ `grunt`


Dependencies
------------

1. [jQuery](http://code.jquery.com/jquery-1.8.3.min.js)
2. [underscore](http://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.5.2/underscore-min.js)
3. [Modernizr](http://cdnjs.cloudflare.com/ajax/libs/modernizr/2.6.2/modernizr.js)