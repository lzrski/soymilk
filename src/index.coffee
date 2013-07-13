### 

  # Soymilk

###

eco     = require "eco"
_       = require "underscore"
wrench  = require "wrench"
fs      = require "fs"
async   = require "async"
debug   = require "debug"
$       = debug "soymilk"

# Views are stored here. Controllers are immediately mounted to router
views =
  templates: {}
  layouts  : {}
  helpers  : {}

module.exports =
  # DRY?
  register_view: (type, name, string) ->
    $ = debug "soymilk:register_view"
    $ "Registering %s '%s' containing:", type, name
    $ "%s", string
    if typeof type is "string" and type in ["template", "layout", "helper"]
      name = String name
      views[type + "s"][name] = eco.compile string
    else throw new Error """
      First parameter to register must be a string with value in ['template', 'layout', 'helper']
    """

  load_view: (type, name, path, done) ->
    $ = debug "soymilk:load_view"
    $ "loading %s from %s as %s", type, path, name
    fs.readFile path, encoding: "utf-8", (error, string) =>
      if typeof string is "string" then @register_view type, name, string
      else $ "%s is not a string (%j)", string, error
      done error

  load_views: (directory, callback) ->
    $ = debug "soymilk:load_views"
    $ "Loading views from %s", directory

    load_type = (type, next_type) =>
      $ = debug "soymilk:load_views:#{type}"
      plural = type + "s"
      path = directory + "/" + plural

      $ "Loading %s from %s", plural, path
      if not (fs.existsSync(path) and fs.statSync(path).isDirectory())
        $ "No such directory: %s (%j)", path, fs.statSync path
        do next_type
      else # directory exists
        load_file = (file, next_file) =>
          $ = debug "soymilk:load_views:#{type}:file"
          # Little helper to be used in async.each below
          name = file.split('.').shift()
          @load_view type, name, path + "/" + file, next_file
        
        # TODO: use wrench.readdirRecursive (tried and strange behaviour occurs in tests)
        fs.readdir path, (error, files) ->
          $ = debug "soymilk:load_views:readdir"
          if error then return next_file error
          if not files then throw new Error "WTF?"
          files = files.filter (file) -> file.match /(.+)\.eco$/
          async.each files, load_file, next_type

    async.each ["template", "layout", "helper"], load_type, callback

  get_registered_views: -> 
    registered = {}
    for type of views
      registered[type] = _.keys views[type]
    return registered

  # load: (type, done) ->
  #   ###
  #     Swiss army knife method to load views (templates, layouts, helpers) or controller
  #     Usage:
  #       load views: "/views", controllers: "/controllers", (error) -> ...
  #         load
  #           all templates   from directory views/templates
  #           all layouts     from directory views/layouts
  #           all helpers     from directory views/helpers
  #           all controllers from directory controllers/
  #   ###
  #   if typeof type is object then @load key,
  #   if typeof type is "string" and type in ["template", "layout", "helper", "controller"]

  # load: (options, next) ->
  #   options = _.pick options, [
  #     "views"
  #     "controllers"
  #   ]
  #   loadTemplate
  #   async.parallel {
  #     (done) =>
  #       wrench.readDirRecursive options.views, (error, files) =>
  #         for file in files when file.match /(.+)\.eco$/
  #           path = options.views + "/templates/" + file
  #           name = file.split(".").shift()
  #           fs.readFile file, (error, template) =>
  #             @registerTemplate name, template
  #         done error


  #   }



  ### 

    ## type do we do here:

    We define a function, that - when given an argument of type `function` - will extend that function with properties of it's `this`. That way we can creat a `function object that` will inherit properties of `context`. We will use that to capture blocks of Eco templates (they are being internally converted to functions) and have all the properties of current context.

  ###
  bind: (template, data) ->
    $ = debug "soymilk:bind"
    $ "binding data %j to template %s", data, template

    context = capture: (fn) -> _.extend fn, @
    _.extend context, views
    _.extend context, data

    if typeof template is "string"    then template = views.templates[template]
    if typeof template is "function"  then template context
    else 
      message =  """
        Wrong template provided.

        First argument to bind should be either a name of registered Eco template or a compiled Eco template.
      """
      if (_.keys templates).length
        message += "\n\nThere are following templates registered:"
        message += "\n  * #{name}" for name of templates

      throw new Error message
      