@Feedback = React.createClass
  className: ->
    if @props.positive then 'positive' else 'negative'
  toggle: ->
    @props.handlers.toggle(@props.id, !@props.positive)
  destroy: ->
    @props.handlers.destroy(@props.id)
  render: ->
    <div className='Feedback'>
      <p>
        <span onClick={@destroy}>X </span>
        <span className={@className()} onClick={@toggle}>{@props.number} {@props.name}</span>
      </p>
    </div>
