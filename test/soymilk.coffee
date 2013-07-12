do (require "source-map-support").install

Soymilk   = require '..'
expect    = require 'expect.js'
minify    = (require 'html-minifier').minify

describe "Soymilk", ->
  sm = new Soymilk

  it "can fill a simple template", ->
    template = """
      <html>
        <head>
          <title><%- @title %></title>
        </head>
        <body>
          <h1><%- @title %></h1>
          <p>Hello, <%- @name %></p>
        </body>
      </html>
    """

    data =
      title : "Greetings"
      name  : "Katiusza"

    sm.registerTemplate "simple", template
    html = sm.bind "simple", data
    html = minify html

    expected = minify """
      <html>
        <head>
          <title>Greetings</title>
        </head>
        <body>
          <h1>Greetings</h1>
          <p>Hello, Katiusza</p>
        </body>
      </html>
    """

    expect(html).to.be expected
