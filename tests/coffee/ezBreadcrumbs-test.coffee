(jQuery document).ready ($) ->
    "use strict"

    # cache important variables
    browserWindow = $ window
    currentDoc    = $ this
    html          = $ document.documentElement
    body          = $ document.body

    testElement = ($ '#test-breadcrumb').find '.breadcrumb'

    children    = testElement.children 'li'

    crumbWidths = children
        .map( ->
            return ($ this).outerWidth true
        )
        .get()

    crumbHeights = children
        .map( ->
            return ($ this).outerHeight true
        )
        .get()

    maxWidth = 0

    _.each crumbWidths, (v) ->
        maxWidth += v

    testElement.ezBreadcrumbs()

    testElementData = testElement.data 'ezBreadcrumbs'

    optimalCrumbHeight = _.max crumbHeights

    testsFn =
        load: ->
            test 'check breadcrumb if it responsive on window load', ->
                equal optimalCrumbHeight, testElement.height()

        status: (e) ->
            console.log "Test Element Width: #{ testElement.width() }. Element should wrap/unwrap on #{ maxWidth }"

            test "check breadcrumb status on width #{ testElement.width() }", ->
                if testElement.width() < maxWidth
                    console.log "testing on window size less than or equal to #{ maxWidth }."

                    equal testElementData.getState(), 'compressed'
                    equal testElementData.isCompressed(), true
                    equal testElement.hasClass('ezbreadcrumbs-wrapped'), true
                else
                    console.log "testing on window size greater than #{ maxWidth }."

                    equal testElementData.getState(), 'decompressed'
                    equal testElementData.isCompressed(), false
                    equal testElement.hasClass('ezbreadcrumbs-wrapped'), false

            console.log '-----------------'

    window.onload = testsFn.load

    browserWindow.on 'resize.test', _.debounce(testsFn.status, 200)

    # always return null
    return null