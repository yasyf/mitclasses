@MitClass = React.createClass
  render: ->
    <div className='mitClass'>
      <h3>{@props.data.number} {@props.data.name}</h3>
      <p>{@props.data.description}</p>
    </div>
