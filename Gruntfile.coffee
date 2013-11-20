# Grunt Task Configuration
module.exports = (grunt) ->
    # project configuration
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'
        coffee:
            common:
                files:
                    'assets/js/responsive.breadcrumbs.js': 'src/coffee/responsive.breadcrumbs.coffee'
                    'assets/js/site.js': 'src/coffee/site.coffee'
                options:
                    bare: true
        less:
            common:
                files:
                    'assets/css/site.css': 'src/less/site.less'
                    'assets/css/responsive.breadcrumbs.css': 'src/less/responsive.breadcrumbs.less'
        watch:
            coffee:
                files: ['src/coffee/site.coffee', 'src/coffee/responsive.breadcrumbs.coffee']
                tasks: ['coffee']
            less:
                files: ['src/less/site.less', 'src/less/responsive.breadcrumbs.less']
                tasks: ['less']
        concat:
            rwd:
                src: ['assets/dependencies/modernizr/modernizr.js', 'assets/dependencies/respond/respond.min.js']
                dest: 'assets/compiled/rwd.js'
            libs:
                src: ['assets/dependencies/jquery/jquery.min.js', 'assets/dependencies/underscore/underscore-min.js', 'assets/dependencies/bootstrap/dist/js/bootstrap.min.js']
                dest: 'assets/compiled/libs.js'
        notify_hooks:
            options:
                enabled: true
                max_jshint_notifications: 5
                title: "Responsive Breadcrumbs"

    # Load the plugin that provides the "coffee", "less", "watch" task.
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-less'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-concat'
    grunt.loadNpmTasks 'grunt-notify'

    # Default Tasks
    grunt.registerTask 'default', ['concat', 'watch']

    grunt.task.run 'notify_hooks'
