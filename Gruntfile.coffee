# Grunt Task Configuration
module.exports = (grunt) ->
    # project configuration
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'
        coffee:
            common:
                files:
                    'public/lib/js/common.js': 'public/lib/js/coffee/common.coffee'
                options:
                    bare: true
        watch:
            common:
                files: ['public/lib/js/coffee/common.coffee']
                tasks: ['coffee']

    # Load the plugin that provides the "coffee" task.
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-devtools'

    # Default Tasks
    grunt.registerTask 'default', ['coffee']
