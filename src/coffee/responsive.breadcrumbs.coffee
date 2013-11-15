###
 * Responsive Breadcrumbs - Turns breadcrumbs into a responsive one
 * Copyright(c) Exequiel Ceasar Navarrete <exequiel.navarrete09@gmail.com>
 * Licensed under MIT
### 
(($, window, document, undefined_) ->
    "use strict"

    pluginName = 'responsiveBreadcrumbs'
    defaults =
        allowance:              10
        compressOnWidth:        null
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
        holder:
            class: "#{ pluginName.toLowerCase() }-holder"
            text:  '...'
        wrapperClass:           "#{ pluginName.toLowerCase() }-wrapper"
        wrappedClass:           "#{ pluginName.toLowerCase() }-wrapped"
        onBeforeCompress:       (obj) ->
        onCompress:             (obj) ->
        onAfterCompress:        (obj) ->
        onBeforeDecompress:     (obj) ->
        onDecompress:           (obj) ->
        onAfterDecompress:      (obj) ->
        onBeforeLoad:           (obj) ->
        onLoad:                 (obj) ->
        onAfterLoad:            (obj) ->
        onDestroy:              (obj) ->

    ResponsiveBreadcrumbs = (el, options) ->
        o        = ($ el).data '_obj', {}
        _this    = this
        metadata = ($ el).data "#{ pluginName.toLowerCase() }-options"
        stateKey = "#{ pluginName.toLowerCase() }-state"

        o.resize = (e) ->
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
                    o.opts.onBeforeCompress(_this) if $.isFunction(o.opts.onBeforeCompress)

                    o.el
                        .data("#{ pluginName.toLowerCase() }-optimalwidth", (current.width() + o.opts.allowance))
                        .addClass(o.opts.wrappedClass)
                        .trigger "compress.#{ pluginName }"
            else
                if current.width() >= optimalWidth
                    if _this.isCompressed()
                        o.opts.onBeforeDecompress(_this) if $.isFunction(o.opts.onBeforeDecompress)

                        o.el
                            .removeClass(o.opts.wrappedClass)
                            .trigger "decompress.#{ pluginName }"
                else
                    if not _this.isCompressed()
                        o.opts.onBeforeCompress(_this) if $.isFunction(o.opts.onBeforeCompress)

                        o.el
                            .addClass(o.opts.wrappedClass)
                            .trigger "compress.#{ pluginName }"

            return null

        o.debug = ->
            # Skip browsers w/o firebug or console
            if console and $.isFunction(console.log)
                return false if arguments.length < 1

                args = []

                for n of arguments
                    args.push arguments[n]
                    args.push " >> "

                args.push(o.el) if args.length is 1
                args.push "[#{ pluginName }]"

                console.log.apply console, args

        o.error = ->
            # Skip browsers w/o firebug or console
            if console and $.isFunction(console.log)
                return false if arguments.length < 1

                args = []

                for n of arguments
                    args.push arguments[n] + (" >> ")

                args.push(o.el) if args.length is 1
                args.push "[#{ pluginName }]"

                console.error.apply console, args

        # Initialize Properties and States Plugin
        o.init = ->
            # check if underscore.js is required.
            if typeof window._ is "undefined"
                o.error 'underscore.js is required.'

                return false

            # Extend options
            o.opts = $.extend {}, defaults, options, metadata

            # execute custom code before the plugin process the elements.
            o.opts.onBeforeLoad(_this) if $.isFunction(o.opts.onBeforeLoad)

            # Initialize
            o.el            = $ el
            o.cloneEl       = o.el.clone() # Reference to the old untouched element
            o.browserWindow = $ window

            o.opts.onLoad(_this) if $.isFunction(o.opts.onLoad)

            # add the wrapper class to the element
            o.el.addClass o.opts.wrapperClass

            if o.opts.fixIEResize
                _.each resize, (v, i) ->
                    resize[i] = _.debounce(v, o.opts.debounceTime) if $.isFunction(v)

            o.el.data stateKey, 'decompressed'

            o.el.on "compress.#{ pluginName }", (e) ->
                current = $ this

                items = current.children 'li'

                current.data stateKey, 'compressed'

                # slice the items beginning to the second element up to the second to the last element
                hiddenItems = items
                    .slice(1, (items.length - 1))
                    .detach()

                holder = ($ "<li class=\"#{ o.opts.holder.class }\"><a href=\"#\">#{ o.opts.holder.text }</a><ul class=\"clearfix\" /></li>").insertAfter items.first()

                o.opts.onCompress(_this) if $.isFunction(o.opts.onCompress)

                holder
                    .children('ul')
                    .hide()
                    .append hiddenItems

                # delete the reference since it does not correctly point it anymore to the hidden elements
                hiddenItems = null

                o.opts.onAfterCompress(_this) if $.isFunction(o.opts.onAfterCompress)

                console.log 'compress'

            o.el.on "decompress.#{ pluginName }", (e) ->
                current = $ this

                current.data stateKey, 'decompressed'

                holder = current.find ".#{ o.opts.holder.class }"

                hiddenItems = holder
                    .find("ul li")
                    .detach()

                holder.remove()

                o.opts.onDecompress(_this) if $.isFunction(o.opts.onDecompress)

                current
                    .find('li')
                    .filter(':first-child')
                    .after hiddenItems

                # delete the reference since the holder element have been remove already
                holder = null

                o.opts.onAfterDecompress(_this) if $.isFunction(o.opts.onAfterDecompress)

                console.log 'decompress'

            o.browserWindow.on "resize.#{ pluginName }", o.resize

            # execute custom code after the plugin has loaded
            o.opts.onAfterLoad(_this) if $.isFunction(o.opts.onAfterLoad)

            # trigger the resize event after the plugin has loaded
            o.browserWindow.trigger "resize.#{ pluginName }"

        _this.getState = ->
            state = o.el.data stateKey

            return if typeof state is "undefined" then 'decompressed' else state

        _this.isCompressed = ->
            return if _this.getState() is 'compressed' then true else false

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