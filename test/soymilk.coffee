do (require "source-map-support").install

soymilk   = require '..'
expect    = require 'expect.js'
minify    = (html) -> html.replace /\n\s*/g, " "

describe "Soymilk", ->
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

    soymilk.register_view "template", "simple", template
    html = minify (soymilk.bind "simple", data)

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

  it "can use a layout", ->
    soymilk.register_view "layout", "basic", """
      <!doctype html>
      <html>
        <head>
          <title><%- @title %> for <%- @user.name %></title>
        </head>
        <body>
          <h1><%- @title %></h1>
          <%- do @ %>
        </body>
      </html>
    """

    soymilk.register_view "template", "partial", """
      <%- @layouts.basic @capture => %>
        <p>It's an amazing <%= @user.name %>!</p>
      <% end %>
    """

    html = soymilk.bind "partial",
      title : "Applause"
      user  :
        # Can't use bare 'name' as a property, as it will be overriten by function name (which will be `undefined`), and won't be visible in layout. 
        # TODO: Warn user if 'name' used as a property of `context`
        name  : "Katiusza"

    expect(minify html).to.be minify """
      <!doctype html>
      <html>
        <head>
          <title>Applause for Katiusza</title>
        </head>
        <body>
          <h1>Applause</h1>
          <p>It's an amazing Katiusza!</p>
        </body>
      </html>
    """

  it "can use helpers", ->
    soymilk.register_view "helper", "userbox", """
      <div class="userbox">
        <h3>Amazing <%- @name %></h3>
        <p>Come see as this trully amazing <%- @role %> does spectacular tricks!</p>
      </div>
    """
    soymilk.register_view "template", "helpee", """
      <section class="users">
      <% for user in @users: %>
        <%- @helpers.userbox user %>
      <% end %>
      </section>
    """
    output = soymilk.bind "helpee",
      title: "Circus"
      users: [
        { name: "Katiusza", role: "cat" }
        { name: "Roger", role: "grasshoper" }
      ]

    expect(minify output).to.be minify """
      <section class="users">
        <div class="userbox">
          <h3>Amazing Katiusza</h3>
          <p>Come see as this trully amazing cat does spectacular tricks!</p>
        </div>
        <div class="userbox">
          <h3>Amazing Roger</h3>
          <p>Come see as this trully amazing grasshoper does spectacular tricks!</p>
        </div>
      </section>
    """

  it "can report registered views", ->
    views = do soymilk.get_registered_views
    expect(views).to.eql
      templates : [ "simple", "partial", "helpee" ]
      layouts   : [ "basic" ]
      helpers   : [ "userbox" ]

  it "can read views from directory", (done) ->
    soymilk.load_views __dirname + "/views", ->
      views = soymilk.get_registered_views()
      expect(views).to.eql
        templates : [ "simple", "partial", "helpee", "index" ]
        layouts   : [ "basic", "default" ]
        helpers   : [ "userbox", "header" ]
      do done

      
      # output = soymilk.bind "index",
      #   title : "Users"
      #   site  :
      #     title : "Soymilk Factory"
      #     slogan: "A cream that is Eco!"
      #   users : [
      #     { name: "Bob", role: "soy farmer" }
      #     { name: "ST 583-12a", role: "giant soy processing robot" }
      #   ]

      # expect(minify output).to.be minify """
      #   <!doctype html>
      #   <html>
      #     <head>
      #       <title>Soymilk Factory | Users</title>
      #     </head>
      #     <body>
            
      #       <header>
      #         <h1>Soymilk Factory</h1>
      #         <h2>A cream that is Eco!</h2>
      #       </header>
            
      #       <section class="users">
      #         <div class="userbox">
      #           <h3>Bob</h3>
      #           <p>Come see as this trully amazing <%- @role %>, as he does spectacular job!</p>
      #         </div>
      #         <div class="userbox">
      #           <h3>ST 583-12a</h3>
      #           <p>Come see as this trully amazing giant soy processing robot, as he does spectacular job!</p>
      #         </div>
      #       </section>

      #       <section class="content">
      #         Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
      #         tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
      #         quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
      #         consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
      #         cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
      #         proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
      #       </section>

      #       <footer>&copy; Tadeusz Łazurski 2013</footer>
          
      #     </body>
      #   </html>
      # """