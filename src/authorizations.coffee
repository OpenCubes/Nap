exports.canThis = ->
    if not @config.authorizations then return @allow
    
    @getRole().then (role) =>
      console.log role, @method, @config.authorizations
      if @config.authorizations
        switch @method
          when "GET"
            if ["guest", "user", "admin"].indexOf(role) isnt -1
              @allow()
             else @deny()
             return
        
          when "POST"
            if ["user", "admin"].indexOf(role) isnt -1
              @allow()
            else @deny()
            return
                  
          when "PUT"
            if ["admin"].indexOf(role) isnt -1
              @allow()
            else @deny()
            return
                  
          when "DELETE"
            if ["admin"].indexOf(role) isnt -1
              @allow()
            else @deny()
            return
      else return @allow()
    .fail console.log