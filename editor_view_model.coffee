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

    console.dir height
    console.dir @elem

  setElement: (elem) ->
    @elem = elem.children[0]
    console.dir @elem
    if @elem.children[0].className == 'titleEditor'
      @elemTitleEditor = @elem.children[0]
      @elemEditor = @elem.children[1]
    else
      @elemTitleEditor = @elem.children[1]
      @elemEditor = @elem.children[0]


  setId: (id) ->
    @id = id

module.exports = EditorViewModel
