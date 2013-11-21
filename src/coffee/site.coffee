(jQuery document).ready ($) ->
    "use strict"

    # cache important variables
    browserWindow = $ window
    currentDoc    = $ this
    html          = $ document.documentElement
    body          = $ document.body
    mainContainer = $ '#main-container'
    mainContent   = $ '#main-content'

    ($ '#usage')
        .find('.breadcrumb')
        .ezBreadcrumbs()

    # always return null
    return null