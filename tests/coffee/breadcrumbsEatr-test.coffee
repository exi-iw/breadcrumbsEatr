(jQuery document).ready ($) ->
    "use strict"

    # cache important variables
    browserWindow = $ window
    currentDoc    = $ this
    html          = $ document.documentElement
    body          = $ document.body

    testElement      = ($ '#test-breadcrumb').find '.breadcrumb'
    smartCompression = ($ '#smart-compression-breadcrumb').find '.breadcrumb'

    testsFn =
        load: ->
            test 'check breadcrumb if it responsive on window load', ->
                equal optimalCrumbHeight, testElement.height()

        status: (e) ->
            console.log "Test Element Width: #{ testElement.width() }. Element should wrap/unwrap on #{ maxWidth }"

            testElementData = testElement.data 'breadcrumbsEatr'

            test "check breadcrumb status on width #{ testElement.width() }", ->
                if testElement.width() < maxWidth
                    console.log "testing on window size less than or equal to #{ maxWidth }."

                    equal testElementData.getState(), 'compressed'
                    equal testElementData.isCompressed(), true
                    equal testElement.hasClass('breadcrumbseatr-wrapped'), true
                else
                    console.log "testing on window size greater than #{ maxWidth }."

                    equal testElementData.getState(), 'decompressed'
                    equal testElementData.isCompressed(), false
                    equal testElement.hasClass('breadcrumbseatr-wrapped'), false

            console.log '-----------------'

        bodyHidden: ->
            console.log 'body is hidden test'

            smartCompressionData = smartCompression.data 'breadcrumbsEatr'

            test 'check if breadcrumb is compressed when the body is hidden', ->
                equal smartCompressionData.getState(), 'decompressed'

        bodyShown: ->
            console.log 'body is revealed test'

            smartCompressionData = smartCompression.data 'breadcrumbsEatr'

            test 'check if breadcrumb is compressed after the body is revealed', ->
                equal smartCompressionData.getState(), 'compressed'

    if testElement.length > 0
        console.log 'basic tests'

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

        testElement.breadcrumbsEatr()

        optimalCrumbHeight = _.max crumbHeights

        window.onload = testsFn.load

        browserWindow.on 'resize.test', _.debounce(testsFn.status, 200)

    if smartCompression.length > 0
        console.log 'smart compression test'

        if browserWindow.width() > 640
            console.error 'Browser Window must be less than or equal to 640 to conduct this test.'
        else 
            body.hide()

            smartCompression.breadcrumbsEatr()

            testsFn.bodyHidden()

            window.setTimeout(->
                body.show()
            , 1000)

            window.setTimeout(->
                testsFn.bodyShown()
            , 1200)

    # always return null
    return null