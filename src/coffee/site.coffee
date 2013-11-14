(jQuery document).ready ($) ->
    "use strict"

    # cache important variables
    browserWindow = $ window
    currentDoc    = $ this
    html          = $ document.documentElement
    body          = $ document.body
    mainContainer = $ '#main-container'
    mainContent   = $ '#main-content'

    ($ '#basic-usage')
        .find('.breadcrumb')
        .responsiveBreadcrumbs
            onLoad: ->
                console.log 'loaded'

    # always return null
    return null