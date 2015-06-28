marked = require 'marked'

class MainViewModel
  constructor: ->
    @editor = wx.property ''
    @viewer = wx.whenAny(this.editor, (editor) ->
      marked(editor)
    ).toProperty()

mainViewModel = new MainViewModel()

wx.applyBindings(mainViewModel)
