@StudentLink = React.createClass
  render: ->
    <p className='studentLink'>
      <a href={@props.url}>{@props.name}</a>
    </p>
