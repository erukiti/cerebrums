class EditorViewModel
  constructor: (param) ->
    @title = wx.property ''
    @text = wx.property ''
    @isDirty = wx.property false
    @html = wx.property '<editor></editor>'

  setHeight: (height) ->
    @height = height
    @elem.style.height = "#{height}px"

    @elemEditor.style.height = "#{height - @elemTitleEditor.offsetHeight}px"

  setWidth: (width) ->
    @width = width
    @elem.style.width = "#{width}px"
    @elemEditor.style.width = "#{width}px"
    @elemTitleEditor.style.width = "#{width}px"

  setElement: (elem) ->
    @elem = elem.children[0]
    if @elem.children[0].className == 'titleEditor'
      @elemTitleEditor = @elem.children[0]
      @elemEditor = @elem.children[1]
    else
      @elemTitleEditor = @elem.children[1]
      @elemEditor = @elem.children[0]


  setId: (id) ->
    @id = id

module.exports = EditorViewModel
