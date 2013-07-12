eco = require "eco"

template = """
  <% layout = (content) => %>
    <body>
      <% console.dir @ %>
      <% console.dir arguments %>
      <h1><%- @title %></h1>
      <%- do content %>
    </body>
  <% end %>
  <%- layout => %>
    <p>Hello, <%= @name %>!</p>
  <% end %>
"""

t = eco.compile template

html = t
  title : "Working Eco layout"
  name  : "Bob"

console.log html
