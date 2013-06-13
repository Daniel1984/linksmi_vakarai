define [
  'backbone'
  'views/post_comments/list_view'
  'views/post_comments/form_view'
  'collections/post_comments'
  'models/post_comment'
  'text!templates/post_comments/alert_msg.html'
  'text!templates/post_comments/index.html'
  'spin'
], (Backbone, ListView, FormView, Comments, Comment, NoCommentsMsg, template, Spinner) ->
  class IndexView extends Backbone.View
    initialize: (options) ->
      console.log 'hahahah got here'
      @template = _.template(template)
      @postId = options.postId
      @spinner = new Spinner(color: '#000', width: 4, length: 6, lines: 11, radius: 8)
      @noCommentsMsg = _.template(NoCommentsMsg)
      @comment = new Comment(post_id: @postId)
      @comments = new Comments()
      @comments.on('reset', @renderList)
      @fetch(post_id: @postId)

    render: =>
      @$el.html(@template)
      @$el.find('.spinner-container').append(@spinner.spin().el)
      @renderForm()
      @

    fetch: (data = {}) =>
      @comments.fetch(data: data, reset: true)

    renderList: =>
      @spinner.stop()
      if @comments.length == 0
        @$el.find('.comments-container').append(@noCommentsMsg)
      else
        @listView = new ListView(collection: @comments)
        @$el.find('.comments-container').append(@listView.render().el)

    renderForm: =>
      @formView = new FormView(model: @comment)
      @$el.find('.form-container').append(@formView.render().el)
