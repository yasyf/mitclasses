@ScheduleRecommendation = React.createClass
  render: ->
    block =
      if @props.data?
        <div>
          <MitClass data={@props.data}/>
          <ScheduleFeedbackButtons callback={@props.callback}/>
        </div>
      else if @props.done
        <p>No recommendations left!</p>
      else
        <p>Recommendations loading...</p>
    <div className='scheduleRecommendation'>
      {block}
    </div>
