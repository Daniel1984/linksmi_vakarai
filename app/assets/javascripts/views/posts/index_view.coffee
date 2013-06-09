define [
  'backbone'
  'views/posts/search_post_manager'
  'views/posts/create_post_manager'
  'views/posts/list_view'
  'collections/posts'
  'spin'
], (Backbone, SearchPostManager, CreatePostManager, ListView, Posts, Spinner) ->
  class PostsIndexView extends Backbone.View
    className: 'posts-conainer'

    initialize: (options) ->
      @spinner = new Spinner(color: '#fff')
      @posts = new Posts()
      @posts.on('reset', @renderList)
      
    render: =>
      @$el.html()
      @enableSearch()
      @enableCreate()
      @fetch()
      @

    fetch: (data = {}) =>
      @listView?.remove()
      @$el.append(@spinner.spin().el)
      @posts.fetch(data: data, reset: true)

    enableSearch: =>
      @searchView = new SearchPostManager(collection: @posts, parent: @)
      @$el.append(@searchView.render().el)

    enableCreate: =>
      @createInput = new CreatePostManager()
      @$el.append(@createInput.render().el)

    renderList: =>
      @spinner.stop()
      @listView = new ListView(collection: @posts)
      @$el.append(@listView.render().el)
      @listView.manageTiles()