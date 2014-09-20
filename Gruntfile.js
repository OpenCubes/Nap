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

          log: false,
        },
        src: ['test/**/*.coffee'],
        dest: './FEATURES.md'
      }

    },
    watch: {
      test: {
        options: {
          spawn: false,
        },
        files: ['src/**/*.coffee', 'test/**/*.coffee'],
        tasks: ['coffee:main', 'mochaTest:test']
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
