module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    mochaTest: {
      test: {

        options: {
          reporter: 'spec',
          clearRequireCache: true,
          require: ['./index.js']
        },
        src: ['test/**/*.coffee']
      },
      report: {

        options: {
          reporter: 'markdown',
          clearRequireCache: true,
          require: ['./index.js'],

          quiet: true,
          captureFile: 'FEATURES.md',
        },
        src: ['test/**/*.coffee'],
      }

    },
    watch: {
      test: {
        options: {
          spawn: false,
        },
        files: ['src/**/*.coffee', 'test/**/*.coffee'],
        tasks: ['mochaTest:test', 'coffee:main']
      }
    },
    coffee: {

      main: {
        options: {
          bare: true
        },

        files: [{
          expand: true,
          cwd: "./src",
          src: ["**/*.coffee"],
          dest: "./lib",
          ext: ".js"
        }]
      },


    }
  });
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-mocha-test');

  // Default task(s).
  grunt.registerTask('default', ['coffee:main', 'mochaTest:test', 'watch']);
  grunt.registerTask('test', ['coffee:main', 'mochaTest:test']);
  grunt.registerTask('report', ['coffee:main', 'mochaTest:report']);

};
