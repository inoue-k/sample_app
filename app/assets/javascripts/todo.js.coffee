# ToDo app
# from https://github.com/jashkenas/backbone/tree/master/examples/todos

$ ->
  class ToDo extends Backbone.Model
    defaults: () ->
      {
        title: "empty todo..."
        order: Todos.nextOrder()
        done: false
      }

    toggle: () ->
      @save(done: !@get("done"))

  class TodoList extends Backbone.Collection
    model: ToDo

    localStorage: if Backbone.LocalStorage? then new Backbone.LocalStorage("todos-backbone") else false

    done: () ->
      @where(done: true)

    remaining: () ->
      @where(done: false)

    nextOrder: () ->
      return 1 if !@length
      @last().get('order') + 1

  window.Todos = new TodoList

  class TodoView extends Backbone.View
    tagName: 'li'
    template: _.template($('#item-template').html())

    events:
      "click .toggle" : "toggleDone"
      "dblclick .view" : "edit"
      "click a.destroy" : "clear"
      "keypress .edit" : "updateOnEnter"
      "blur .edit" : "close"

    initialize: () ->
      @listenTo(@model, 'change',  @render)
      @listenTo(@model, 'destroy', @remove)

    render: () ->
      @$el.html(@template(@model.toJSON()))
      @$el.toggleClass('done', @model.get('done'))
      @input = @$('.edit')
      @

    toggleDone: () ->
      @model.toggle()

    edit: () ->
      @$el.addClass('editing')
      @input.focus()

    close: () ->
      value = @input.val()
      if !value
        @clear()
      else
        @model.save(title: value)
        @$el.removeClass('editing')

    updateOnEnter: (e) ->
      @close() if e.keyCode == 13

    clear: () ->
      @model.destroy()

  class AppView extends Backbone.View
    el: $("#todoapp")
    statsTemplate: _.template($('#stats-template').html())

    events:
      "keypress #new-todo": "createOnEnter"
      "click #clear-completed": "clearCompleted"
      "click #toggle-all": "toggleAllComplete"

    initialize: () ->
      @input = @$('#new-todo')
      @allCheckbox = @$('#toggle-all')[0]

      @listenTo(Todos, 'add', @addOne)
      @listenTo(Todos, 'reset', @addAll)
      @listenTo(Todos, 'all', @render)

      @footer = @$('footer')
      @main = @$('#main')

      if Backbone.LocalStorage?
        Todos.fetch()

    render: () ->
      done = Todos.done().length
      remaining = Todos.remaining().length

      if Todos.length != 0
        @main.show()
        @footer.show()
        @footer.html(this.statsTemplate(done: done, remaining: remaining))
      else
        @main.hide()
        @footer.hide()

    addOne: (todo) ->
      view = new TodoView(model: todo)
      @$('#todo-list').append(view.render().el)

    addAll: () ->
      Todos.each(@addOne, @)

    createOnEnter: (e) ->
      return if e.keyCode != 13
      return if !@input.val()

      Todos.create(title: @input.val())
      @input.val('')

    clearCompleted: () ->
      _.invoke(Todos.done(), 'destroy')
      false

    toggleAllComplete: () ->
      done = @allCheckbox.checked
      Todos.each((todo) -> todo.save('done': done))

  window.App = new AppView()
