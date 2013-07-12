### 

  # Soymilk

###

eco = require "eco"
_   = require "underscore"


### 

  ## What do we do here:

  We define a function, that - when given an argument of type `function` - will extend that function with properties of it's `this`. That way we can creat a function object that will inherit properties of `context`. We will use that to capture blocks of Eco templates (they are being internally converted to functions) and have all the properties of current context

###

context =
  capture: (fn) -> _.extend fn, @
  layouts:
    # This is a sample layout. Real layouts will be provided by application logic.
    sample: eco.compile """
      <body>
        <% console.log "layout" %>
        <% console.dir @ %>
        <% console.dir arguments %>
        <h1><%- @title %></h1>
        <%- do @ %>
      </body>
    """


# This is a sample data. Again - real data will be provided by application logic.
data =
  title   : "Working Eco layout"
  name    : "Bob"

# Extend context with provided data
_.extend context, data


console.dir context

# Sample template
template = """
  <%- @layouts.sample @capture => %>
    <% console.log "template" %>
    <% console.dir @ %>
    <% console.dir arguments %>
    <p>Hello, <%= @name %>!</p>
  <% end %>
"""
tfn = eco.compile template

html = tfn context


console.log html
