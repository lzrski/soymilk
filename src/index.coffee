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
    <!doctype html>
    <html>
      <head>
        <title><%- @title %></title>
        <% for sheet in @stylesheets: %>
          <link rel="stylesheet" type="text/css" href="<%=sheet%>">
        <% end %>
      </head>
      <body>
        <h1>
        <%- do @ %>
      </body>
    """
    sub: eco.compile """
      <% @stylesheets.push "sub-layout.css" %>
      <%- @layouts.sample @capture => %>
        <section class="greetings">
          <h2>Bob came</h2>
          <%- do @ %>
        </section>
      <% end %>
    """

# This is a sample data. Again - real data will be provided by application logic.
data =
  title       : "Working Eco layout"
  name        : "Bob"
  stylesheets : [
    "bobs.css"
  ]

# Extend context with provided data
_.extend context, data


console.dir context

# Sample template
template = """
  <%- @layouts.sub @capture => %>
    <p>Hello, <%= @name %>!</p>
  <% end %>
"""
tfn = eco.compile template

html = tfn context

console.log html
