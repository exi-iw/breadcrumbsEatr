(($, window, document, undefined_) ->
    "use strict"

    pluginName = 'responsiveBreacrumbs'
    defaults =
        onLoad: ->
        onDestroy: ->

    ResponsiveBreacrumbs = (el, options) ->
        o        = ($ el).data '_obj', {}
        _this    = this
        metadata = ($ el).data "#{ pluginName.toLowerCase() }-options"

        o.debug = ->
            # Skip browsers w/o firebug or console
            if console and $.isFunction(console.log)
                return false if arguments_.length < 1

                args = []

                for n of arguments_
                    args.push arguments_[n]
                    args.push " >> "

                args.push o.el  if args.length is 1
                args.push "[#{ pluginName }]"

                console.log.apply console, args

        o.error = ->
            # Skip browsers w/o firebug or console
            if console and $.isFunction(console.log)
                return false if arguments_.length < 1

                args = []

                for n of arguments_
                    args.push arguments_[n] + (" >> ")

                args.push o.el  if args.length is 1
                args.push "[#{ pluginName }]"

                console.error.apply console, args

        # Initialize Properties and States Plugin
        o.init = ->
            # Extend options
            o.opts = $.extend {}, defaults, options, metadata

            # Initialize 
            o.el = $(el)
            o.cloneEl = o.el.clone() # Reference to the old untouched element
            o.opts.onLoad(_this) if $.isFunction(o.opts.onLoad)

        _this.destroy = ->
            o.opts.onDestroy(_this) if $.isFunction(o.opts.onDestroy)

            # Stop any animation
            # o.el.stop(true, true);

            # Remove Events attached to the elements
            # o.el.off('.' + pluginName); 

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
            $.data this, pluginName, new FrozPluginName(this, options) unless $.data(this, pluginName)

) jQuery, window, document