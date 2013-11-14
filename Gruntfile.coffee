# Grunt Task Configuration
module.exports = (grunt) ->
    # project configuration
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'
        coffee:
            common:
                files:
                    'assets/js/responsive.breadcrumbs.js': 'src/coffee/responsive.breadcrumbs.coffee'
                options:
                    bare: true
        less:
            common:
                files:
                    'assets/js/responsive.breadcrumbs.css': 'src/less/responsive.breadcrumbs.less'
        watch:
            coffee:
                files: ['src/coffee/responsive.breadcrumbs.coffee']
                tasks: ['coffee']
            less:
                files: ['src/less/responsive.breadcrumbs.less']
                tasks: ['less']

    # Load the plugin that provides the "coffee", "less", "watch" task.
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-less'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    # Default Tasks
    grunt.registerTask 'default', ['coffee']
