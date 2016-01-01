@ScheduleFeedbackButtons = React.createClass
  respondYes: ->
    @props.callback(yes)
  respondNo: ->
    @props.callback(no)
  render: ->
    <div className='scheduleFeedbackButtons'>
      <button onClick={@respondYes}>Yes</button>
      <button onClick={@respondNo}>No</button>
    </div>
