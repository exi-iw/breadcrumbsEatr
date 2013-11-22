# Grunt Task Configuration
module.exports = (grunt) ->
    # project configuration
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'
        coffee:
            common:
                files:
                    'assets/js/ezBreadcrumbs.js': 'src/coffee/ezBreadcrumbs.coffee'
                    'assets/js/site.js': 'src/coffee/site.coffee'
                    'tests/js/ezBreadcrumbs-test.js': 'tests/coffee/ezBreadcrumbs-test.coffee'
                options:
                    bare: true
        less:
            common:
                files:
                    'assets/css/site.css': 'src/less/site.less'
                    'assets/css/ezBreadcrumbs.css': 'src/less/ezBreadcrumbs.less'
        watch:
            coffee:
                files: ['src/coffee/site.coffee', 'src/coffee/ezBreadcrumbs.coffee', 'tests/coffee/ezBreadcrumbs-test.coffee']
                tasks: ['coffee']
            less:
                files: ['src/less/site.less', 'src/less/ezBreadcrumbs.less']
                tasks: ['less']
            qunit:
                files: ['tests/coffee/ezBreadcrumbs-test.coffee', 'tests/index.html']
                tasks: ['connect', 'qunit']
        concat:
            rwd:
                src: ['assets/dependencies/modernizr/modernizr.js', 'assets/dependencies/respond/respond.min.js']
                dest: 'assets/compiled/rwd.js'
            libs:
                src: [
                    'assets/dependencies/jquery/jquery.min.js',
                    'assets/dependencies/underscore/underscore-min.js',
                    'assets/dependencies/bootstrap/dist/js/bootstrap.min.js',
                ]
                dest: 'assets/compiled/libs.js'
        notify_hooks:
            options:
                enabled: true
                max_jshint_notifications: 5
                title: "ezBreadcrumbs"

    # Load the plugin that provides the "coffee", "less", "watch" task.
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-less'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-concat'
    grunt.loadNpmTasks 'grunt-notify'

    # Default Tasks
    grunt.registerTask 'default', ['concat', 'coffee', 'less', 'watch']

    grunt.task.run 'notify_hooks'
