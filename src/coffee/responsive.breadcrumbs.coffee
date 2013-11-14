(($, window, document, undefined_) ->
    "use strict"

    pluginName = 'responsiveBreadcrumbs'
    defaults =
        allowance:              10
        compressed:
            wrapperClass: "#{ pluginName.toLowerCase() }-compressed-wrapper"
            beforeOpen:   (obj) ->
            open:         (obj) ->
            afterOpen:    (obj) ->
            beforeClose:  (obj) ->
            close:        (obj) ->
            afterClose:   (obj) ->
        debounceTime:           200
        enhanceAnimation:       true
        exposeItems:            false
        fixIEResize:            false
        wrapperClass:           "#{ pluginName.toLowerCase() }-wrapper"
        wrappedClass:           "#{ pluginName.toLowerCase() }-wrapped"
        onBeforeCompress:       (obj) ->
        onCompress:             (obj) ->
        onAfterCompress:        (obj) ->
        onBeforeShowCompressed: (obj) ->
        onShowCompressed:       (obj) ->
        onAfterShowCompressed:  (obj) ->
        onBeforeLoad:           (obj) ->
        onLoad:                 (obj) ->
        onAfterLoad:            (obj) ->
        onDestroy:              (obj) ->

    ResponsiveBreadcrumbs = (el, options) ->
        o        = ($ el).data '_obj', {}
        _this    = this
        metadata = ($ el).data "#{ pluginName.toLowerCase() }-options"

        resize =
            main: (e) ->
                current      = $ this
                optimalWidth = o.el.data "#{ pluginName.toLowerCase() }-optimalwidth"

                crumbHeights = o.el
                    .children('li')
                    .map( ->
                        return ($ this).outerHeight true
                    )
                    .get()

                optimalCrumbHeight = _.max crumbHeights

                if typeof optimalWidth is "undefined"
                    if optimalCrumbHeight isnt o.el.height()
                        o.el
                            .data("#{ pluginName.toLowerCase() }-optimalwidth", (current.width() + o.opts.allowance))
                            .addClass o.opts.wrappedClass
                else
                    if current.width() >= optimalWidth
                        console.log 'remove'
                        o.el.removeClass o.opts.wrappedClass
                    else
                        console.log 'add'
                        o.el.addClass o.opts.wrappedClass

                return null

        o.debug = ->
            # Skip browsers w/o firebug or console
            if console and $.isFunction(console.log)
                return false if arguments_.length < 1

                args = []

                for n of arguments_
                    args.push arguments_[n]
                    args.push " >> "

                args.push(o.el) if args.length is 1
                args.push "[#{ pluginName }]"

                console.log.apply console, args

        o.error = ->
            # Skip browsers w/o firebug or console
            if console and $.isFunction(console.log)
                return false if arguments_.length < 1

                args = []

                for n of arguments_
                    args.push arguments_[n] + (" >> ")

                args.push(o.el) if args.length is 1
                args.push "[#{ pluginName }]"

                console.error.apply console, args

        # Initialize Properties and States Plugin
        o.init = ->

            # check if underscore.js is required.
            if not window._
                o.error 'underscore.js is required.'

                return false

            # Extend options
            o.opts = $.extend {}, defaults, options, metadata

            # execute custom code before the plugin process the elements.
            o.opts.onBeforeLoad(_this) if $.isFunction(o.opts.onBeforeLoad)

            # Initialize
            o.el = $(el)
            o.cloneEl = o.el.clone() # Reference to the old untouched element

            o.opts.onLoad(_this) if $.isFunction(o.opts.onLoad)

            # add the wrapper class to the element
            o.el.addClass o.opts.wrapperClass

            if o.opts.fixIEResize
                _.each resize, (v, i) ->
                    resize[i] = _.debounce(v, o.opts.debounceTime) if $.isFunction(v)

            ($ window)
                .on("resize.#{ pluginName }", resize.main)
                .trigger "resize.#{ pluginName }"

            # execute custom code after the plugin has loaded
            o.opts.onAfterLoad(_this) if $.isFunction(o.opts.onAfterLoad)

        _this.destroy = ->
            o.opts.onDestroy(_this) if $.isFunction(o.opts.onDestroy)

            # Stop any animation
            o.el.stop true, true

            # Remove Events attached to the elements
            o.el.off ".#{ pluginName }"

            # remove any events attached to window object
            ($ window).off ".#{ pluginName }"

            # Remove Plugin Data
            o.el.removeData pluginName


        # Remove Element Classes
        _this.setOption = (key, value) ->
            if key of o.opts then o.opts[key] = value else o.error "Option \"#{ key }\" is not a known option."

            _this

        o.init()

        return null

    $.fn[pluginName] = (options) ->
        @each ->
            $.data this, pluginName, new ResponsiveBreadcrumbs(this, options) unless $.data(this, pluginName)

) jQuery, window, document