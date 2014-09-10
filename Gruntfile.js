module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    mochaTest: {
      test: {

        options: {
          reporter: 'nyan',
          clearRequireCache: true,
          require: ['./index.js']
        },
        src: ['test/**/*.coffee']
      }

    },
    watch: {
      test: {
        options: {
          spawn: false,
        },
        files: 'src/**/*.coffee',
        tasks: ['coffee:main', 'mochaTest']
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
  grunt.registerTask('default', ['coffee:main', 'mochaTest', 'watch']);

};
