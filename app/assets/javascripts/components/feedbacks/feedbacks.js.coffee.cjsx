@Feedbacks = React.createClass
  getInitialState: ->
    feedbacks: @props.feedbacks
  destroyFeedback: (id) ->
    $.post "#{@props.endpoints.feedbacks}/#{id}",
      _method: 'DELETE'
    .then =>
      @setState feedbacks: _.filter @state.feedbacks, (f) -> f.id isnt id
  toggleFeedback: (id, newValue) ->
    $.post "#{@props.endpoints.feedbacks}/#{id}",
      _method: 'PATCH'
      feedback:
        positive: newValue
    .then =>
      @setState feedbacks: _.map @state.feedbacks, (f) ->
        f.positive = !f.positive if f.id is id
        f
  render: ->
    handlers = toggle: @toggleFeedback, destroy: @destroyFeedback
    <div className='Feedbacks'>
      <h1>Feedbacks</h1>
      <h2>{@props.student.name}</h2>
      <FeedbackList feedbacks={@state.feedbacks} handlers={handlers}/>
    </div>
