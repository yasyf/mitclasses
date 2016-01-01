@Student = React.createClass
  render: ->
    nodes = (<StudentLink name={name} url={url} key={name}/> for name, url of @props.endpoints)
    <div className='student'>
      {nodes}
    </div>
