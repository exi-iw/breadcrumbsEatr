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
        compressAllAtOnce:      false
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
        o         = ($ el).data '_obj', {}
        _this     = this
        metadata  = ($ el).data "#{ pluginName.toLowerCase() }-options"

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

            # plugin keys ::start
            o.pluginKey = o.generateRandomKey()
            o.stateKey  = "#{ pluginName.toLowerCase() }-state"

            # generate random key for resize event to prevent event namespace conflicts
            o.resizeKey = "resize.#{ pluginName }_#{ o.pluginKey }"
            # plugin keys ::end

            # add the wrapper class to the element
            o.el.addClass o.opts.wrapperClass

            o.resize = _.debounce(o.resize, o.opts.debounceTime) if o.opts.fixIEResize

            o.el.data o.stateKey, 'decompressed'

            # bind the element to a custom event named compress
            o.el.on "compress.#{ pluginName }", (e) ->
                current = $ this
                items   = current.children 'li'
                holder  = items.filter ".#{ o.opts.holder.class }"

                # set the state to compressed
                current.data o.stateKey, 'compressed'

                # slice the items beginning to the second element up to the second to the last element
                if holder.length is 0
                    hiddenItems = items
                        .eq(1)
                        .detach()

                    holder = ($ "<li class=\"#{ o.opts.holder.class }\"><a href=\"#\">#{ o.opts.holder.text }</a><ul class=\"clearfix\" /></li>").insertAfter items.first()
                else
                    hiddenItems = items
                        .eq(2)
                        .detach()

                o.opts.onCompress(_this) if $.isFunction(o.opts.onCompress)

                holder
                    .children('ul')
                    .hide()
                    .append hiddenItems

                # delete the reference since it does not correctly point it anymore to the hidden elements
                hiddenItems = null

                o.opts.onAfterCompress(_this) if $.isFunction(o.opts.onAfterCompress)

            # bind the element to a custom event named decompress
            # o.el.on "decompress.#{ pluginName }", (e) ->
            #     current     = $ this
            #     holder      = current.find ".#{ o.opts.holder.class }"
            #     hiddenItems = holder.find 'ul > li'

            #     # set the state to decompressed
            #     current.data o.stateKey, 'decompressed'

            #     if holder.length > 0
            #         console.log 'remove some items'

            #     # hiddenItems = holder
            #     #     .find("ul li")
            #     #     .detach()

            #     # holder.remove()

            #     o.opts.onDecompress(_this) if $.isFunction(o.opts.onDecompress)

            #     # current
            #     #     .find('li')
            #     #     .filter(':first-child')
            #     #     .after hiddenItems

            #     # delete the reference since the holder element have been remove already
            #     holder = null

            #     o.opts.onAfterDecompress(_this) if $.isFunction(o.opts.onAfterDecompress)

            o.browserWindow.on o.resizeKey, o.resize

            # execute custom code after the plugin has loaded
            o.opts.onAfterLoad(_this) if $.isFunction(o.opts.onAfterLoad)

            # trigger the resize event after the plugin has loaded
            o.browserWindow.trigger o.resizeKey

        o.resize = (e) ->
            current      = $ this
            # optimalWidth = o.el.data "#{ pluginName.toLowerCase() }-optimalwidth"

            crumbHeights = o.el
                .children('li')
                .map( ->
                    return ($ this).outerHeight true
                )
                .get()

            optimalCrumbHeight = _.max crumbHeights

            if optimalCrumbHeight isnt o.el.height()
                o.compress()
            else
                console.log 'must be decompressed'

            # if typeof optimalWidth is "undefined"
            #     if optimalCrumbHeight isnt o.el.height()
            #         o.el.data "#{ pluginName.toLowerCase() }-optimalwidth", (current.width() + o.opts.allowance)

            #         o.compress()
            # else
            #     if current.width() >= optimalWidth
            #         o.decompress() if _this.isCompressed()
            #     else
            #         o.compress() unless _this.isCompressed()

            return null

        o.compress = ->
            o.opts.onBeforeCompress(_this) if $.isFunction(o.opts.onBeforeCompress)

            o.el
                .addClass(o.opts.wrappedClass)
                .trigger "compress.#{ pluginName }"

        o.decompress = ->
            o.opts.onBeforeDecompress(_this) if $.isFunction(o.opts.onBeforeDecompress)

            o.el
                .removeClass(o.opts.wrappedClass)
                .trigger "decompress.#{ pluginName }"

        o.generateRandomKey = ->
            Math
                .random()
                .toString(36)
                .substring 7

        _this.getState = ->
            state = o.el.data o.stateKey

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