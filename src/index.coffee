### 

  # Soymilk

###

eco   = require "eco"
_     = require "underscore"
debug = require "debug"
$     = debug "soymilk"



templates = {}
layouts   = {}
helpers   = {}

class Soymilk
  # DRY?
  registerTemplate: (name, string) -> templates[name] = eco.compile string
  registerLayout  : (name, string) -> layouts[name]   = eco.compile string
  registerHelper  : (name, string) -> helpers[name]   = eco.compile string

  ### 

    ## What do we do here:

    We define a function, that - when given an argument of type `function` - will extend that function with properties of it's `this`. That way we can creat a `function object that` will inherit properties of `context`. We will use that to capture blocks of Eco templates (they are being internally converted to functions) and have all the properties of current context.

  ###
  bind: (template, data) ->
    $ "bind %j to %s", data, template

    context = {
      templates
      layouts
      helpers
      capture: (fn) -> _.extend fn, @
    }
      

    _.extend context, data

    if typeof template is "string"    then template = templates[template]
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

module.exports = Soymilk