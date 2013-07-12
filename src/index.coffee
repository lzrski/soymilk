eco = require "eco"
_   = require "underscore"

layout = """
  <body>
    <% console.log "layout" %>
    <% console.dir @ %>
    <% console.dir arguments %>
    <h1><%- @title %></h1>
    <%- do @ %>
  </body>
"""
lfn = eco.compile layout

context = (fn) -> _.extend fn, arguments.callee
data =
  title   : "Working Eco layout"
  user    : 
    # TODO: plain name would not work - investigate why and warn user if appropriate
    name    : "Bob"
  layout  : lfn
_.extend context, data

console.dir context

template = """
  <%- @layout @ => %>
    <% console.log "template" %>
    <% console.dir @ %>
    <% console.dir arguments %>
    <p>Hello, <%= @user.name %>!</p>
  <% end %>
"""
tfn = eco.compile template

html = tfn context


console.log html
