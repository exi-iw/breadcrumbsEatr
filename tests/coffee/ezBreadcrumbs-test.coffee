(jQuery document).ready ($) ->
    "use strict"

    # cache important variables
    browserWindow = $ window
    currentDoc    = $ this
    html          = $ document.documentElement
    body          = $ document.body

    testElement = ($ '#usage').find '.breadcrumb'

    testElement.ezBreadcrumbs()

    testElementData = testElement.data 'ezBreadcrumbs'

    maxWidth = 670

    testsFn =
        status: (e) ->
            current = $ this

            test "check breadcrumb status on width #{ current.width() }", ->
                if browserWindow.width() <= maxWidth
                    console.log "testing on window size less than or equal to #{ maxWidth }."

                    equal testElementData.getState(), 'compressed'
                    equal testElementData.isCompressed(), true
                    equal testElement.hasClass('ezbreadcrumbs-wrapped'), true
                else
                    console.log "testing on window size greater than #{ maxWidth }."

                    equal testElementData.getState(), 'decompressed'
                    equal testElementData.isCompressed(), false
                    equal testElement.hasClass('ezbreadcrumbs-wrapped'), false

    browserWindow.on 'resize.test', _.debounce(testsFn.status, 200)

    # begin test on load
    browserWindow.trigger 'resize.test'

    # always return null
    return null