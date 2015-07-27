class EditorViewModel
  constructor: (param) ->
    console.log "EditorViewModel"
    @title = wx.property ''
    @text = wx.property ''
    @isDirty = wx.property false
    


module.exports = EditorViewModel
