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
            class:     "#{ pluginName.toLowerCase() }-holder"
            text:      '...'
            listClass: "#{ pluginName.toLowerCase() }-hidden-list"
        holderAnimation:
            fade:         true
            showEasing:   'swing'
            hideEasing:   'swing'
            showDuration: 400
            hideDuration: 400
            onBeforeShow: (obj) ->
            onShow:       (obj) ->
            onAfterShow:  (obj) ->
            onBeforeHide: (obj) ->
            onHide:       (obj) ->
            onAfterHide:  (obj) ->
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

            if typeof window.Modernizr is "undefined"
                o.error 'Modernizr is required.'

                return false

            # Extend options
            o.opts = $.extend {}, defaults, options, metadata

            # execute custom code before the plugin process the elements.
            o.opts.onBeforeLoad(_this) if $.isFunction(o.opts.onBeforeLoad)

            # Initialize
            o.el            = $ el
            o.cloneEl       = o.el.clone()            # Reference to the old untouched element
            o.browserWindow = $ window
            o.windowWidth   = o.browserWindow.width()
            o.unwrapWidth   =  o.getChildrenWidth()   # unwrapped width for the breadcrumbs

            o.opts.onLoad(_this) if $.isFunction(o.opts.onLoad)

            # plugin keys ::start
            o.pluginKey = o.generateRandomKey()

            # generate random key for resize event to prevent event namespace conflicts
            o.resizeKey = "resize.#{ pluginName }_#{ o.pluginKey }"
            # plugin keys ::end

            # normalize events ::start
            o.hoverIn  = if Modernizr.touch then 'touchstart' else 'mouseenter'
            o.hoverOut = if Modernizr.touch then 'touchend' else 'mouseleave'
            # normalize events ::end

            # set the widths of each elements ::start
            o.el
                .children('li')
                .each ->
                    current = $ this

                    # set the elements float left and display inline-block and store the width to the element
                    current
                        .css(
                             float: 'left',
                             display: 'inline-block'
                        )
                        .data "#{ pluginName.toLowerCase() }-width", current.outerWidth(true)
            # set the widths of each elements ::end

            # add the wrapper class to the element
            o.el.addClass o.opts.wrapperClass

            # create the dropdown wrapper
            o.dropdownWrapper = ($ "<div id=\"#{ o.pluginKey }\" class=\"#{ pluginName.toLowerCase() }-dropdown-wrapper\"><ul class=\"#{ pluginName.toLowerCase() }-hidden-list clearfix\" /></div>")

            # append the dropdown wrapper to the body tag
            o.dropdownWrapper
                .hide()
                .appendTo document.body

            o.resize = _.debounce(o.resize, o.opts.debounceTime) if o.opts.fixIEResize

            # bind the element to a custom event named compress
            o.el.on "compress.#{ pluginName }", (e) ->
                current = $ this
                items   = current.children 'li'
                holder  = items.filter ".#{ o.opts.holder.class }"

                if holder.length is 0
                    holder = ($ "<li class=\"#{ o.opts.holder.class }\"><a href=\"#\">#{ o.opts.holder.text }</a></li>").insertAfter items.first()

                    # set the holder's css to float left and display inline-block
                    holder.css
                        float: 'left',
                        display: 'inline-block'

                # initialize an array for storage of the hidden items
                hiddenItems = []

                # loop through the breadcrumb children starting from the element after the holder element until the element before the active element
                holder
                    .nextUntil('.active')
                    .each ->
                        crumb = $ this

                        if o.optimalCrumbHeight isnt o.el.height()
                            hiddenItems.push crumb.detach().get(0)

                            # delete the reference since it does not correctly point it anymore the element
                            crumb = null
                        else
                            return false

                if hiddenItems.length > 0
                    # trigger first the beforeCompress callback
                    o.opts.onBeforeCompress(_this) if $.isFunction(o.opts.onBeforeCompress)

                    hiddenItems  = $ hiddenItems
                    dropdownList = o.dropdownWrapper.children ".#{ pluginName.toLowerCase() }-hidden-list"

                    # trigger onCompress callback
                    o.opts.onCompress(_this) if $.isFunction(o.opts.onCompress)

                    # append the hiddenItems in the holder's child ul
                    dropdownList.append hiddenItems

                    # set the hidden list items to block
                    dropdownList
                        .children()
                        .css
                            float:   'none'
                            display: 'block'

                    # trigger the afterCompress callback
                    o.opts.onAfterCompress(_this) if $.isFunction(o.opts.onAfterCompress)

                # delete the reference since it does not correctly point it anymore to the hidden elements
                hiddenItems = null

            # bind the element to a custom event named decompress
            o.el.on "decompress.#{ pluginName }", (e) ->
                current      = $ this
                holder       = current.find ".#{ o.opts.holder.class }"
                dropdownList = o.dropdownWrapper.children ".#{ pluginName.toLowerCase() }-hidden-list"
                hiddenItems  = dropdownList.find 'li'

                if hiddenItems.length > 0
                    hiddenItems   = $ hiddenItems.get().reverse()
                    releaseItems  = []
                    childrenWidth = o.getChildrenWidth()

                    hiddenItems.each ->
                        crumb = $ this
                        width = crumb.data "#{ pluginName.toLowerCase() }-width"

                        if typeof width isnt "undefined" and (childrenWidth + width) <= current.width()
                            releaseItems.unshift(crumb.detach().get(0))

                            childrenWidth += width
                        else
                            return false

                    if releaseItems.length > 0
                        # trigger first the beforeDecompress callback
                        o.opts.onBeforeDecompress(_this) if $.isFunction(o.opts.onBeforeDecompress)

                        # trigger onDecompress callback
                        o.opts.onDecompress(_this) if $.isFunction(o.opts.onDecompress)

                        # append the released items after the holder
                        holder.after ($ releaseItems)

                        # query again the dom and store it again in a variable
                        hiddenItems = dropdownList.find 'li'

                        # remove the remaining hidden item if the parent width and greater than or equal to the unwrap width
                        holder.after hiddenItems.detach() if hiddenItems.length is 1 and o.el.width() >= o.unwrapWidth

                        # remove the holder if there is no more item left.
                        if hiddenItems.length <= 1 and o.el.width() >= o.unwrapWidth
                            holder.remove()

                            # delete the reference since the holder element have been remove already
                            holder = null

                        # set the css of the children
                        current
                            .children()
                            .css
                                float:   'left'
                                display: 'inline-block'

                        # trigger the afterDecompress callback
                        o.opts.onAfterDecompress(_this) if $.isFunction(o.opts.onAfterDecompress)

            # delegate the normalized event for hoverIn to the holder element
            o.el.on "#{ o.hoverIn }.#{ pluginName }", ".#{ pluginName.toLowerCase() }-holder", (e) ->
                current  = $ this

                o.opts.holderAnimation.onBeforeShow(_this) if $.isFunction(o.opts.holderAnimation.onBeforeShow)

                ps = o.el
                    .find(".#{ pluginName.toLowerCase() }-holder")
                    .offset()

                o.dropdownWrapper
                    .css(
                        top:  (o.el.offset().top + o.el.outerHeight())
                        left: ps.left
                    )
                    .stop(true, true)
                    .fadeIn
                        duration: o.opts.holderAnimation.showDuration
                        easing:   o.opts.holderAnimation.showEasing
                        complete: ->
                            o.opts.holderAnimation.onShow(_this) if $.isFunction(o.opts.holderAnimation.onShow)

                            o.opts.holderAnimation.onAfterShow(_this) if $.isFunction(o.opts.holderAnimation.onAfterShow)

            # delegate the normalized event for hoverOut to the holder element
            o.el.on "#{ o.hoverOut }.#{ pluginName }", ".#{ pluginName.toLowerCase() }-holder", (e) ->
                current = $ this

                o.dropdownTimer = window.setTimeout( ->
                    o.dropdownWrapper.trigger "#{ o.hoverOut }.#{ pluginName }"
                , 500)

            o.dropdownWrapper.on "#{ o.hoverIn }.#{ pluginName }", ->
                window.clearTimeout o.dropdownTimer

            o.dropdownWrapper.on "#{ o.hoverOut }.#{ pluginName }", (e) ->
                current = $ this

                o.opts.holderAnimation.onBeforeHide(_this) if $.isFunction(o.opts.holderAnimation.onBeforeHide)

                current
                    .stop(true, true)
                    .fadeOut
                        duration: o.opts.holderAnimation.hideDuration
                        easing:   o.opts.holderAnimation.hideEasing
                        complete: ->
                            o.opts.holderAnimation.onHide(_this) if $.isFunction(o.opts.holderAnimation.onHide)

                            o.opts.holderAnimation.onAfterHide(_this) if $.isFunction(o.opts.holderAnimation.onAfterHide)

            # bind resize event to the window
            o.browserWindow.on o.resizeKey, o.resize

            # execute custom code after the plugin has loaded
            o.opts.onAfterLoad(_this) if $.isFunction(o.opts.onAfterLoad)

            # trigger the resize event after the plugin has loaded
            o.browserWindow.trigger o.resizeKey

        o.resize = (e) ->
            current = $ this

            crumbHeights = o.el
                .children('li')
                .map( ->
                    return ($ this).outerHeight true
                )
                .get()

            o.optimalCrumbHeight = _.max crumbHeights

            if o.optimalCrumbHeight isnt o.el.height()
                o.el
                    .addClass(o.opts.wrappedClass)
                    .trigger "compress.#{ pluginName }"

            if o.windowWidth isnt o.browserWindow.width()
                if o.browserWindow.width() < o.windowWidth and o.optimalCrumbHeight isnt o.el.height()
                    o.el
                        .addClass(o.opts.wrappedClass)
                        .trigger "compress.#{ pluginName }"
                else
                    o.el
                        .removeClass(o.opts.wrappedClass)
                        .trigger "decompress.#{ pluginName }"

                o.windowWidth = o.browserWindow.width()

            return null

        o.getChildrenWidth = ->
            totalWidth = 0

            o.el
                .children()
                .each ->
                    totalWidth += ($ this).width()

            return totalWidth

        o.generateRandomKey = ->
            return "rb-#{ Math.random().toString(36).substring(7) }"

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