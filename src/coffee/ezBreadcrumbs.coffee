###
 * EzBreadcrumbs - jQuery plugin that transforms a breadcrumbs to a responsive one. Useful when making responsive websites.
 * Copyright(c) Exequiel Ceasar Navarrete <exequiel.navarrete09@gmail.com>
 * Licensed under MIT
 * Version 1.0.2
### 
(($, window, document, undefined_) ->
    "use strict"

    pluginName = 'ezBreadcrumbs'
    defaults =
        activeClass:            'active'
        debounceResize:
            enabled: false
            time:    200
        dropdownWrapperClass:   "#{ pluginName.toLowerCase() }-dropdown-wrapper"
        enhanceAnimation:       true
        exposeItems:            false
        holder:
            class:      "#{ pluginName.toLowerCase() }-holder"
            hoverClass: "#{ pluginName.toLowerCase() }-holder-hovered"
            listClass:  "#{ pluginName.toLowerCase() }-hidden-list"
            text:       '...'
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

    EzBreadcrumbs = (el, options) ->
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
            o.unwrapWidth   = o.getChildrenWidth()   # unwrapped width for the breadcrumbs
            o.documentBody  = $ document.body

            o.opts.onLoad(_this) if $.isFunction(o.opts.onLoad)

            # plugin keys ::start
            o.pluginKey = o.generateRandomKey()

            # generate random key for resize event to prevent event namespace conflicts
            o.resizeKey = "resize.#{ pluginName }_#{ o.pluginKey }"
            # plugin keys ::end

            # normalize events ::start
            o.hoverIn  = if Modernizr.touch then 'touchstart' else 'mouseenter'
            # normalize events ::end

            # set the widths of each elements ::start
            o.el
                .children('li')
                .each ->
                    current = $ this

                    # store the width to the element
                    current.data "#{ pluginName.toLowerCase() }-width", current.outerWidth(true)
            # set the widths of each elements ::end

            # add the wrapper class to the element
            o.el.addClass o.opts.wrapperClass

            # create the dropdown wrapper
            o.dropdownWrapper = ($ "<div id=\"#{ o.pluginKey }\" class=\"#{ o.opts.dropdownWrapperClass }\"><ul class=\"#{ o.opts.holder.listClass } clearfix\" /></div>")

            # append the dropdown wrapper to the body tag
            o.dropdownWrapper
                .hide()
                .appendTo o.documentBody

            # debounce the resize function if o.opts.debounceResize.enabled is set to true
            o.resize = _.debounce(o.resize, o.opts.debounceResize.time) if o.opts.debounceResize.enabled

            # bind the element to a custom event named compress
            o.el.on "compress.#{ pluginName }", (e) ->
                current = $ this
                items   = current.children 'li'
                holder  = items.filter ".#{ o.opts.holder.class }"

                if holder.length is 0
                    holder = ($ "<li class=\"#{ o.opts.holder.class }\"><a href=\"#\">#{ o.opts.holder.text }</a></li>").insertAfter items.first()

                # initialize an array for storage of the hidden items
                hiddenItems = []

                # loop through the breadcrumb children starting from the element after the holder element until the element before the active element
                holder
                    .nextUntil(o.opts.activeClass)
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
                    dropdownList = o.dropdownWrapper.children ".#{ o.opts.holder.listClass }"

                    # trigger onCompress callback
                    o.opts.onCompress(_this) if $.isFunction(o.opts.onCompress)

                    # append the hiddenItems in the holder's child ul
                    dropdownList.append hiddenItems

                    # add wrapped class to the element if it does not exist
                    current.addClass(o.opts.wrappedClass) unless current.hasClass(o.opts.wrappedClass)

                    # trigger the afterCompress callback
                    o.opts.onAfterCompress(_this) if $.isFunction(o.opts.onAfterCompress)

                # delete the reference since it does not correctly point it anymore to the hidden elements
                hiddenItems = null

            # bind the element to a custom event named decompress
            o.el.on "decompress.#{ pluginName }", (e) ->
                current      = $ this
                holder       = current.find ".#{ o.opts.holder.class }"
                dropdownList = o.dropdownWrapper.children ".#{ o.opts.holder.listClass }"
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

                            # remove wrapped class to the element if it exists
                            current.removeClass(o.opts.wrappedClass) if current.hasClass(o.opts.wrappedClass)

                        # trigger the afterDecompress callback
                        o.opts.onAfterDecompress(_this) if $.isFunction(o.opts.onAfterDecompress)

            # delegate the normalized event for hoverIn to the holder element
            o.el.on "#{ o.hoverIn }.#{ pluginName }", ".#{ o.opts.holder.class }", (e) ->
                o.opts.holderAnimation.onBeforeShow(_this) if $.isFunction(o.opts.holderAnimation.onBeforeShow)

                # add the hover class to the holder element
                ($ this).addClass o.opts.holder.hoverClass

                o.dropdownWrapper
                    .stop(true, true)
                    .fadeIn
                        duration: o.opts.holderAnimation.showDuration
                        easing:   o.opts.holderAnimation.showEasing
                        complete: ->
                            o.opts.holderAnimation.onShow(_this) if $.isFunction(o.opts.holderAnimation.onShow)

                            o.opts.holderAnimation.onAfterShow(_this) if $.isFunction(o.opts.holderAnimation.onAfterShow)

                e.preventDefault()

            # bind custom event named close to close or hide the dropdown
            o.dropdownWrapper.on "hide.#{ pluginName }", (e) ->
                current = $ this

                o.opts.holderAnimation.onBeforeHide(_this) if $.isFunction(o.opts.holderAnimation.onBeforeHide)

                current
                    .stop(true, true)
                    .fadeOut
                        duration: o.opts.holderAnimation.hideDuration
                        easing:   o.opts.holderAnimation.hideEasing
                        complete: ->
                            o.opts.holderAnimation.onHide(_this) if $.isFunction(o.opts.holderAnimation.onHide)

                            # remove the hover class to the holder element
                            o.el
                                .children(".#{ o.opts.holder.class }")
                                .removeClass o.opts.holder.hoverClass

                            o.opts.holderAnimation.onAfterHide(_this) if $.isFunction(o.opts.holderAnimation.onAfterHide)

            # delegate events for non-touch devices
            unless Modernizr.touch
                # delegate the click event for preventing default behavior
                o.el.on "click.#{ pluginName }", ".#{ o.opts.holder.class }", (e) ->
                    e.preventDefault()

                # delegate the mouseleave event for hoverOut to the holder element
                o.el.on "mouseleave.#{ pluginName }", ".#{ o.opts.holder.class }", ->
                    o.dropdownTimer = window.setTimeout( ->
                        o.dropdownWrapper.trigger "mouseleave.#{ pluginName }"
                    , 500)

                # bind the mouseenter event for hoverIn to the dropdownWrapper
                o.dropdownWrapper.on "mouseenter.#{ pluginName }", ->
                    window.clearTimeout o.dropdownTimer

                # bind the mouseleave event for hoverOut to the dropdownWrapper
                o.dropdownWrapper.on "mouseleave.#{ pluginName }", ->
                    ($ this).trigger "hide.#{ pluginName }"
            else
                # bind touchstart event to check if the element that has been touched is not the dropdown or the holder
                o.documentBody.on "touchstart.#{ pluginName }", (e) ->
                    target    = $ e.target
                    wrapperId = o.dropdownWrapper.attr 'id'

                    if (not target.is(".#{ o.opts.holder.class }") and not target.is("##{ wrapperId }")) and
                        (target.parents(".#{ o.opts.holder.class }").length is 0 and target.parents("##{ wrapperId }").length is 0)
                            o.dropdownWrapper.trigger("hide.#{ pluginName }") 

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
                o.el.trigger "compress.#{ pluginName }"

            if o.windowWidth isnt o.browserWindow.width()
                if o.browserWindow.width() < o.windowWidth and o.optimalCrumbHeight isnt o.el.height()
                    o.el.trigger("compress.#{ pluginName }")
                else
                    o.el.trigger("decompress.#{ pluginName }")

                o.windowWidth = o.browserWindow.width()

            # set the positioning of the dropdown menu
            holderOffset = o.el
                .find(".#{ o.opts.holder.class }")
                .offset()

            if typeof holderOffset isnt "undefined"
                # compute the right offset of the dropdownWrapper
                rightOffset = current.width() - (o.dropdownWrapper.outerWidth() + holderOffset.left)

                dropdownOffset =
                    top:  (o.el.offset().top + o.el.outerHeight())
                    left: 0

                dropdownOffset.left = if holderOffset.left <= rightOffset then holderOffset.left else ((current.width() - o.dropdownWrapper.outerWidth()) / 2)

                o.dropdownWrapper.css dropdownOffset

            return null

        o.getChildrenWidth = ->
            totalWidth = 0

            o.el
                .children()
                .each ->
                    totalWidth += ($ this).outerWidth(true)

            return totalWidth

        o.generateRandomKey = ->
            return "ezB_#{ Math.random().toString(36).substring(7) }"

        _this.destroy = ->
            o.opts.onDestroy(_this) if $.isFunction(o.opts.onDestroy)

            # Stop any animation
            o.el.stop true, true

            # Remove Events attached to the elements
            o.el.off ".#{ pluginName }"

            # remove the dropdown wrapper
            o.dropdownWrapper.remove()

            # remove any events attached to the document body
            o.documentBody.off ".#{ pluginName }"

            # remove any events attached to window object
            ($ window).off ".#{ pluginName }"

            # Remove Plugin Data
            o.el.removeData pluginName

            # replace the current element with the cloned element
            o.el.replaceWith o.cloneEl


        # Remove Element Classes
        _this.setOption = (key, value) ->
            if key of o.opts then o.opts[key] = value else o.error "Option \"#{ key }\" is not a known option."

            _this

        o.init()

        return null

    $.fn[pluginName] = (options) ->
        @each ->
            $.data this, pluginName, new EzBreadcrumbs(this, options) unless $.data(this, pluginName)

) jQuery, window, document